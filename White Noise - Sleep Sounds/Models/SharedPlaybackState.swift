import Foundation
import WidgetKit

/// Manages shared playback state between the main app and widgets via UserDefaults.
/// When an App Group is configured, change `suiteName` to your App Group identifier.
struct SharedPlaybackState {
    // Change this to your App Group ID when you set one up (e.g., "group.com.zalgo.whitenoisesleepsounds")
    private static let defaults = UserDefaults.standard

    static var currentSoundId: String? {
        get { defaults.string(forKey: "widget_currentSoundId") }
        set { defaults.set(newValue, forKey: "widget_currentSoundId") }
    }

    static var currentSoundName: String? {
        get { defaults.string(forKey: "widget_currentSoundName") }
        set { defaults.set(newValue, forKey: "widget_currentSoundName") }
    }

    static var isPlaying: Bool {
        get { defaults.bool(forKey: "widget_isPlaying") }
        set { defaults.set(newValue, forKey: "widget_isPlaying") }
    }

    static func update(soundId: String?, soundName: String?, isPlaying: Bool) {
        self.currentSoundId = soundId
        self.currentSoundName = soundName
        self.isPlaying = isPlaying
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func clear() {
        currentSoundId = nil
        currentSoundName = nil
        isPlaying = false
        WidgetCenter.shared.reloadAllTimelines()
    }
}
