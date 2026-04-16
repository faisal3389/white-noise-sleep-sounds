import SwiftUI

// MARK: - Design System (Canonical source: DESIGN.md)
// "The Ethereal Sanctuary" — all design tokens centralized here.

struct DS {

    // MARK: - Typography

    /// Display & Headlines use Manrope variable font (geometric, modern warmth).
    /// Body & Labels use system font (SF Pro) for native legibility.
    /// Manrope is registered as a variable font — access weights via Font.custom + .weight().
    enum Typography {
        // Display — Manrope Bold
        static let displayLg = Font.custom("Manrope", size: 34).weight(.bold)
        static let displayHero = Font.custom("Manrope", size: 36).weight(.bold)

        // Headlines — Manrope
        static let headlineLg = Font.custom("Manrope", size: 22).weight(.bold)
        static let headlineMd = Font.custom("Manrope", size: 20).weight(.semibold)
        static let headlineSm = Font.custom("Manrope", size: 18).weight(.semibold)

        // Body — System (SF Pro / Inter equivalent)
        static let bodyLg = Font.system(size: 16)
        static let bodyMd = Font.system(size: 14)
        static let bodySm = Font.system(size: 13)

        // Labels — System
        static let labelLg = Font.system(size: 15, weight: .semibold)
        static let labelMd = Font.system(size: 13, weight: .medium)
        static let labelSm = Font.system(size: 11, weight: .medium)
        static let labelXs = Font.system(size: 10, weight: .bold)

        // Specialty
        static let timerDisplay = Font.system(size: 64, weight: .light, design: .monospaced)
        static let clockDisplay = Font.system(size: 72, weight: .thin, design: .monospaced)

        // Category pill / tracking text
        static let pill = Font.system(size: 10, weight: .bold)

        // Button text
        static let button = Font.system(size: 17, weight: .semibold)
        static let buttonSm = Font.system(size: 14, weight: .semibold)
    }

    // MARK: - Spacing (DESIGN.md §7)

    /// Gutter: 24px, Component Gap: 16px, Section Gap: 40px+
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16    // component gap
        static let xl: CGFloat = 24    // gutter
        static let xxl: CGFloat = 32
        static let section: CGFloat = 40  // section gap
        static let sectionLg: CGFloat = 48
    }

    // MARK: - Corner Radius (DESIGN.md §5)

    /// Cards: xl (24). Controls: lg (16). Small elements: md (12). Pill: full.
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24     // cards per spec
        static let full: CGFloat = 9999  // pill / capsule
    }

    // MARK: - Shadows (DESIGN.md §4)

    /// Extra-diffused: 32–64px blur, 6–10% opacity, tinted with on-surface (#F6F6FC).
    struct ShadowToken {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat

        static let ambient = ShadowToken(
            color: Color(hex: "F6F6FC").opacity(0.08),
            radius: 32, x: 0, y: 4
        )
        static let card = ShadowToken(
            color: Color(hex: "F6F6FC").opacity(0.06),
            radius: 24, x: 0, y: 2
        )
        static let floating = ShadowToken(
            color: Color(hex: "F6F6FC").opacity(0.08),
            radius: 40, x: 0, y: -4
        )
        static let accentGlow = ShadowToken(
            color: Color.appAccent.opacity(0.10),
            radius: 48, x: 0, y: 4
        )
        static let playButton = ShadowToken(
            color: Color.appAccent.opacity(0.10),
            radius: 32, x: 0, y: 4
        )
    }
}

// MARK: - Shadow View Modifier

extension View {
    func dsShadow(_ token: DS.ShadowToken) -> some View {
        self.shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
    }
}

// MARK: - Jewel Gradient for Primary Buttons (DESIGN.md §5)
/// "primary to primary-container subtle vertical gradient" for a jewel-like quality.

extension LinearGradient {
    static let jewelButton = LinearGradient(
        colors: [Color.appAccent, Color.primaryContainer],
        startPoint: .top,
        endPoint: .bottom
    )

    static let jewelButtonDiagonal = LinearGradient(
        colors: [Color.appAccent, Color.primaryContainer],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
