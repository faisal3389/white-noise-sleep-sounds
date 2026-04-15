import AVFoundation
import Foundation

class AudioEngine {
    private let engine = AVAudioEngine()

    // Single sound playback
    private var playerNode: AVAudioPlayerNode?
    private var sourceNode: AVAudioSourceNode?
    private var audioFile: AVAudioFile?
    private var isUsingGeneratedNoise = false

    // Mix playback (up to 5 simultaneous sounds)
    private var mixPlayerNodes: [String: AVAudioPlayerNode] = [:]
    private var mixSourceNodes: [String: AVAudioSourceNode] = [:]
    private var mixVolumes: [String: Float] = [:]
    private var isMixMode = false

    // Brown noise state
    private var brownNoiseLastOutput: Float = 0.0

    // Pink noise state (Voss-McCartney with 8 octaves)
    private var pinkNoiseRows = [Float](repeating: 0, count: 8)
    private var pinkNoiseRunningSum: Float = 0
    private var pinkNoiseIndex: Int = 0

    // Per-source noise state for mix mode
    private var mixBrownNoiseState: [String: Float] = [:]
    private var mixPinkNoiseState: [String: (rows: [Float], runningSum: Float, index: Int)] = [:]

    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            print("AudioSession setup failed: \(error)")
        }
    }

    // MARK: - Play Generated Noise

    func playGeneratedNoise(type: String) {
        stopAll()
        isUsingGeneratedNoise = true
        isMixMode = false

        // Reset noise state
        brownNoiseLastOutput = 0
        pinkNoiseRows = [Float](repeating: 0, count: 8)
        pinkNoiseRunningSum = 0
        pinkNoiseIndex = 0

        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        var previousSample: Float = 0

        let source = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, bufferList -> OSStatus in
            guard let self else { return noErr }
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            let buffer = buffers[0]
            let frames = Int(frameCount)
            guard let data = buffer.mData?.assumingMemoryBound(to: Float.self) else { return noErr }

            for i in 0..<frames {
                let sample: Float
                switch type {
                case "white_noise":
                    sample = Float.random(in: -1.0...1.0)
                case "pink_noise":
                    sample = self.generatePinkNoise()
                case "brown_noise":
                    sample = self.generateBrownNoise()
                case "blue_noise":
                    let white = Float.random(in: -1.0...1.0)
                    sample = max(-1.0, min(1.0, white - previousSample))
                    previousSample = white
                default:
                    sample = 0
                }
                data[i] = sample * 0.3 // Master gain reduction
            }
            return noErr
        }

        sourceNode = source
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            print("Engine start failed: \(error)")
        }
    }

    private func generatePinkNoise() -> Float {
        let white = Float.random(in: -1.0...1.0)
        pinkNoiseIndex += 1

        // Voss-McCartney algorithm
        var changed = pinkNoiseIndex
        for i in 0..<pinkNoiseRows.count {
            if changed & 1 != 0 {
                pinkNoiseRunningSum -= pinkNoiseRows[i]
                let newValue = Float.random(in: -1.0...1.0)
                pinkNoiseRunningSum += newValue
                pinkNoiseRows[i] = newValue
                break
            }
            changed >>= 1
        }

        let result = (pinkNoiseRunningSum + white) / Float(pinkNoiseRows.count + 1)
        return max(-1.0, min(1.0, result))
    }

    private func generateBrownNoise() -> Float {
        let white = Float.random(in: -1.0...1.0)
        brownNoiseLastOutput += white * 0.02
        brownNoiseLastOutput *= 0.998 // Decay factor
        brownNoiseLastOutput = max(-1.0, min(1.0, brownNoiseLastOutput))
        return brownNoiseLastOutput
    }

    // MARK: - Play File-Based Sound

    func playFile(fileName: String) {
        stopAll()
        isUsingGeneratedNoise = false
        isMixMode = false

        // Support absolute paths (custom imported sounds)
        if fileName.hasPrefix("/") {
            let url = URL(fileURLWithPath: fileName)
            guard FileManager.default.fileExists(atPath: fileName) else {
                print("Custom sound file not found: \(fileName)")
                return
            }
            playFileAtURL(url)
            return
        }

        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension

        guard let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Sounds") else {
            // Try without subdirectory
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
                print("Sound file not found: \(fileName)")
                return
            }
            playFileAtURL(url)
            return
        }
        playFileAtURL(url)
    }

    private func playFileAtURL(_ url: URL) {
        do {
            let file = try AVAudioFile(forReading: url)
            audioFile = file

            let player = AVAudioPlayerNode()
            playerNode = player
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)

            try engine.start()

            scheduleLoop(player: player, file: file)
            player.play()
        } catch {
            print("File playback failed: \(error)")
        }
    }

    private func scheduleLoop(player: AVAudioPlayerNode, file: AVAudioFile) {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else { return }
        do {
            file.framePosition = 0
            try file.read(into: buffer)
            player.scheduleBuffer(buffer, at: nil, options: .loops)
        } catch {
            print("Buffer scheduling failed: \(error)")
        }
    }

    // MARK: - Mix Playback

    func playMix(components: [MixComponent]) {
        stopAll()
        isMixMode = true
        isUsingGeneratedNoise = false

        for component in components.prefix(5) {
            guard let sound = component.sound else { continue }
            mixVolumes[sound.id] = component.volume

            if sound.isGenerated {
                addGeneratedNoiseToMix(soundId: sound.id, type: sound.id, volume: component.volume)
            } else {
                addFileToMix(soundId: sound.id, fileName: sound.fileName, volume: component.volume)
            }
        }

        do {
            try engine.start()
        } catch {
            print("Mix engine start failed: \(error)")
        }

        // Start all file-based player nodes
        for (_, player) in mixPlayerNodes {
            player.play()
        }
    }

    private func addGeneratedNoiseToMix(soundId: String, type: String, volume: Float) {
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        // Initialize per-source noise state
        mixBrownNoiseState[soundId] = 0
        mixPinkNoiseState[soundId] = (rows: [Float](repeating: 0, count: 8), runningSum: 0, index: 0)

        var previousSample: Float = 0

        let source = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, bufferList -> OSStatus in
            guard let self else { return noErr }
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            let buffer = buffers[0]
            let frames = Int(frameCount)
            guard let data = buffer.mData?.assumingMemoryBound(to: Float.self) else { return noErr }

            let vol = self.mixVolumes[soundId] ?? volume

            for i in 0..<frames {
                let sample: Float
                switch type {
                case "white_noise":
                    sample = Float.random(in: -1.0...1.0)
                case "pink_noise":
                    sample = self.generateMixPinkNoise(soundId: soundId)
                case "brown_noise":
                    sample = self.generateMixBrownNoise(soundId: soundId)
                case "blue_noise":
                    let white = Float.random(in: -1.0...1.0)
                    sample = max(-1.0, min(1.0, white - previousSample))
                    previousSample = white
                default:
                    sample = 0
                }
                data[i] = sample * 0.3 * vol
            }
            return noErr
        }

        mixSourceNodes[soundId] = source
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)
    }

    private func addFileToMix(soundId: String, fileName: String, volume: Float) {
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension

        let url: URL? = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Sounds")
            ?? Bundle.main.url(forResource: name, withExtension: ext)

        guard let url else {
            print("Mix sound file not found: \(fileName)")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)
            let player = AVAudioPlayerNode()
            player.volume = volume

            mixPlayerNodes[soundId] = player
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
            scheduleLoop(player: player, file: file)
        } catch {
            print("Mix file load failed: \(error)")
        }
    }

    private func generateMixPinkNoise(soundId: String) -> Float {
        var state = mixPinkNoiseState[soundId] ?? (rows: [Float](repeating: 0, count: 8), runningSum: 0, index: 0)
        let white = Float.random(in: -1.0...1.0)
        state.index += 1

        var changed = state.index
        for i in 0..<state.rows.count {
            if changed & 1 != 0 {
                state.runningSum -= state.rows[i]
                let newValue = Float.random(in: -1.0...1.0)
                state.runningSum += newValue
                state.rows[i] = newValue
                break
            }
            changed >>= 1
        }

        let result = (state.runningSum + white) / Float(state.rows.count + 1)
        mixPinkNoiseState[soundId] = state
        return max(-1.0, min(1.0, result))
    }

    private func generateMixBrownNoise(soundId: String) -> Float {
        var last = mixBrownNoiseState[soundId] ?? 0
        let white = Float.random(in: -1.0...1.0)
        last += white * 0.02
        last *= 0.998
        last = max(-1.0, min(1.0, last))
        mixBrownNoiseState[soundId] = last
        return last
    }

    func updateComponentVolume(soundId: String, volume: Float) {
        mixVolumes[soundId] = volume
        // For file-based players, set volume directly
        mixPlayerNodes[soundId]?.volume = volume
        // For source nodes, volume is read from mixVolumes in the render callback
    }

    // MARK: - Transport Controls

    func pause() {
        if isMixMode {
            engine.pause()
        } else if isUsingGeneratedNoise {
            engine.pause()
        } else {
            playerNode?.pause()
        }
    }

    func resume() {
        if isMixMode || isUsingGeneratedNoise {
            do {
                try engine.start()
            } catch {
                print("Engine resume failed: \(error)")
            }
            if isMixMode {
                for (_, player) in mixPlayerNodes {
                    player.play()
                }
            }
        } else {
            playerNode?.play()
        }
    }

    func stopAll() {
        // Stop single playback
        playerNode?.stop()
        if let player = playerNode {
            engine.detach(player)
        }
        playerNode = nil

        if let source = sourceNode {
            engine.detach(source)
        }
        sourceNode = nil

        // Stop mix playback
        for (_, player) in mixPlayerNodes {
            player.stop()
            engine.detach(player)
        }
        mixPlayerNodes.removeAll()

        for (_, source) in mixSourceNodes {
            engine.detach(source)
        }
        mixSourceNodes.removeAll()
        mixVolumes.removeAll()
        mixBrownNoiseState.removeAll()
        mixPinkNoiseState.removeAll()

        engine.stop()
        audioFile = nil
        isUsingGeneratedNoise = false
        isMixMode = false
    }

    func setVolume(_ volume: Float) {
        engine.mainMixerNode.outputVolume = volume
    }

    var isRunning: Bool {
        engine.isRunning
    }
}
