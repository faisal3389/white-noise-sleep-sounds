import SwiftUI

struct SleepClockView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var timerManager: TimerManager

    @State private var showInfo = false
    @State private var dimmed = false
    @State private var lastInteraction = Date()
    @State private var previousBrightness: CGFloat = 0.5

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                VStack(spacing: 8) {
                    Text(timeString(from: context.date))
                        .font(.system(size: 72, weight: .thin, design: .monospaced))
                        .foregroundStyle(.white.opacity(dimmed ? 0.3 : 0.8))

                    Text(dateString(from: context.date))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(dimmed ? 0.15 : 0.4))
                }
            }

            // Info overlay (shown on tap)
            if showInfo {
                VStack(spacing: 8) {
                    Spacer()

                    if player.isPlaying {
                        Text(player.displayTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    if timerManager.isTimerActive {
                        Text("Sleep timer: \(timerManager.remainingFormatted)")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appAccent.opacity(0.8))
                    }

                    Spacer().frame(height: 80)
                }
                .transition(.opacity)
            }
        }
        .statusBarHidden()
        .onAppear {
            #if os(iOS)
            previousBrightness = UIScreen.main.brightness
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
            scheduleDim()
        }
        .onDisappear {
            #if os(iOS)
            UIScreen.main.brightness = previousBrightness
            UIApplication.shared.isIdleTimerDisabled = false
            #endif
        }
        .onTapGesture {
            handleTap()
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
    }

    private func handleTap() {
        lastInteraction = Date()
        restoreBrightness()

        withAnimation(.easeInOut(duration: 0.3)) {
            showInfo = true
        }

        // Hide info after 2 seconds
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.5)) {
                showInfo = false
            }
        }

        scheduleDim()
    }

    private func scheduleDim() {
        Task {
            try? await Task.sleep(for: .seconds(5))
            guard Date().timeIntervalSince(lastInteraction) >= 4.5 else { return }
            dimScreen()
        }
    }

    private func dimScreen() {
        dimmed = true
        #if os(iOS)
        UIScreen.main.brightness = 0.1
        #endif
    }

    private func restoreBrightness() {
        dimmed = false
        #if os(iOS)
        UIScreen.main.brightness = previousBrightness
        #endif
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}
