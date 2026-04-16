import Foundation
import UIKit

@Observable
final class ReviewPromptManager {
    static let shared = ReviewPromptManager()

    private static let soundPlaysKey = "review_sound_plays_count"
    private static let promptCountKey = "review_prompt_count"
    private static let lastPromptDateKey = "review_last_prompt_date"
    private static let hasRatedKey = "review_has_rated"

    private static let firstPlayDelay: TimeInterval = 25
    private static let secondPromptDelay: TimeInterval = 24 * 60 * 60          // next day
    private static let thirdPromptDelay: TimeInterval = 3 * 24 * 60 * 60       // three days later
    private static let maxPrompts = 3
    private static let reviewURL = URL(string: "https://apps.apple.com/us/app/white-noise-sleep-sounds/id6762322017?action=write-review")!

    var shouldShowPrompt: Bool = false

    private var soundPlaysCount: Int {
        get { UserDefaults.standard.integer(forKey: Self.soundPlaysKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.soundPlaysKey) }
    }

    private var promptCount: Int {
        get { UserDefaults.standard.integer(forKey: Self.promptCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.promptCountKey) }
    }

    private var lastPromptDate: Date? {
        get { UserDefaults.standard.object(forKey: Self.lastPromptDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Self.lastPromptDateKey) }
    }

    private var hasRated: Bool {
        get { UserDefaults.standard.bool(forKey: Self.hasRatedKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.hasRatedKey) }
    }

    private var pendingWork: DispatchWorkItem?

    private init() {}

    // MARK: - Public API

    /// Call whenever a sound or mix starts playing. Schedules the prompt if eligible.
    func recordPlay() {
        soundPlaysCount += 1
        scheduleIfEligible()
    }

    /// Call when the app becomes active — re-evaluates if a day has passed.
    func evaluateOnAppActive() {
        scheduleIfEligible()
    }

    /// User tapped "Rate 5 Stars" — open App Store review page and stop further prompts.
    func openAppStoreReview() {
        hasRated = true
        shouldShowPrompt = false
        UIApplication.shared.open(Self.reviewURL)
        AnalyticsManager.shared.track(.rateAppTapped, properties: ["source": "review_prompt"])
    }

    /// User dismissed the sheet without rating. Move to next slot on the schedule.
    func dismissPrompt() {
        promptCount += 1
        lastPromptDate = Date()
        shouldShowPrompt = false
        AnalyticsManager.shared.track(.ratePromptDismissed, properties: ["prompt_index": promptCount])
    }

    /// Called when the sheet actually appears — counts as a shown prompt.
    func markPromptShown() {
        AnalyticsManager.shared.track(.ratePromptShown, properties: ["prompt_index": promptCount + 1])
    }

    // MARK: - Scheduling

    private func scheduleIfEligible() {
        guard !hasRated, promptCount < Self.maxPrompts, !shouldShowPrompt else { return }

        let delay: TimeInterval
        switch promptCount {
        case 0:
            guard soundPlaysCount >= 1 else { return }
            delay = Self.firstPlayDelay
        case 1:
            guard let last = lastPromptDate, Date().timeIntervalSince(last) >= Self.secondPromptDelay else { return }
            delay = Self.firstPlayDelay
        case 2:
            guard let last = lastPromptDate, Date().timeIntervalSince(last) >= Self.thirdPromptDelay else { return }
            delay = Self.firstPlayDelay
        default:
            return
        }

        pendingWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.shouldShowPrompt = true
        }
        pendingWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }
}
