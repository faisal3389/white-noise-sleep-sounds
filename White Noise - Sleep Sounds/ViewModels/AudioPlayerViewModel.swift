import Foundation
import MediaPlayer
import WidgetKit

@Observable
class AudioPlayerViewModel {
    private let analytics = AnalyticsManager.shared

    var currentSound: Sound?
    var isPlaying: Bool = false
    var volume: Float = 0.7
    var currentIndex: Int = 0
    var isShuffleOn: Bool = false
    var loopMode: LoopMode = .off

    enum LoopMode {
        case off, one, all
    }

    // Mix playback
    var currentMix: SoundMix?
    var isMixPlaying: Bool = false
    var activeComponents: [MixComponent] = []

    private let audioEngine = AudioEngine()
    private let nowPlayingManager = NowPlayingManager()
    let liveActivityManager = LiveActivityManager()
    private(set) var soundList: [Sound] = SoundLibrary.allSounds

    init() {
        audioEngine.onInterruption = { [weak self] began in
            guard let self else { return }
            if began {
                self.pause()
            } else {
                self.resume()
            }
        }
        audioEngine.onRouteChange = { [weak self] in
            self?.pause()
        }

        nowPlayingManager.onPlay = { [weak self] in
            self?.resume()
        }
        nowPlayingManager.onPause = { [weak self] in
            self?.pause()
        }
        nowPlayingManager.onTogglePlayPause = { [weak self] in
            self?.togglePlayPause()
        }
        nowPlayingManager.onNextTrack = { [weak self] in
            self?.next()
        }
        nowPlayingManager.onPreviousTrack = { [weak self] in
            self?.previous()
        }
    }

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
        nowPlayingManager.updateNowPlayingInfo(sound: sound, isPlaying: true)
        liveActivityManager.startActivity(sound: sound, isPlaying: true, timerEndDate: nil)
        analytics.track(.soundPlayed, properties: [
            "sound_id": sound.id,
            "sound_name": sound.name,
            "category": sound.category.rawValue,
            "is_premium": sound.isPremium,
            "is_generated": sound.isGenerated
        ])
    }

    func pause() {
        audioEngine.pause()
        isPlaying = false
        if isMixPlaying {
            isMixPlaying = false
        }
        analytics.track(.soundPaused, properties: [
            "sound_name": displayTitle,
            "is_mix": currentMix != nil
        ])
        SharedPlaybackState.update(soundId: currentSound?.id ?? currentMix?.id.uuidString, soundName: displayTitle, backgroundImage: displayBackgroundImage, isPlaying: false)
        nowPlayingManager.updatePlaybackRate(isPlaying: false)
        liveActivityManager.updateActivity(isPlaying: false, timerEndDate: nil)
    }

    func resume() {
        audioEngine.resume()
        isPlaying = true
        if currentMix != nil {
            isMixPlaying = true
        }
        SharedPlaybackState.update(soundId: currentSound?.id ?? currentMix?.id.uuidString, soundName: displayTitle, backgroundImage: displayBackgroundImage, isPlaying: true)
        nowPlayingManager.updatePlaybackRate(isPlaying: true)
        liveActivityManager.updateActivity(isPlaying: true, timerEndDate: nil)
        analytics.track(.soundResumed, properties: [
            "sound_name": displayTitle,
            "is_mix": currentMix != nil
        ])
    }

    func stop() {
        analytics.track(.soundStopped, properties: [
            "sound_name": displayTitle,
            "is_mix": currentMix != nil
        ])
        audioEngine.stopAll()
        isPlaying = false
        currentSound = nil
        currentMix = nil
        isMixPlaying = false
        activeComponents = []
        SharedPlaybackState.clear()
        nowPlayingManager.clearNowPlayingInfo()
        liveActivityManager.endActivity()
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
        analytics.track(.soundNext, properties: ["shuffle": isShuffleOn, "loop_mode": "\(loopMode)"])
        if loopMode == .one, let sound = currentSound {
            play(sound: sound)
            return
        }
        if isShuffleOn {
            currentIndex = Int.random(in: 0..<soundList.count)
        } else {
            currentIndex = (currentIndex + 1) % soundList.count
        }
        play(sound: soundList[currentIndex])
    }

    func previous() {
        guard !soundList.isEmpty else { return }
        analytics.track(.soundPrevious, properties: ["shuffle": isShuffleOn, "loop_mode": "\(loopMode)"])
        if loopMode == .one, let sound = currentSound {
            play(sound: sound)
            return
        }
        if isShuffleOn {
            currentIndex = Int.random(in: 0..<soundList.count)
        } else {
            currentIndex = (currentIndex - 1 + soundList.count) % soundList.count
        }
        play(sound: soundList[currentIndex])
    }

    func toggleShuffle() {
        isShuffleOn.toggle()
        analytics.track(.shuffleToggled, properties: ["enabled": isShuffleOn])
    }

    func cycleLoopMode() {
        switch loopMode {
        case .off: loopMode = .all
        case .all: loopMode = .one
        case .one: loopMode = .off
        }
        analytics.track(.loopModeChanged, properties: ["mode": "\(loopMode)"])
    }

    func setVolume(_ newVolume: Float) {
        volume = newVolume
        audioEngine.setVolume(newVolume)
        analytics.track(.volumeChanged, properties: ["volume": newVolume])
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
        nowPlayingManager.updateNowPlayingInfo(mix: mix, isPlaying: true)
        liveActivityManager.startActivity(mix: mix, isPlaying: true, timerEndDate: nil)
        analytics.track(.mixPlayed, properties: [
            "mix_name": mix.name,
            "component_count": mix.components.count
        ])
    }

    func adjustComponentVolume(soundId: String, volume: Float) {
        analytics.track(.mixComponentVolumeChanged, properties: ["sound_id": soundId, "volume": volume])
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
        analytics.track(.mixNextPlayed, properties: ["mix_name": mixes[nextIndex].name])
        playMix(mix: mixes[nextIndex])
    }

    func previousMix(in mixes: [SoundMix]) {
        guard let current = currentMix,
              let index = mixes.firstIndex(where: { $0.id == current.id }) else { return }
        let prevIndex = (index - 1 + mixes.count) % mixes.count
        analytics.track(.mixPreviousPlayed, properties: ["mix_name": mixes[prevIndex].name])
        playMix(mix: mixes[prevIndex])
    }

    func updateLiveActivityTimer(endDate: Date?) {
        liveActivityManager.updateActivity(isPlaying: isPlaying, timerEndDate: endDate)
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
