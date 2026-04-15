import Foundation

@Observable
class SettingsManager {
    private static let fadeDurationKey = "fade_duration"

    var fadeDuration: Double {
        didSet {
            UserDefaults.standard.set(fadeDuration, forKey: Self.fadeDurationKey)
        }
    }

    init() {
        let saved = UserDefaults.standard.double(forKey: Self.fadeDurationKey)
        self.fadeDuration = saved > 0 ? saved : 0
    }
}
