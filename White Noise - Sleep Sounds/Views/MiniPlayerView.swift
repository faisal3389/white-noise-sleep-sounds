import SwiftUI

struct MiniPlayerView: View {
    @Bindable var player: AudioPlayerViewModel
    let onTap: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        if player.currentSound != nil || player.currentMix != nil {
            Button(action: {
                AnalyticsManager.shared.track(.miniPlayerTapped, properties: ["sound_name": player.displayTitle])
                onTap()
            }) {
                HStack(spacing: 10) {
                    // Thumbnail
                    thumbnailView

                    // Title + subtitle
                    VStack(alignment: .leading, spacing: 1) {
                        Text(player.displayTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(player.displaySubtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.45))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 4)

                    // EQ bars
                    if player.isPlaying {
                        miniEQAnimation
                    }

                    // Play/Pause
                    Button {
                        AnalyticsManager.shared.track(.miniPlayerPlayPause, properties: ["is_playing": player.isPlaying, "sound_name": player.displayTitle])
                        player.togglePlayPause()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.leading, 10)
                .padding(.trailing, 12)
                .padding(.vertical, 10)
                .background {
                    ZStack {
                        // Tinted glass
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)

                        // Subtle top highlight
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    }
                }
                .shadow(color: Color.black.opacity(0.35), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dragOffset = value.translation.height * 0.3
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3)) {
                            dragOffset = 0
                        }
                        if value.translation.height < -30 {
                            onTap()
                        }
                    }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Thumbnail

    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appSurface)
                .frame(width: 36, height: 36)

            if !player.displayBackgroundImage.isEmpty {
                Image(player.displayBackgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if player.isPlaying {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.appAccent.opacity(0.6), lineWidth: 1)
                    .frame(width: 36, height: 36)
            }
        }
    }

    // MARK: - Mini EQ

    private var miniEQAnimation: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                EQBar(index: i, maxHeight: 12, width: 2)
            }
        }
        .frame(width: 14, height: 14)
    }
}
