import SwiftUI
import AppKit

private func parseHex(_ hex: String) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 6:
        (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
        (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
        (a, r, g, b) = (255, 0, 0, 0)
    }
    return (CGFloat(r) / 255, CGFloat(g) / 255, CGFloat(b) / 255, CGFloat(a) / 255)
}

extension Color {
    init(hex: String) {
        let (r, g, b, a) = parseHex(hex)
        self.init(.sRGB, red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
}

extension NSColor {
    convenience init(hex: String) {
        let (r, g, b, a) = parseHex(hex)
        self.init(srgbRed: r, green: g, blue: b, alpha: a)
    }
}

enum ThemeColors {
    // Backgrounds
    static let backgroundPrimary = Color(hex: "#1E1E1E")
    static let backgroundSecondary = Color(hex: "#252526")
    static let backgroundTertiary = Color(hex: "#2D2D2D")
    static let backgroundHover = Color(hex: "#363636")

    // Text - improved contrast
    static let textPrimary = Color(hex: "#E4E4E4")
    static let textSecondary = Color(hex: "#A0A0A0")
    static let textMuted = Color(hex: "#6E6E6E")

    // Accent
    static let accent = Color(hex: "#007AFF")
    static let accentHover = Color(hex: "#3395FF")

    // Status
    static let modified = Color(hex: "#E9A700")
    static let error = Color(hex: "#F14C4C")
    static let warning = Color(hex: "#CCA700")
    static let success = Color(hex: "#89D185")

    enum NS {
        static let backgroundPrimary = NSColor(hex: "#1E1E1E")
        static let backgroundSecondary = NSColor(hex: "#252526")
        static let backgroundTertiary = NSColor(hex: "#2D2D2D")

        static let textPrimary = NSColor(hex: "#E4E4E4")
        static let textSecondary = NSColor(hex: "#A0A0A0")
        static let textMuted = NSColor(hex: "#6E6E6E")

        static let accent = NSColor(hex: "#007AFF")
        static let modified = NSColor(hex: "#E9A700")
        static let currentLine = NSColor(hex: "#2D2D2D").withAlphaComponent(0.5)
        static let selection = NSColor(hex: "#007AFF").withAlphaComponent(0.3)
    }
}
