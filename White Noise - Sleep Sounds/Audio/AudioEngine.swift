import AVFoundation
import Foundation
import MediaPlayer

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

    // Bumped on every stopAll() so in-flight buffer-completion callbacks
    // (running on the audio render thread) can detect that they're now stale
    // and skip the recursive scheduleBuffer — which would otherwise crash by
    // calling into a player node that's already been detached from the engine.
    private var playbackEpoch: Int = 0

    var onInterruption: ((Bool) -> Void)?  // true = began, false = ended (should resume)
    var onRouteChange: (() -> Void)?       // headphones disconnected

    init() {
        configureAudioSession()
        setupNotifications()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback)
            try session.setActive(true)
        } catch {
            print("AudioSession setup failed: \(error)")
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        // iOS delivers AVAudioSession notifications on its own queue, not
        // necessarily main. Hop to main before invoking the callback —
        // the ViewModel that consumes it touches @Observable state.
        let shouldResume: Bool
        if type == .ended,
           let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
            shouldResume = AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume)
        } else {
            shouldResume = false
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch type {
            case .began:
                self.onInterruption?(true)
            case .ended where shouldResume:
                self.onInterruption?(false)
            default:
                break
            }
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        if reason == .oldDeviceUnavailable {
            DispatchQueue.main.async { [weak self] in
                self?.onRouteChange?()
            }
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
        guard let buffer = makeLoopBuffer(from: file) else { return }
        // Queue two buffers up front and keep re-queueing on completion. This
        // is more reliable than `.loops` for overnight playback — we've seen
        // `.loops` stop after the first pass on some iOS builds, leaving the
        // user in silence. Completion-based rescheduling guarantees there is
        // always a buffer ready to play.
        let epoch = playbackEpoch
        scheduleNextLoop(player: player, buffer: buffer, epoch: epoch)
        scheduleNextLoop(player: player, buffer: buffer, epoch: epoch)
    }

    private func scheduleNextLoop(player: AVAudioPlayerNode, buffer: AVAudioPCMBuffer, epoch: Int) {
        player.scheduleBuffer(
            buffer,
            at: nil,
            options: [],
            completionCallbackType: .dataConsumed
        ) { [weak self, weak player] _ in
            guard let self, let player else { return }
            // Bail if a stopAll() has happened since this buffer was scheduled.
            // The epoch check is the load-bearing guard against the race where
            // the player node has been (or is about to be) detached from the
            // engine — calling scheduleBuffer on a detached node throws an
            // uncatchable Obj-C exception.
            guard self.playbackEpoch == epoch else { return }
            // Also bail if a new sound has replaced this player while the
            // engine kept running.
            let stillActive = self.playerNode === player
                || self.mixPlayerNodes.values.contains(where: { $0 === player })
            guard stillActive else { return }
            self.scheduleNextLoop(player: player, buffer: buffer, epoch: epoch)
        }
    }

    // Builds a seamlessly loopable PCM buffer from a file.
    //
    // Source clips have fade-in/fade-out baked in — typically 1–5 seconds on
    // each side. Looping the raw buffer makes that fade audible every cycle,
    // which users correctly describe as "the sound stops and restarts."
    //
    // Strategy:
    // 1. Read the full PCM data.
    // 2. Scan per-window RMS energy to find where steady-state audio begins
    //    and ends (any region below 50% of peak RMS is treated as fade/silence).
    // 3. Extract that steady-state middle section.
    // 4. Apply a long equal-power crossfade across the loop seam so the wrap
    //    point is inaudible even if the middle's start and end don't match.
    private func makeLoopBuffer(from file: AVAudioFile) -> AVAudioPCMBuffer? {
        let sampleRate = file.processingFormat.sampleRate
        let fullFrames = AVAudioFrameCount(file.length)
        guard fullFrames > 0,
              let full = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: fullFrames),
              full.floatChannelData != nil else {
            return nil
        }
        do {
            file.framePosition = 0
            try file.read(into: full)
        } catch {
            print("Buffer read failed: \(error)")
            return nil
        }

        let totalSeconds = Double(full.frameLength) / sampleRate
        guard totalSeconds >= 2.0 else {
            // Too short to do anything sensible — play as-is.
            return full
        }

        let range = detectSteadyStateRange(buffer: full)
        let startFrame = range.start
        let endFrame = range.end
        let contentFrames = AVAudioFrameCount(endFrame - startFrame)

        guard contentFrames > AVAudioFrameCount(sampleRate * 1.0),
              let core = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: contentFrames),
              let srcChannels = full.floatChannelData,
              let dstChannels = core.floatChannelData else {
            return full
        }
        core.frameLength = contentFrames

        let channelCount = Int(file.processingFormat.channelCount)
        let byteCount = Int(contentFrames) * MemoryLayout<Float>.size
        for ch in 0..<channelCount {
            memcpy(dstChannels[ch], srcChannels[ch].advanced(by: startFrame), byteCount)
        }

        // Crossfade the tail with the head so the seam is inaudible. Use up
        // to 1s or a quarter of the clip, whichever is smaller.
        let maxCrossfadeSec = min(1.0, Double(contentFrames) / sampleRate / 4.0)
        let xfade = Int(maxCrossfadeSec * sampleRate)
        guard xfade > 64 else { return core }

        let total = Int(contentFrames)
        for ch in 0..<channelCount {
            let ptr = dstChannels[ch]
            for i in 0..<xfade {
                let t = Float(i) / Float(xfade)
                let outGain = cosf(t * .pi / 2)
                let inGain = sinf(t * .pi / 2)
                let tailIdx = total - xfade + i
                ptr[tailIdx] = ptr[tailIdx] * outGain + ptr[i] * inGain
            }
        }

        // The head section (first `xfade` frames) was blended into the tail,
        // so drop it — the resulting buffer's end naturally leads into its
        // start when `.loops` (or manual re-scheduling) wraps around.
        let newLen = contentFrames - AVAudioFrameCount(xfade)
        guard let shifted = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: newLen) else {
            return core
        }
        shifted.frameLength = newLen
        let shiftByteCount = Int(newLen) * MemoryLayout<Float>.size
        for ch in 0..<channelCount {
            guard let dst = shifted.floatChannelData?[ch] else { continue }
            memcpy(dst, dstChannels[ch].advanced(by: xfade), shiftByteCount)
        }
        return shifted
    }

    // Scans RMS energy per window to locate the "content" region of a clip —
    // i.e., where the audio is at steady amplitude, skipping any fade-in/out
    // or silence padding at the edges.
    private func detectSteadyStateRange(buffer: AVAudioPCMBuffer) -> (start: Int, end: Int) {
        let total = Int(buffer.frameLength)
        let fallback = (start: 0, end: total)
        guard let channels = buffer.floatChannelData else { return fallback }

        let channelCount = Int(buffer.format.channelCount)
        let sampleRate = buffer.format.sampleRate
        let windowSize = max(1, Int(sampleRate * 0.05)) // 50 ms windows
        guard total >= windowSize * 4 else { return fallback }

        var rms: [Float] = []
        rms.reserveCapacity(total / windowSize + 1)
        var i = 0
        while i + windowSize <= total {
            var sumSq: Float = 0
            for ch in 0..<channelCount {
                let ptr = channels[ch]
                for j in 0..<windowSize {
                    let s = ptr[i + j]
                    sumSq += s * s
                }
            }
            rms.append(sqrtf(sumSq / Float(windowSize * channelCount)))
            i += windowSize
        }

        guard let peak = rms.max(), peak > 0 else { return fallback }
        let threshold = peak * 0.5

        var startWindow = 0
        for (idx, v) in rms.enumerated() where v >= threshold {
            startWindow = idx
            break
        }
        var endWindow = rms.count - 1
        for idx in stride(from: rms.count - 1, through: 0, by: -1) where rms[idx] >= threshold {
            endWindow = idx
            break
        }

        let startFrame = startWindow * windowSize
        let endFrame = min(total, (endWindow + 1) * windowSize)

        // Require at least 1 second of content — otherwise fall back to the
        // full buffer rather than return a uselessly short loop.
        guard endFrame - startFrame >= Int(sampleRate) else { return fallback }
        return (startFrame, endFrame)
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
        // Fast path: a normal pause→play (no interruption happened). The
        // engine is still running; just unpause the player nodes. Stays on
        // the main thread, returns immediately, UI stays snappy.
        if engine.isRunning {
            if isMixMode {
                for (_, player) in mixPlayerNodes { player.play() }
            } else if !isUsingGeneratedNoise {
                playerNode?.play()
            }
            return
        }

        // Slow path: an interruption (alarm, call, another audio app)
        // deactivated our session and stopped the engine. Reactivating the
        // session and restarting the engine can BLOCK for hundreds of ms
        // while iOS renegotiates audio resources — running it on the main
        // thread freezes every button in the UI. Do it on a utility queue.
        let epoch = playbackEpoch
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("AudioSession reactivate failed: \(error)")
            }
            // If a stopAll() ran while we were waiting on setActive(true),
            // the engine has been torn down — don't try to start it back up.
            guard self.playbackEpoch == epoch else { return }
            do {
                try self.engine.start()
            } catch {
                print("Engine resume failed: \(error)")
                return
            }
            guard self.playbackEpoch == epoch else { return }
            if self.isMixMode {
                for (_, player) in self.mixPlayerNodes { player.play() }
            } else if !self.isUsingGeneratedNoise {
                self.playerNode?.play()
            }
            // Generated-noise mode renders straight from the source node —
            // once the engine is running, audio flows.
        }
    }

    func stopAll() {
        // Invalidate any in-flight loop completions BEFORE we detach nodes —
        // their guard checks read this value and bail out if it changed.
        playbackEpoch &+= 1

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
