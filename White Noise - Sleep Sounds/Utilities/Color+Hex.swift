import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let appBackground = Color(hex: "0D0F1A")
    static let appSurface = Color(hex: "1A1D2E")
    static let appAccent = Color(hex: "7C6CF0")

    // Extended theme tokens
    static let primaryContainer = Color(hex: "3D2FA0")
    static let secondaryContainer = Color(hex: "2A1F6E")
    static let onSurface = Color.white
    static let onSurfaceVariant = Color.white.opacity(0.6)
    static let onPrimary = Color.white
    static let surfaceContainerHigh = Color(hex: "232640")
}
