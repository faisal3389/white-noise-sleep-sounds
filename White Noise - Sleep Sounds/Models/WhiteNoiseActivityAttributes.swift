import ActivityKit
import Foundation

struct WhiteNoiseActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var soundName: String
        var categoryIcon: String
        var categoryName: String
        var isPlaying: Bool
        var timerEndDate: Date?
        var mixSoundCount: Int?
    }
}
