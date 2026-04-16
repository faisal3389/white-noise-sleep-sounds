import Foundation

@Observable
class SettingsManager {
    private static let fadeDurationKey = "fade_duration"
    private static let liveActivitiesKey = "liveActivitiesEnabled"

    var fadeDuration: Double {
        didSet {
            UserDefaults.standard.set(fadeDuration, forKey: Self.fadeDurationKey)
        }
    }

    var liveActivitiesEnabled: Bool {
        didSet {
            UserDefaults.standard.set(liveActivitiesEnabled, forKey: Self.liveActivitiesKey)
        }
    }

    init() {
        let saved = UserDefaults.standard.double(forKey: Self.fadeDurationKey)
        self.fadeDuration = saved > 0 ? saved : 0

        // Default to true if not previously set
        if UserDefaults.standard.object(forKey: Self.liveActivitiesKey) == nil {
            UserDefaults.standard.set(true, forKey: Self.liveActivitiesKey)
        }
        self.liveActivitiesEnabled = UserDefaults.standard.bool(forKey: Self.liveActivitiesKey)
    }
}
