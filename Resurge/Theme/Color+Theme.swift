import SwiftUI

// MARK: - Theme Color Cache

/// Caches resolved theme colors to avoid repeated UserDefaults reads and Color(hex:) parsing.
/// Call `ThemeColors.refresh()` when the theme changes.
final class ThemeColors {
    static let shared = ThemeColors()

    private(set) var appBackground: Color
    private(set) var cardBackground: Color
    private(set) var cardBorder: Color
    private(set) var elevatedBackground: Color
    private var cachedTheme: String

    private init() {
        let theme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "default"
        cachedTheme = theme
        appBackground = ThemeColors.resolveAppBackground(theme)
        cardBackground = ThemeColors.resolveCardBackground(theme)
        cardBorder = ThemeColors.resolveCardBorder(theme)
        elevatedBackground = ThemeColors.resolveElevatedBackground(theme)
    }

    func refresh() {
        let theme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "default"
        guard theme != cachedTheme else { return }
        cachedTheme = theme
        appBackground = ThemeColors.resolveAppBackground(theme)
        cardBackground = ThemeColors.resolveCardBackground(theme)
        cardBorder = ThemeColors.resolveCardBorder(theme)
        elevatedBackground = ThemeColors.resolveElevatedBackground(theme)
    }

    /// Call this to ensure cache is fresh — cheap if already up to date
    func refreshIfNeeded() {
        let theme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "default"
        if theme != cachedTheme { refresh() }
    }

    private static func resolveAppBackground(_ theme: String) -> Color {
        switch theme {
        case "theme_midnight": return Color(hex: "000000")   // Pure black
        case "theme_aurora":   return Color(hex: "021A0A")   // Deep dark green-black (Neon Jungle)
        case "theme_sunset":   return Color(hex: "0E0520")   // Deep dark purple-black (Ultraviolet)
        case "theme_ocean":    return Color(hex: "001428")   // Deep navy ocean
        default:               return Color(hex: "05051A")
        }
    }

    private static func resolveCardBackground(_ theme: String) -> Color {
        switch theme {
        case "theme_midnight": return Color(hex: "0A0A0A")
        case "theme_aurora":   return Color(hex: "0A2A15")   // Dark emerald card
        case "theme_sunset":   return Color(hex: "1A0A30")   // Dark violet card
        case "theme_ocean":    return Color(hex: "082840")
        default:               return Color(hex: "10102A")
        }
    }

    private static func resolveCardBorder(_ theme: String) -> Color {
        switch theme {
        case "theme_midnight": return Color(hex: "1A1A1A")
        case "theme_aurora":   return Color(hex: "00E676")   // Bright neon green border
        case "theme_sunset":   return Color(hex: "E040FB")   // Vivid hot pink border
        case "theme_ocean":    return Color(hex: "1A4570")
        default:               return Color(hex: "1E1E42")
        }
    }

    private static func resolveElevatedBackground(_ theme: String) -> Color {
        switch theme {
        case "theme_midnight": return Color(hex: "0F0F0F")
        case "theme_aurora":   return Color(hex: "0D3520")   // Lifted emerald
        case "theme_sunset":   return Color(hex: "250E3A")   // Lifted deep purple
        case "theme_ocean":    return Color(hex: "0A3050")
        default:               return Color(hex: "161638")
        }
    }
}

// MARK: - Color Extension

extension Color {
    // MARK: - Rainbow Gradient Palette (matched to Resurge logo)

    /// Bright cyan-blue — the "cool" anchor of the gradient
    static let neonCyan = Color(hex: "00D4FF")
    /// Rich blue-violet — transition into purple
    static let neonBlue = Color(hex: "4B7BF5")
    /// Vivid purple — center of the spectrum
    static let neonPurple = Color(hex: "A855F7")
    /// Hot magenta-pink — warm transition
    static let neonMagenta = Color(hex: "F637CF")
    /// Vibrant orange — approaching the warm end
    static let neonOrange = Color(hex: "FF6B35")
    /// Rich gold-yellow — the "warm" anchor
    static let neonGold = Color(hex: "FFD700")
    /// Bright green for success states
    static let neonGreen = Color(hex: "39FF14")

    // MARK: - Backgrounds & Surfaces (Theme-Aware, Cached)

    /// Main background — auto-refreshes cache if theme changed
    static var appBackground: Color {
        ThemeColors.shared.refreshIfNeeded()
        return ThemeColors.shared.appBackground
    }

    /// Card surface — auto-refreshes cache if theme changed
    static var cardBackground: Color {
        ThemeColors.shared.refreshIfNeeded()
        return ThemeColors.shared.cardBackground
    }

    /// Card border — auto-refreshes cache if theme changed
    static var cardBorder: Color {
        ThemeColors.shared.refreshIfNeeded()
        return ThemeColors.shared.cardBorder
    }

    /// Elevated surface — auto-refreshes cache if theme changed
    static var elevatedBackground: Color {
        ThemeColors.shared.refreshIfNeeded()
        return ThemeColors.shared.elevatedBackground
    }

    // MARK: - Text

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9B9BC0")

    // MARK: - Legacy Aliases

    static var primaryTeal: Color { neonCyan }
    static var accentOrange: Color { neonMagenta }
    static var premiumGold: Color { neonGold }
    static var appText: Color { textPrimary }
    static var subtleText: Color { textSecondary }

    // MARK: - Rainbow Gradients

    /// Full rainbow gradient matching the logo R — cyan → blue → purple → magenta → orange → gold
    static let rainbowGradient = LinearGradient(
        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Warm half — purple → magenta → orange → gold
    static let warmGradient = LinearGradient(
        colors: [.neonPurple, .neonMagenta, .neonOrange, .neonGold],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Cool half — cyan → blue → purple
    static let coolGradient = LinearGradient(
        colors: [.neonCyan, .neonBlue, .neonPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Accent gradient — cyan → purple (for buttons, progress bars)
    static let accentGradient = LinearGradient(
        colors: [.neonCyan, .neonPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Gold premium gradient
    static let premiumGradient = LinearGradient(
        colors: [.neonGold, .neonOrange],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Angular Rainbow (for rings, borders)

    static let rainbowAngular = AngularGradient(
        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold, .neonCyan],
        center: .center
    )

    // MARK: - Hex Initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
