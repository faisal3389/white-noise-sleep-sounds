import ActivityKit
import Foundation

@Observable
class LiveActivityManager {
    private var currentActivity: Activity<WhiteNoiseActivityAttributes>?

    func startActivity(sound: Sound, isPlaying: Bool, timerEndDate: Date?) {
        guard UserDefaults.standard.bool(forKey: "liveActivitiesEnabled") else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // End any existing activity first
        endActivity()

        let state = WhiteNoiseActivityAttributes.ContentState(
            soundName: sound.name,
            categoryIcon: sound.category.iconName,
            categoryName: sound.category.rawValue,
            isPlaying: isPlaying,
            timerEndDate: timerEndDate,
            mixSoundCount: nil
        )

        let content = ActivityContent(state: state, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: WhiteNoiseActivityAttributes(),
                content: content,
                pushType: nil
            )
            AnalyticsManager.shared.track(.liveActivityStarted, properties: ["content_type": "sound", "sound_name": sound.name])
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func startActivity(mix: SoundMix, isPlaying: Bool, timerEndDate: Date?) {
        guard UserDefaults.standard.bool(forKey: "liveActivitiesEnabled") else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        endActivity()

        let dominantCategory = mix.components.first?.sound?.category
        let state = WhiteNoiseActivityAttributes.ContentState(
            soundName: mix.name,
            categoryIcon: dominantCategory?.iconName ?? "square.stack.3d.up.fill",
            categoryName: dominantCategory?.rawValue ?? "Custom Mix",
            isPlaying: isPlaying,
            timerEndDate: timerEndDate,
            mixSoundCount: mix.components.count
        )

        let content = ActivityContent(state: state, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: WhiteNoiseActivityAttributes(),
                content: content,
                pushType: nil
            )
            AnalyticsManager.shared.track(.liveActivityStarted, properties: ["content_type": "mix", "mix_name": mix.name, "component_count": mix.components.count])
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateActivity(isPlaying: Bool, timerEndDate: Date?) {
        guard let activity = currentActivity else { return }

        var updatedState = activity.content.state
        updatedState.isPlaying = isPlaying
        updatedState.timerEndDate = timerEndDate

        let content = ActivityContent(state: updatedState, staleDate: nil)

        Task {
            await activity.update(content)
        }
    }

    func endActivity() {
        guard let activity = currentActivity else { return }
        AnalyticsManager.shared.track(.liveActivityEnded)
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }

    func onSettingsChanged(enabled: Bool) {
        if !enabled {
            endActivity()
        }
    }
}
