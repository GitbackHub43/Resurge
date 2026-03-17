import SwiftUI

/// Draws a watch/clock face that gets more sophisticated with higher requiredDays.
/// From a basic digital watch (1d) to an ornate luxury timepiece (365d).
struct WatchFaceView: View {
    let requiredDays: Int
    let gradientColors: [Color]
    let size: CGFloat
    let isLocked: Bool

    private var tier: Int {
        switch requiredDays {
        case 1: return 0       // Basic digital
        case 3: return 1       // Simple round
        case 7: return 2       // Sport watch
        case 14: return 3      // Dress watch
        case 30: return 4      // Chronograph
        case 60: return 5      // Diver's watch
        case 90: return 6      // Premium
        case 180: return 7     // Luxury
        case 270: return 8     // Grand complication
        case 365: return 9     // Ultimate — Annual Legend
        default: return 2
        }
    }

    private var watchSize: CGFloat {
        let base: CGFloat = 0.55
        let growth = CGFloat(min(tier, 9)) * 0.05
        return size * (base + growth)
    }

    private var bezelWidth: CGFloat {
        tier >= 4 ? size * 0.04 : size * 0.025
    }

    var body: some View {
        ZStack {
            // Watch case / bezel
            watchCase

            // Watch face
            watchDial

            // Hour markers
            if tier >= 1 {
                hourMarkers
            }

            // Watch hands
            if tier >= 1 {
                watchHands
            }

            // Complications (sub-dials) for higher tiers
            if tier >= 4 {
                complications
            }

            // Crown (winding knob) for tier 2+
            if tier >= 2 {
                crown
            }

            // Strap lugs for tier 3+
            if tier >= 3 {
                strapLugs
            }
        }
    }

    // MARK: - Watch Case

    private var watchCase: some View {
        ZStack {
            // Outer bezel
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: watchSize, height: watchSize)

            // Bezel ring for higher tiers
            if tier >= 5 {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: gradientColors + [gradientColors.first ?? .white],
                            center: .center
                        ),
                        lineWidth: bezelWidth
                    )
                    .frame(width: watchSize - bezelWidth, height: watchSize - bezelWidth)
            }

            // Inner face background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "0A0A1A"), Color(hex: "050510")],
                        center: .center,
                        startRadius: 0,
                        endRadius: watchSize * 0.4
                    )
                )
                .frame(width: watchSize - bezelWidth * 2 - size * 0.06, height: watchSize - bezelWidth * 2 - size * 0.06)
        }
    }

    // MARK: - Watch Dial

    private var watchDial: some View {
        let dialSize = watchSize - bezelWidth * 2 - size * 0.08

        return ZStack {
            if tier == 0 {
                // Digital display for 1-day badge
                RoundedRectangle(cornerRadius: size * 0.04)
                    .fill(
                        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: watchSize * 0.7, height: watchSize * 0.5)
                RoundedRectangle(cornerRadius: size * 0.02)
                    .fill(Color(hex: "0A0A1A"))
                    .frame(width: watchSize * 0.6, height: watchSize * 0.35)
                Text("1D")
                    .font(.system(size: dialSize * 0.3, weight: .bold, design: .monospaced))
                    .foregroundColor(gradientColors.first ?? .neonCyan)
            }
        }
    }

    // MARK: - Hour Markers

    private var hourMarkers: some View {
        let dialRadius = (watchSize - bezelWidth * 2 - size * 0.1) / 2
        let markerCount = tier >= 6 ? 12 : (tier >= 3 ? 12 : 4)

        return ZStack {
            ForEach(0..<markerCount, id: \.self) { i in
                let angle = Double(i) / Double(markerCount) * 360 - 90
                let isCardinal = i % (markerCount / 4) == 0
                let markerLength: CGFloat = isCardinal ? size * 0.05 : size * 0.025
                let markerWidth: CGFloat = isCardinal ? size * 0.02 : size * 0.01

                RoundedRectangle(cornerRadius: 1)
                    .fill(tier >= 7 ? gradientColors.first ?? .white : .white)
                    .frame(width: markerWidth, height: markerLength)
                    .offset(y: -(dialRadius - markerLength / 2 - size * 0.02))
                    .rotationEffect(.degrees(angle))
                    .opacity(tier >= 2 ? 0.9 : 0.6)
            }
        }
    }

    // MARK: - Watch Hands

    private var watchHands: some View {
        let dialRadius = (watchSize - bezelWidth * 2 - size * 0.12) / 2

        return ZStack {
            // Hour hand
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white)
                .frame(width: size * 0.02, height: dialRadius * 0.5)
                .offset(y: -dialRadius * 0.25)
                .rotationEffect(.degrees(-30))

            // Minute hand
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.015, height: dialRadius * 0.7)
                .offset(y: -dialRadius * 0.35)
                .rotationEffect(.degrees(60))

            // Second hand for tier 3+
            if tier >= 3 {
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(gradientColors.first ?? .neonCyan)
                    .frame(width: size * 0.008, height: dialRadius * 0.75)
                    .offset(y: -dialRadius * 0.375)
                    .rotationEffect(.degrees(180))
            }

            // Center dot
            Circle()
                .fill(tier >= 5 ? gradientColors.first ?? .white : .white)
                .frame(width: size * 0.04, height: size * 0.04)
        }
    }

    // MARK: - Complications (sub-dials)

    private var complications: some View {
        let subSize = watchSize * 0.15

        return ZStack {
            // Small sub-dial at 6 o'clock
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                .frame(width: subSize, height: subSize)
                .offset(y: watchSize * 0.15)

            if tier >= 6 {
                // Sub-dial at 9 o'clock
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    .frame(width: subSize, height: subSize)
                    .offset(x: -watchSize * 0.15)
            }

            if tier >= 8 {
                // Sub-dial at 3 o'clock
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    .frame(width: subSize, height: subSize)
                    .offset(x: watchSize * 0.15)

                // Date window
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white)
                    .frame(width: size * 0.06, height: size * 0.035)
                    .offset(x: watchSize * 0.2, y: size * 0.005)
            }
        }
    }

    // MARK: - Crown

    private var crown: some View {
        let crownColor = tier >= 7 ? gradientColors.first ?? .neonGold : Color(hex: "888888")

        return RoundedRectangle(cornerRadius: size * 0.01)
            .fill(crownColor)
            .frame(width: size * 0.04, height: size * 0.06)
            .offset(x: watchSize / 2 + size * 0.01)
    }

    // MARK: - Strap Lugs

    private var strapLugs: some View {
        let lugColor = tier >= 7 ? gradientColors.first ?? .neonGold : Color(hex: "666666")

        return ZStack {
            // Top lugs
            HStack(spacing: watchSize * 0.5) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(lugColor)
                    .frame(width: size * 0.03, height: size * 0.06)
                RoundedRectangle(cornerRadius: 1)
                    .fill(lugColor)
                    .frame(width: size * 0.03, height: size * 0.06)
            }
            .offset(y: -watchSize / 2 - size * 0.02)

            // Bottom lugs
            HStack(spacing: watchSize * 0.5) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(lugColor)
                    .frame(width: size * 0.03, height: size * 0.06)
                RoundedRectangle(cornerRadius: 1)
                    .fill(lugColor)
                    .frame(width: size * 0.03, height: size * 0.06)
            }
            .offset(y: watchSize / 2 + size * 0.02)
        }
    }
}
