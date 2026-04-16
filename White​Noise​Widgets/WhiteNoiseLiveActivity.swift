import WidgetKit
import SwiftUI
import ActivityKit

struct WhiteNoiseLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WhiteNoiseActivityAttributes.self) { context in
            // Lock Screen banner
            HStack(spacing: 12) {
                Image(systemName: context.state.categoryIcon)
                    .font(.title2)
                    .foregroundStyle(.cyan)

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.soundName)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(context.state.categoryName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                if let endDate = context.state.timerEndDate {
                    Text(endDate, style: .timer)
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(.cyan)
                }

                Image(systemName: context.state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.cyan)
            }
            .padding()
            .background(Color(red: 0.05, green: 0.06, blue: 0.1))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.categoryIcon)
                        .foregroundStyle(.cyan)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.soundName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let endDate = context.state.timerEndDate {
                        Text(endDate, style: .timer)
                            .monospacedDigit()
                            .foregroundStyle(.cyan)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(.cyan)
            } compactTrailing: {
                if context.state.isPlaying {
                    Image(systemName: "waveform")
                        .foregroundStyle(.cyan)
                }
            } minimal: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(.cyan)
            }
        }
    }
}
