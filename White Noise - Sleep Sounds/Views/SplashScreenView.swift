import SwiftUI

// MARK: - Splash Screen View

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var loadingOffset: CGFloat = -0.4
    @State private var statusOpacity: Double = 0.5
    @State private var arrowOffset: CGFloat = 0
    @State private var particlePhase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: Background Gradient (warm amber → olive → teal → dark)
                backgroundGradient

                // MARK: Floating Particles
                floatingParticles(in: geo.size)

                // MARK: Center Content
                VStack(spacing: 28) {
                    // Glowing Waveform Logo
                    logoSection

                    // Brand Name + Tagline
                    brandSection

                    // Loading Bar + Status Text
                    loadingSection
                }
                .padding(.horizontal, 24)

                // MARK: Down Arrow
                downArrow(in: geo.size)
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            startLoadingAnimation()
            startStatusPulse()
            startArrowBob()
            startParticlePhase()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            // Base vertical gradient: warm top → cool bottom
            LinearGradient(
                colors: [
                    Color(hex: "1A1610"),
                    Color(hex: "1A1812"),
                    Color(hex: "191A10"),
                    Color(hex: "161A12"),
                    Color(hex: "131912"),
                    Color(hex: "111814"),
                    Color(hex: "10171A"),
                    Color(hex: "0F1519"),
                    Color(hex: "0E1418"),
                    Color(hex: "0D1216"),
                    Color(hex: "0C1014")
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Warm amber glow — top right
            RadialGradient(
                colors: [
                    Color(hex: "C4A45A").opacity(0.18),
                    Color.clear
                ],
                center: UnitPoint(x: 0.65, y: 0.05),
                startRadius: 0,
                endRadius: 300
            )

            // Soft peach wash — top left
            RadialGradient(
                colors: [
                    Color(hex: "B48C50").opacity(0.10),
                    Color.clear
                ],
                center: UnitPoint(x: 0.25, y: 0.08),
                startRadius: 0,
                endRadius: 200
            )

            // Olive/forest mid transition
            RadialGradient(
                colors: [
                    Color(hex: "505F3C").opacity(0.12),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: 280
            )

            // Warm amber — middle right
            RadialGradient(
                colors: [
                    Color(hex: "B49650").opacity(0.10),
                    Color.clear
                ],
                center: UnitPoint(x: 0.8, y: 0.5),
                startRadius: 0,
                endRadius: 200
            )

            // Teal accent glow — center low
            RadialGradient(
                colors: [
                    Color.appAccent.opacity(0.07),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.6),
                startRadius: 0,
                endRadius: 220
            )

            // Warm olive lift — lower center
            RadialGradient(
                colors: [
                    Color(hex: "6E6E3C").opacity(0.06),
                    Color.clear
                ],
                center: UnitPoint(x: 0.45, y: 0.75),
                startRadius: 0,
                endRadius: 200
            )

            // Soft golden haze — lower right
            RadialGradient(
                colors: [
                    Color(hex: "A08246").opacity(0.07),
                    Color.clear
                ],
                center: UnitPoint(x: 0.7, y: 0.7),
                startRadius: 0,
                endRadius: 180
            )

            // Subtle grain texture overlay
            Color.white.opacity(0.015)
                .blendMode(.overlay)
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        ZStack {
            // Glow behind circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.appAccent.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
                .blur(radius: 30)
                .scaleEffect(isAnimating ? 1.15 : 1.0)
                .opacity(isAnimating ? 1.0 : 0.6)

            // Frosted glass circle
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.04))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.appAccent.opacity(0.08), radius: 32)
                .frame(width: 120, height: 120)
                .overlay(
                    // Animated waveform bars
                    WaveformIcon()
                        .frame(width: 52, height: 52)
                )
        }
    }

    // MARK: - Brand Section

    private var brandSection: some View {
        VStack(spacing: 6) {
            Text("WHITE\nNOISE")
                .font(.system(size: 58, weight: .semibold, design: .rounded))
                .tracking(6)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appAccent)
                .shadow(color: Color.appAccent.opacity(0.10), radius: 32)
                .shadow(color: Color.appAccent.opacity(0.06), radius: 48)

            Text("YOUR PERSONAL SOUND SANCTUARY")
                .font(.system(size: 12, weight: .light, design: .default))
                .tracking(4)
                .foregroundStyle(Color.appSecondary.opacity(0.75))
        }
    }

    // MARK: - Loading Section

    private var loadingSection: some View {
        VStack(spacing: 16) {
            // Loading track
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track background
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 2)

                    // Glowing bar
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.appAccent,
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * 0.4, height: 2)
                        .shadow(color: Color.appAccent, radius: 5)
                        .shadow(color: Color.appAccent, radius: 2)
                        .offset(x: loadingOffset * geo.size.width)
                }
            }
            .frame(height: 2)

            // Status text
            Text("FINDING YOUR SANCTUARY...")
                .font(.system(size: 11, weight: .medium))
                .tracking(2.5)
                .foregroundStyle(Color.onSurfaceVariant)
                .opacity(statusOpacity)
        }
        .frame(width: 240)
        .padding(.top, 48)
    }

    // MARK: - Down Arrow

    private func downArrow(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "chevron.compact.down")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Color.onBackground.opacity(0.35))
                .offset(y: arrowOffset)
                .padding(.bottom, 48)
        }
    }

    // MARK: - Floating Particles

    private func floatingParticles(in size: CGSize) -> some View {
        ZStack {
            ForEach(SplashParticle.allParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(
                        x: size.width * particle.xPosition,
                        y: particleY(
                            baseY: size.height * particle.startY,
                            totalHeight: size.height,
                            speed: particle.speed,
                            delay: particle.delay
                        )
                    )
                    .opacity(particleOpacity(
                        baseY: size.height * particle.startY,
                        totalHeight: size.height,
                        speed: particle.speed,
                        delay: particle.delay
                    ))
            }
        }
    }

    private func particleY(baseY: CGFloat, totalHeight: CGFloat, speed: Double, delay: Double) -> CGFloat {
        let progress = fmod(max(particlePhase - delay, 0), speed) / speed
        return baseY - (totalHeight * 1.2 * progress)
    }

    private func particleOpacity(baseY: CGFloat, totalHeight: CGFloat, speed: Double, delay: Double) -> Double {
        let progress = fmod(max(particlePhase - delay, 0), speed) / speed
        if progress < 0.1 { return progress * 10 }
        if progress > 0.9 { return (1 - progress) * 10 }
        return 1.0
    }

    // MARK: - Animations

    private func startLoadingAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
            loadingOffset = 1.0
        }
    }

    private func startStatusPulse() {
        withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
            statusOpacity = 1.0
        }
    }

    private func startArrowBob() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            arrowOffset = 6
        }
    }

    private func startParticlePhase() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            particlePhase += 0.05
        }
    }
}

