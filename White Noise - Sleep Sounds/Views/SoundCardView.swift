import SwiftUI

enum SoundCardStyle {
    case portrait    // Tall card for grids
    case landscape   // Wide card for horizontal scrolls
    case hero        // Large featured card
}

struct SoundCardView: View {
    let sound: Sound
    let style: SoundCardStyle
    let isFavorite: Bool
    let isPlaying: Bool
    let isLocked: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void

    @State private var isPressed = false

    private var cornerRadius: CGFloat {
        switch style {
        case .portrait: return DS.Radius.xl
        case .landscape: return DS.Radius.lg
        case .hero: return DS.Radius.xl
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Background layer
                Color.appSurface

                // Background image
                Image(sound.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

                // Gradient overlay
                LinearGradient(
                    colors: [
                        Color.black.opacity(style == .landscape ? 0.3 : 0.0),
                        Color.black.opacity(style == .hero ? 0.85 : 0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Locked overlay
                if isLocked {
                    Color.black.opacity(0.4)
                }

                // Content overlay
                cardContent

                // Playing glow effect (no stroke borders per DESIGN.md "No-Line" rule)
                if isPlaying {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.appAccent.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.clear)
                                .shadow(color: Color.appAccent.opacity(0.25), radius: 12)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        )
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(CardPressStyle())
    }

    @ViewBuilder
    private var cardContent: some View {
        switch style {
        case .hero:
            heroContent
        case .portrait:
            portraitContent
        case .landscape:
            landscapeContent
        }
    }

    private var heroContent: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                // Category pill
                Text(sound.category.rawValue.uppercased())
                    .font(DS.Typography.pill)
                    .tracking(1.5)
                    .foregroundStyle(Color.appAccent)
                    .padding(.horizontal, DS.Spacing.sm)
                    .padding(.vertical, 3)
                    .background(Color.appAccent.opacity(0.15))
                    .clipShape(Capsule())

                Text(sound.name)
                    .font(DS.Typography.headlineLg)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(sound.category.rawValue)
                    .font(DS.Typography.labelSm)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // Play indicator or lock
            if isLocked {
                lockBadge
            } else if isPlaying {
                playingIndicator
            } else {
                playButton(size: 40)
            }
        }
        .padding(DS.Spacing.lg)
    }

    private var portraitContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                if !isLocked {
                    // Favorite button
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundStyle(isFavorite ? Color.appAccent : .white.opacity(0.6))
                            .padding(DS.Spacing.sm)
                            .background(.ultraThinMaterial.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, DS.Spacing.md)
            .padding(.trailing, DS.Spacing.md)

            Spacer()

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(sound.name)
                        .font(DS.Typography.labelLg)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(sound.category.rawValue)
                        .font(DS.Typography.labelSm)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                } else if isPlaying {
                    smallPlayingIndicator
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.md)
        }
    }

    private var landscapeContent: some View {
        HStack(spacing: DS.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.15))
                    .frame(width: 38, height: 38)

                Image(systemName: sound.category.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appAccent)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(sound.name)
                    .font(DS.Typography.buttonSm)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(sound.category.rawValue)
                    .font(DS.Typography.labelSm)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            if isLocked {
                lockBadge
            } else if isPlaying {
                smallPlayingIndicator
            } else {
                Image(systemName: "play.fill")
                    .font(DS.Typography.bodySm)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Shared Components

    private var lockBadge: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 14))
            .foregroundStyle(Color.appAccent)
            .padding(10)
            .background(Color.appAccent.opacity(0.15))
            .clipShape(Circle())
    }

    private var playingIndicator: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                EQBar(index: i)
            }
        }
        .frame(width: 20, height: 16)
        .padding(14)
        .background(Color.appAccent.opacity(0.2))
        .clipShape(Circle())
    }

    private var smallPlayingIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                EQBar(index: i, maxHeight: 10, width: 2)
            }
        }
        .frame(width: 14, height: 12)
    }

    private func playButton(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)

            Image(systemName: "play.fill")
                .font(.system(size: size * 0.35))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - EQ Bar Animation

struct EQBar: View {
    let index: Int
    var maxHeight: CGFloat = 16
    var width: CGFloat = 3

    @State private var animating = false

    var body: some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(Color.appAccent)
            .frame(width: width, height: animating ? maxHeight : maxHeight * 0.3)
            .animation(
                .easeInOut(duration: Double.random(in: 0.3...0.6))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.15),
                value: animating
            )
            .onAppear { animating = true }
    }
}

// MARK: - Card Press Style

struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
