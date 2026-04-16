import Foundation
import WidgetKit

/// Manages shared playback state between the main app and widgets via App Group UserDefaults.
struct SharedPlaybackState {
    static let appGroupId = "group.com.zalgo.whitenoise"
    private static let defaults = UserDefaults(suiteName: appGroupId) ?? .standard

    static var currentSoundId: String? {
        get { defaults.string(forKey: "widget_currentSoundId") }
        set { defaults.set(newValue, forKey: "widget_currentSoundId") }
    }

    static var currentSoundName: String? {
        get { defaults.string(forKey: "widget_currentSoundName") }
        set { defaults.set(newValue, forKey: "widget_currentSoundName") }
    }

    static var currentBackgroundImage: String? {
        get { defaults.string(forKey: "widget_currentBackgroundImage") }
        set { defaults.set(newValue, forKey: "widget_currentBackgroundImage") }
    }

    static var isPlaying: Bool {
        get { defaults.bool(forKey: "widget_isPlaying") }
        set { defaults.set(newValue, forKey: "widget_isPlaying") }
    }

    /// IDs of the user's top 3 favorite sounds for quick-play widget buttons
    static var favoriteSoundIds: [String] {
        get { defaults.stringArray(forKey: "widget_favoriteSoundIds") ?? [] }
        set { defaults.set(newValue, forKey: "widget_favoriteSoundIds") }
    }

    // Persists across stop/clear so widget always has a background
    static var lastPlayedSoundId: String? {
        get { defaults.string(forKey: "widget_lastPlayedSoundId") }
        set { defaults.set(newValue, forKey: "widget_lastPlayedSoundId") }
    }

    static var lastPlayedBackgroundImage: String? {
        get { defaults.string(forKey: "widget_lastPlayedBackgroundImage") }
        set { defaults.set(newValue, forKey: "widget_lastPlayedBackgroundImage") }
    }

    static func update(soundId: String?, soundName: String?, backgroundImage: String? = nil, isPlaying: Bool) {
        self.currentSoundId = soundId
        self.currentSoundName = soundName
        self.currentBackgroundImage = backgroundImage
        self.isPlaying = isPlaying
        // Persist last played info for widget background when playback stops
        if let soundId = soundId {
            self.lastPlayedSoundId = soundId
        }
        if let backgroundImage = backgroundImage {
            self.lastPlayedBackgroundImage = backgroundImage
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func updateFavorites(_ ids: [String]) {
        favoriteSoundIds = Array(ids.prefix(3))
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func clear() {
        currentSoundId = nil
        currentSoundName = nil
        currentBackgroundImage = nil
        isPlaying = false
        WidgetCenter.shared.reloadAllTimelines()
    }
}
