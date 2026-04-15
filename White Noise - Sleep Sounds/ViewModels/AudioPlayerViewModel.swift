import Foundation
import WidgetKit

@Observable
class AudioPlayerViewModel {
    var currentSound: Sound?
    var isPlaying: Bool = false
    var volume: Float = 0.7
    var currentIndex: Int = 0

    // Mix playback
    var currentMix: SoundMix?
    var isMixPlaying: Bool = false
    var activeComponents: [MixComponent] = []

    private let audioEngine = AudioEngine()
    private(set) var soundList: [Sound] = SoundLibrary.allSounds

    // MARK: - Single Sound Playback

    func play(sound: Sound) {
        // Stop any active mix
        currentMix = nil
        isMixPlaying = false
        activeComponents = []

        currentSound = sound
        if let index = soundList.firstIndex(where: { $0.id == sound.id }) {
            currentIndex = index
        }

        if sound.isGenerated {
            audioEngine.playGeneratedNoise(type: sound.id)
        } else {
            audioEngine.playFile(fileName: sound.fileName)
        }

        audioEngine.setVolume(volume)
        isPlaying = true
        SharedPlaybackState.update(soundId: sound.id, soundName: sound.name, backgroundImage: sound.backgroundImage, isPlaying: true)
    }

    func pause() {
        audioEngine.pause()
        isPlaying = false
        if isMixPlaying {
            isMixPlaying = false
        }
        SharedPlaybackState.update(soundId: currentSound?.id ?? currentMix?.id.uuidString, soundName: displayTitle, backgroundImage: displayBackgroundImage, isPlaying: false)
    }

    func resume() {
        audioEngine.resume()
        isPlaying = true
        if currentMix != nil {
            isMixPlaying = true
        }
        SharedPlaybackState.update(soundId: currentSound?.id ?? currentMix?.id.uuidString, soundName: displayTitle, backgroundImage: displayBackgroundImage, isPlaying: true)
    }

    func stop() {
        audioEngine.stopAll()
        isPlaying = false
        currentSound = nil
        currentMix = nil
        isMixPlaying = false
        activeComponents = []
        SharedPlaybackState.clear()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else if currentSound != nil || currentMix != nil {
            resume()
        }
    }

    func next() {
        guard !soundList.isEmpty else { return }
        currentIndex = (currentIndex + 1) % soundList.count
        play(sound: soundList[currentIndex])
    }

    func previous() {
        guard !soundList.isEmpty else { return }
        currentIndex = (currentIndex - 1 + soundList.count) % soundList.count
        play(sound: soundList[currentIndex])
    }

    func setVolume(_ newVolume: Float) {
        volume = newVolume
        audioEngine.setVolume(newVolume)
    }

    // MARK: - Mix Playback

    func playMix(mix: SoundMix) {
        // Stop any single sound
        currentSound = nil

        currentMix = mix
        activeComponents = mix.components
        isMixPlaying = true
        isPlaying = true

        audioEngine.playMix(components: mix.components)
        audioEngine.setVolume(volume)
        SharedPlaybackState.update(soundId: mix.id.uuidString, soundName: mix.name, backgroundImage: mix.backgroundImage, isPlaying: true)
    }

    func adjustComponentVolume(soundId: String, volume: Float) {
        if let index = activeComponents.firstIndex(where: { $0.soundId == soundId }) {
            activeComponents[index].volume = volume
        }
        audioEngine.updateComponentVolume(soundId: soundId, volume: volume)
    }

    // Navigate between saved mixes
    func nextMix(in mixes: [SoundMix]) {
        guard let current = currentMix,
              let index = mixes.firstIndex(where: { $0.id == current.id }) else { return }
        let nextIndex = (index + 1) % mixes.count
        playMix(mix: mixes[nextIndex])
    }

    func previousMix(in mixes: [SoundMix]) {
        guard let current = currentMix,
              let index = mixes.firstIndex(where: { $0.id == current.id }) else { return }
        let prevIndex = (index - 1 + mixes.count) % mixes.count
        playMix(mix: mixes[prevIndex])
    }

    // Convenience for display
    var displayTitle: String {
        if let mix = currentMix {
            return mix.name
        }
        return currentSound?.name ?? ""
    }

    var displaySubtitle: String {
        if let mix = currentMix {
            return mix.componentNames
        }
        return currentSound?.category.rawValue ?? ""
    }

    var displayBackgroundImage: String {
        if let mix = currentMix {
            return mix.backgroundImage
        }
        return currentSound?.backgroundImage ?? ""
    }
}
