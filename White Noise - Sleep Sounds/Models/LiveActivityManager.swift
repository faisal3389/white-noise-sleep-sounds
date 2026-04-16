import ActivityKit
import Foundation

@Observable
class LiveActivityManager {
    private var currentActivity: Activity<WhiteNoiseActivityAttributes>?
    private var lastContext: Context?

    private enum Context {
        case sound(Sound)
        case mix(SoundMix)
    }

    private var isEnabledInSettings: Bool {
        if UserDefaults.standard.object(forKey: "liveActivitiesEnabled") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "liveActivitiesEnabled")
    }

    func startActivity(sound: Sound, isPlaying: Bool, timerEndDate: Date?) {
        lastContext = .sound(sound)

        guard isEnabledInSettings else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activity: not authorized (check Settings → Face ID & Passcode → Live Activities, and per-app toggle)")
            return
        }

        endActivity(track: false)

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
        lastContext = .mix(mix)

        guard isEnabledInSettings else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activity: not authorized (check Settings → Face ID & Passcode → Live Activities, and per-app toggle)")
            return
        }

        endActivity(track: false)

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
        // If settings/state disabled us earlier but we have context and are now playing, start fresh.
        if currentActivity == nil, isPlaying, let ctx = lastContext, isEnabledInSettings {
            switch ctx {
            case .sound(let sound): startActivity(sound: sound, isPlaying: isPlaying, timerEndDate: timerEndDate)
            case .mix(let mix): startActivity(mix: mix, isPlaying: isPlaying, timerEndDate: timerEndDate)
            }
            return
        }

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
        endActivity(track: true)
        lastContext = nil
    }

    private func endActivity(track: Bool) {
        guard let activity = currentActivity else { return }
        if track {
            AnalyticsManager.shared.track(.liveActivityEnded)
        }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }

    func onSettingsChanged(enabled: Bool, isPlaying: Bool, timerEndDate: Date?) {
        if enabled {
            if currentActivity == nil, isPlaying, let ctx = lastContext {
                switch ctx {
                case .sound(let sound): startActivity(sound: sound, isPlaying: isPlaying, timerEndDate: timerEndDate)
                case .mix(let mix): startActivity(mix: mix, isPlaying: isPlaying, timerEndDate: timerEndDate)
                }
            }
        } else {
            endActivity(track: true)
        }
    }
}