// MARK: - Animated Waveform Icon

struct WaveformIcon: View {
    @State private var animating = false

    private let bars: [(offset: CGFloat, baseHeight: CGFloat, opacity: Double, duration: Double, delay: Double)] = [
        (-20, 12, 0.7, 1.2, 0.0),
        (-12, 24, 0.85, 1.4, 0.15),
        (-4, 36, 1.0, 1.1, 0.3),
        (4, 28, 0.9, 1.5, 0.1),
        (12, 18, 0.75, 1.3, 0.25),
        (20, 10, 0.6, 1.6, 0.4),
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { timeline in
            Canvas { context, size in
                let centerX = size.width / 2
                let centerY = size.height / 2
                let time = timeline.date.timeIntervalSinceReferenceDate
                let barWidth: CGFloat = 4

                for bar in bars {
                    let phase = sin((time - bar.delay) * (.pi * 2 / bar.duration))
                    let minHeight: CGFloat = bar.baseHeight * 0.4
                    let maxHeight = bar.baseHeight
                    let height = minHeight + (maxHeight - minHeight) * ((phase + 1) / 2)

                    let rect = CGRect(
                        x: centerX + bar.offset - barWidth / 2,
                        y: centerY - height / 2,
                        width: barWidth,
                        height: height
                    )

                    let path = Path(roundedRect: rect, cornerRadius: 2)
                    context.opacity = bar.opacity
                    context.fill(path, with: .color(Color.appAccent))

                    // Subtle glow
                    context.opacity = bar.opacity * 0.3
                    context.fill(path.strokedPath(StrokeStyle(lineWidth: 2)), with: .color(Color.appAccent))
                }
            }
        }
        .shadow(color: Color.appAccent.opacity(0.10), radius: 32)
    }
}

// MARK: - Particle Model

struct SplashParticle: Identifiable {
    let id = UUID()
    let xPosition: CGFloat   // 0-1 fraction of screen width
    let startY: CGFloat       // 0-1 fraction of screen height (start from bottom)
    let size: CGFloat
    let color: Color
    let speed: Double         // seconds to traverse screen
    let delay: Double         // offset delay in seconds

    static let allParticles: [SplashParticle] = [
        // Teal particles
        SplashParticle(xPosition: 0.15, startY: 1.1, size: 2.0, color: Color.appAccent.opacity(0.3), speed: 12, delay: 0),
        SplashParticle(xPosition: 0.45, startY: 1.1, size: 1.5, color: Color.appSecondary.opacity(0.25), speed: 16, delay: 2),
        SplashParticle(xPosition: 0.75, startY: 1.1, size: 2.0, color: Color.appAccent.opacity(0.2), speed: 14, delay: 4),
        SplashParticle(xPosition: 0.30, startY: 1.1, size: 1.0, color: Color.appTertiary.opacity(0.3), speed: 18, delay: 1),
        SplashParticle(xPosition: 0.60, startY: 1.1, size: 1.5, color: Color.appSecondary.opacity(0.2), speed: 15, delay: 6),
        SplashParticle(xPosition: 0.85, startY: 1.1, size: 1.0, color: Color.appAccent.opacity(0.25), speed: 20, delay: 3),

        // Warm amber particles — middle-right cluster
        SplashParticle(xPosition: 0.50, startY: 1.1, size: 1.5, color: Color(hex: "D2B464").opacity(0.20), speed: 17, delay: 5),
        SplashParticle(xPosition: 0.70, startY: 1.1, size: 1.0, color: Color(hex: "C4A45A").opacity(0.18), speed: 22, delay: 7),
        SplashParticle(xPosition: 0.78, startY: 1.1, size: 2.0, color: Color(hex: "D2AF5A").opacity(0.22), speed: 14, delay: 1.5),
        SplashParticle(xPosition: 0.65, startY: 1.1, size: 1.5, color: Color(hex: "BE9B4B").opacity(0.20), speed: 19, delay: 3.5),
        SplashParticle(xPosition: 0.82, startY: 1.1, size: 1.0, color: Color(hex: "DCBE6E").opacity(0.18), speed: 16, delay: 8),
        SplashParticle(xPosition: 0.55, startY: 1.1, size: 1.5, color: Color(hex: "B49650").opacity(0.15), speed: 21, delay: 4.5),
        SplashParticle(xPosition: 0.72, startY: 1.1, size: 2.0, color: Color(hex: "C8A555").opacity(0.17), speed: 13, delay: 9),
    ]
}

// MARK: - Preview

#Preview {
    SplashScreenView()
}
