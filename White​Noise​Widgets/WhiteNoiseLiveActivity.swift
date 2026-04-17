import WidgetKit
import SwiftUI
import ActivityKit
import AppIntents

// MARK: - In-place toggle intent
// LiveActivityIntent runs in the widget process without opening the app.
// We signal the main app (alive in background because audio is playing) via a
// Darwin notification; the main app's AudioPlayerViewModel listens and toggles.
struct TogglePlaybackLiveIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle Playback"
    static var description = IntentDescription("Play or pause the current sound from the Live Activity.")

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.zalgo.whitenoise")
        defaults?.set(Date().timeIntervalSince1970, forKey: "playback_toggle_requested_at")

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.zalgo.whitenoise.toggle" as CFString),
            nil,
            nil,
            true
        )

        return .result()
    }
}

struct WhiteNoiseLiveActivity: Widget {
    // App theme tokens (mirror Color+Hex.swift; widget target doesn't link that file)
    private static let accent           = Color(red: 0x7F / 255, green: 0xE6 / 255, blue: 0xDB / 255) // #7FE6DB
    private static let background       = Color(red: 0x0C / 255, green: 0x0E / 255, blue: 0x12 / 255) // #0C0E12
    private static let surfaceContainer = Color(red: 0x17 / 255, green: 0x1A / 255, blue: 0x1F / 255) // #171A1F
    private static let surfaceHigh      = Color(red: 0x1D / 255, green: 0x20 / 255, blue: 0x25 / 255) // #1D2025
    private static let onSurfaceMuted   = Color.white.opacity(0.55)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WhiteNoiseActivityAttributes.self) { context in
            lockScreenBanner(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    iconTile(iconName: context.state.categoryIcon, size: 34, cornerRadius: 9)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let endDate = context.state.timerEndDate {
                        timerPill(endDate: endDate)
                            .padding(.trailing, 4)
                    } else {
                        EmptyView()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.soundName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            subtitleLine(context: context)
                        }

                        Spacer(minLength: 8)

                        playPauseIndicator(isPlaying: context.state.isPlaying, size: 40)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(Self.accent)
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                    .foregroundStyle(Self.accent)
            } minimal: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(Self.accent)
            }
            .keylineTint(Self.accent)
        }
    }

    // MARK: - Lock Screen

    @ViewBuilder
    private func lockScreenBanner(context: ActivityViewContext<WhiteNoiseActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            iconTile(iconName: context.state.categoryIcon, size: 44, cornerRadius: 11)

            VStack(alignment: .leading, spacing: 3) {
                Text(context.state.soundName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                subtitleLine(context: context)
            }

            Spacer(minLength: 8)

            if let endDate = context.state.timerEndDate {
                timerPill(endDate: endDate)
            }

            playPauseButton(isPlaying: context.state.isPlaying, size: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            LinearGradient(
                colors: [Self.surfaceHigh, Self.surfaceContainer],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - Shared Components

    @ViewBuilder
    private func iconTile(iconName: String, size: CGFloat, cornerRadius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Self.accent.opacity(0.16))

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Self.accent.opacity(0.25), lineWidth: 0.5)

            Image(systemName: iconName)
                .font(.system(size: size * 0.48, weight: .semibold))
                .foregroundStyle(Self.accent)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func subtitleLine(context: ActivityViewContext<WhiteNoiseActivityAttributes>) -> some View {
        HStack(spacing: 6) {
            Text(context.state.categoryName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Self.onSurfaceMuted)
                .lineLimit(1)

            if let count = context.state.mixSoundCount, count > 0 {
                Circle()
                    .fill(Self.onSurfaceMuted)
                    .frame(width: 2, height: 2)

                Text("\(count) sounds")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Self.onSurfaceMuted)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func timerPill(endDate: Date) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 10, weight: .semibold))

            Text(endDate, style: .timer)
                .font(.system(size: 12, weight: .semibold).monospacedDigit())
        }
        .foregroundStyle(Self.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Self.accent.opacity(0.14), in: Capsule())
        .overlay(Capsule().strokeBorder(Self.accent.opacity(0.25), lineWidth: 0.5))
    }

    // Interactive version — used on Lock Screen banner where there is no expand gesture to collide with.
    // Uses LiveActivityIntent so the toggle runs in-place without opening the app.
    @ViewBuilder
    private func playPauseButton(isPlaying: Bool, size: CGFloat) -> some View {
        Button(intent: TogglePlaybackLiveIntent()) {
            playPauseIndicator(isPlaying: isPlaying, size: size)
        }
        .buttonStyle(.plain)
    }

    // Static visual — used in Dynamic Island expanded region. Interactive Links conflict with the
    // tap-and-hold-to-expand gesture: releasing after expand lands on the Link and fires toggle.
    @ViewBuilder
    private func playPauseIndicator(isPlaying: Bool, size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Self.accent)

            Circle()
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)

            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(Self.background)
                .offset(x: isPlaying ? 0 : size * 0.04)
        }
        .frame(width: size, height: size)
        .shadow(color: Self.accent.opacity(0.35), radius: 6, x: 0, y: 2)
    }
}
