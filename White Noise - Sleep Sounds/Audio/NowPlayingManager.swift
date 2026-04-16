import Foundation
import MediaPlayer

class NowPlayingManager {
    private var currentSound: Sound?
    private var currentMix: SoundMix?

    var onPlay: (() -> Void)?
    var onPause: (() -> Void)?
    var onTogglePlayPause: (() -> Void)?
    var onNextTrack: (() -> Void)?
    var onPreviousTrack: (() -> Void)?

    init() {
        setupRemoteCommandCenter()
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.onPlay?()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.onPause?()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.onTogglePlayPause?()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.onNextTrack?()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.onPreviousTrack?()
            return .success
        }
    }

    func updateNowPlayingInfo(sound: Sound, isPlaying: Bool) {
        currentSound = sound
        currentMix = nil

        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = sound.name
        info[MPMediaItemPropertyArtist] = "White Noise"
        info[MPMediaItemPropertyAlbumTitle] = sound.category.rawValue

        if let image = UIImage(named: sound.backgroundImage) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func updateNowPlayingInfo(mix: SoundMix, isPlaying: Bool) {
        currentSound = nil
        currentMix = mix

        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = mix.name
        info[MPMediaItemPropertyArtist] = "White Noise"
        info[MPMediaItemPropertyAlbumTitle] = "Custom Mix"

        let bgImage = mix.backgroundImage
        if let image = UIImage(named: bgImage) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func updatePlaybackRate(isPlaying: Bool) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        currentSound = nil
        currentMix = nil
    }
}
