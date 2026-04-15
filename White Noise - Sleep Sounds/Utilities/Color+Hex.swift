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

    // MARK: - PRD Section 4.2 Design Tokens (Material Design 3 Dark)

    static let appBackground = Color(hex: "0C0E12")
    static let appSurface = Color(hex: "0C0E12")
    static let appAccent = Color(hex: "7FE6DB")           // primary
    static let appSecondary = Color(hex: "96A5FF")
    static let appTertiary = Color(hex: "CCF9FF")

    static let surfaceContainerLow = Color(hex: "111318")
    static let surfaceContainer = Color(hex: "171A1F")
    static let surfaceContainerHigh = Color(hex: "1D2025")
    static let surfaceContainerHighest = Color(hex: "23262C")

    static let onBackground = Color(hex: "F6F6FC")
    static let onSurface = Color(hex: "F6F6FC")
    static let onSurfaceVariant = Color(hex: "AAABB0")
    static let onPrimary = Color(hex: "00534D")

    static let primaryContainer = Color(hex: "47B0A7")
    static let secondaryContainer = Color(hex: "2F3F92")

    static let outline = Color(hex: "74757A")
    static let outlineVariant = Color(hex: "46484D")
    static let error = Color(hex: "FF716C")
}

