import SwiftUI

// MARK: - BadgeEmblemView

/// Renders any MilestoneBadge as a rich, animated emblem using custom shapes
/// from BadgeShapes.swift and animations from BadgeAnimations.swift.
struct BadgeEmblemView: View {
    let badge: MilestoneBadge
    let isUnlocked: Bool
    var size: CGFloat = 60

    // MARK: - Streak Flame Animation State

    @State private var flickerScale: CGFloat = 1.0
    @State private var flickerRotation: Double = 0
    @State private var flameGradientShift: Bool = false

    // MARK: - Time Clock Animation State

    @State private var clockTick: Double = 0
    @State private var clockPulse: CGFloat = 1.0

    // MARK: - Colors

    private var badgeColor: Color {
        switch badge.category {
        case .time: return .neonCyan
        case .streak: return .neonOrange
        case .behavior: return .neonGreen
        case .program:
            if let pt = badge.programType { return Color(hex: pt.colorHex) }
            return .neonPurple
        case .tool: return .neonGold
        }
    }

    private var gradientColors: [Color] {
        switch badge.category {
        case .time: return [.neonCyan, .neonBlue]
        case .streak: return [.neonOrange, .neonGold]
        case .behavior: return [.neonGreen, .neonCyan]
        case .program: return [badgeColor, badgeColor.opacity(0.6)]
        case .tool: return [.neonGold, .neonOrange]
        }
    }

    // MARK: - Streak-Specific Computed Properties

    /// Scale factor for the flame shape based on streak requiredDays.
    /// Longer streaks get bigger flames.
    private var flameScale: CGFloat {
        guard badge.category == .streak else { return 1.0 }
        switch badge.requiredDays {
        case 3: return 0.5       // Small flicker
        case 7: return 0.6       // Growing
        case 14: return 0.7      // Building
        case 30: return 0.8      // Strong
        case 60: return 0.85     // Powerful
        case 100: return 0.9     // Intense
        case 200: return 0.95    // Massive
        case 365: return 1.0     // Full inferno
        default: return 0.7
        }
    }

    // MARK: - Time-Specific Computed Properties

    /// Scale factor for the hex shield shape based on time requiredDays.
    /// Longer milestones get bigger clocks.
    private var clockScale: CGFloat {
        guard badge.category == .time else { return 1.0 }
        switch badge.requiredDays {
        case 1: return 0.4
        case 3: return 0.5
        case 7: return 0.55
        case 14: return 0.6
        case 30: return 0.65
        case 60: return 0.7
        case 90: return 0.8
        case 180: return 0.85
        case 270: return 0.9
        case 365: return 1.0
        default: return 0.7
        }
    }

    /// Time-specific gradient colors — every single milestone has a unique vibrant color.
    private var timeGradientColors: [Color] {
        guard badge.category == .time else { return gradientColors }
        switch badge.requiredDays {
        case 1: return [Color(hex: "00E5FF"), Color(hex: "00B8D4")]      // Bright cyan
        case 3: return [Color(hex: "39FF14"), Color(hex: "00E676")]      // Neon green
        case 7: return [Color(hex: "2979FF"), Color(hex: "448AFF")]      // Vivid blue
        case 14: return [Color(hex: "FF6D00"), Color(hex: "FF9100")]     // Bright orange
        case 30: return [Color(hex: "D500F9"), Color(hex: "AA00FF")]     // Electric purple
        case 60: return [Color(hex: "FF1744"), Color(hex: "F50057")]     // Hot red-pink
        case 90: return [Color(hex: "00BFA5"), Color(hex: "1DE9B6")]     // Emerald teal
        case 180: return [Color(hex: "FF4081"), Color(hex: "F50057")]    // Hot magenta-pink
        case 270: return [Color(hex: "E040FB"), Color(hex: "CE93D8")]    // Vivid violet
        case 365: return [Color(hex: "FFD700"), Color(hex: "FFFFFF"), Color(hex: "FFD700")]  // Golden legend
        default: return [.neonCyan, .neonBlue]
        }
    }

    /// Glow color and radius — each milestone gets its own glow matching its gradient.
    private var timeGlowConfig: (color: Color, radius: CGFloat) {
        guard badge.category == .time else { return (badgeColor, 12) }
        switch badge.requiredDays {
        case 1: return (Color(hex: "00E5FF").opacity(0.6), 8)
        case 3: return (Color(hex: "39FF14").opacity(0.6), 8)
        case 7: return (Color(hex: "2979FF").opacity(0.6), 8)
        case 14: return (Color(hex: "FF6D00").opacity(0.6), 10)
        case 30: return (Color(hex: "D500F9").opacity(0.7), 10)
        case 60: return (Color(hex: "FF1744").opacity(0.7), 12)
        case 90: return (Color(hex: "00BFA5").opacity(0.7), 12)
        case 180: return (Color(hex: "FF4081").opacity(0.8), 14)
        case 270: return (Color(hex: "E040FB").opacity(0.8), 14)
        case 365: return (Color(hex: "FFD700").opacity(0.95), 20)
        default: return (.neonCyan.opacity(0.5), 8)
        }
    }

    /// Flicker intensity parameters: (scale amplitude, rotation degrees, animation duration).
    /// Longer streaks get wilder, faster flame dance.
    private var flameFlickerIntensity: (scale: CGFloat, rotation: Double, speed: Double) {
        guard badge.category == .streak else { return (0.03, 2, 0.4) }
        switch badge.requiredDays {
        case 3: return (0.03, 1, 0.5)       // Gentle candle
        case 7: return (0.04, 2, 0.45)      // Small campfire
        case 14: return (0.05, 2.5, 0.4)    // Campfire
        case 30: return (0.06, 3, 0.35)     // Bonfire
        case 60: return (0.07, 3.5, 0.3)    // Roaring fire
        case 100: return (0.08, 4, 0.28)    // Blaze
        case 200: return (0.10, 5, 0.25)    // Inferno
        case 365: return (0.12, 6, 0.2)     // Wildfire
        default: return (0.05, 2.5, 0.4)
        }
    }

    /// Gradient colors that shift from warm orange (short streaks) to white-hot (365-day).
    private var streakGradientColors: [Color] {
        guard badge.category == .streak else { return gradientColors }
        switch badge.requiredDays {
        case 3: return [Color(hex: "FFA500"), Color(hex: "FFD700")]          // Orange to Gold
        case 7: return [Color(hex: "FF8C00"), Color(hex: "FF6347")]          // Dark Orange to Tomato
        case 14: return [Color(hex: "FF6347"), Color(hex: "FF4500")]         // Tomato to Red-Orange
        case 30: return [Color(hex: "FF4500"), Color(hex: "DC143C")]         // Red-Orange to Crimson
        case 60: return [Color(hex: "DC143C"), Color(hex: "B22222")]         // Crimson to Firebrick
        case 100: return [Color(hex: "B22222"), Color(hex: "8B0000")]        // Firebrick to Dark Red
        case 200: return [Color(hex: "FF1493"), Color(hex: "DC143C")]        // Deep Pink to Crimson
        case 365: return [.white, Color(hex: "FFD700"), Color(hex: "FF4500")] // White-hot
        default: return [.neonOrange, .neonGold]
        }
    }

    /// Glow color and radius that intensify with longer streaks.
    private var streakGlowConfig: (color: Color, radius: CGFloat) {
        guard badge.category == .streak else { return (badgeColor, 12) }
        switch badge.requiredDays {
        case 3: return (Color(hex: "FFA500").opacity(0.6), 8)
        case 7: return (Color(hex: "FF8C00").opacity(0.65), 10)
        case 14: return (Color(hex: "FF6347").opacity(0.7), 12)
        case 30: return (Color(hex: "FF4500").opacity(0.75), 14)
        case 60: return (Color(hex: "DC143C").opacity(0.8), 16)
        case 100: return (Color(hex: "B22222").opacity(0.85), 18)
        case 200: return (Color(hex: "FF1493").opacity(0.9), 20)
        case 365: return (.white.opacity(0.95), 24)
        default: return (.neonOrange.opacity(0.7), 12)
        }
    }

    /// Resolved gradient — uses streak-specific colors for streak badges, time-specific for time badges, standard otherwise.
    private var resolvedGradientColors: [Color] {
        if badge.category == .streak { return streakGradientColors }
        if badge.category == .time { return timeGradientColors }
        return gradientColors
    }

    private var gradient: LinearGradient {
        LinearGradient(colors: resolvedGradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var strokeGradient: LinearGradient {
        LinearGradient(
            colors: [.white.opacity(0.4), badgeColor.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if isUnlocked {
                unlockedEmblem
            } else {
                lockedEmblem
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startStreakFlickerIfNeeded()
                startClockTickIfNeeded()
            }
        }
    }

    // MARK: - Streak Flicker Animation

    private func startStreakFlickerIfNeeded() {
        guard badge.category == .streak else { return }
        // Subtle pulsate only — no rotation, no wobble
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            flickerScale = 1.05
        }
        // Animate gradient colors flowing through the flame shape
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            flameGradientShift = true
        }
    }

    // MARK: - Clock Tick Animation (disabled — no movement on time badges)

    private func startClockTickIfNeeded() {
        // Time badges are static — no animation
    }

    // MARK: - Unlocked Emblem

    private var unlockedEmblem: some View {
        ZStack {
            // Base shape with gradient fill
            shapeFill

            // Border stroke
            shapeStroke

            // Inner icon (skip for time badges — WatchFaceView has its own face)
            if badge.category != .time {
                Image(systemName: badge.iconName)
                    .font(.system(size: size * 0.35).weight(.bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }

            // Tier indicator (for track badges)
            if let tier = badge.tier, tier > 0 {
                tierIndicator(tier: tier)
            }

            // Tier rings overlay for tool/track badges
            if let tier = badge.tier, tier > 0 {
                TierRingsView(tier: tier, color: badgeColor)
            }
        }
        .applyStreakGlow(badge: badge, glowConfig: streakGlowConfig, timeGlowConfig: timeGlowConfig, fallbackColor: badgeColor)
    }

    // MARK: - Locked Emblem

    private var lockedEmblem: some View {
        ZStack {
            // FULL vibrant badge — same as unlocked, NO dimming
            Group {
                switch badge.category {
                case .time:
                    WatchFaceView(
                        requiredDays: badge.requiredDays,
                        gradientColors: resolvedGradientColors,
                        size: size,
                        isLocked: true
                    )
                case .streak:
                    FlameShape()
                        .fill(animatedFlameGradient)
                        .scaleEffect(flameScale)
                        .scaleEffect(flickerScale)
                case .behavior: MedallionShape().fill(LinearGradient(colors: resolvedGradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                case .program: ProgramShieldShape().fill(LinearGradient(colors: resolvedGradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                case .tool: StarBurstShape().fill(LinearGradient(colors: resolvedGradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                }
            }

            // Full vibrant border stroke
            Group {
                switch badge.category {
                case .time:
                    // WatchFaceView handles its own rendering
                    EmptyView()
                case .streak:
                    // No stroke — flame fill is the only visual
                    EmptyView()
                case .behavior: MedallionShape().stroke(LinearGradient(colors: [.white.opacity(0.4), badgeColor.opacity(0.6)], startPoint: .top, endPoint: .bottom), lineWidth: size * 0.03)
                case .program: ProgramShieldShape().stroke(LinearGradient(colors: [.white.opacity(0.4), badgeColor.opacity(0.6)], startPoint: .top, endPoint: .bottom), lineWidth: size * 0.03)
                case .tool: StarBurstShape().stroke(LinearGradient(colors: [.white.opacity(0.4), badgeColor.opacity(0.6)], startPoint: .top, endPoint: .bottom), lineWidth: size * 0.03)
                }
            }

            // Full bright icon — same as unlocked (skip for time badges)
            if badge.category != .time {
                Image(systemName: badge.iconName)
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }

            // Tier indicator (for track badges)
            if let tier = badge.tier, tier > 0 {
                tierIndicator(tier: tier)
            }

            // Small lock icon in TOP-RIGHT corner
            Image(systemName: "lock.fill")
                .font(.system(size: size * 0.15))
                .foregroundColor(.white)
                .padding(size * 0.04)
                .background(Circle().fill(Color.black.opacity(0.6)))
                .offset(x: size * 0.3, y: -size * 0.3)
        }
        .applyStreakGlow(badge: badge, glowConfig: streakGlowConfig, timeGlowConfig: timeGlowConfig, fallbackColor: badgeColor)
    }

    // MARK: - Shape Rendering (iOS 15 compatible switch/Group pattern)

    /// Animated gradient for streak flames — colors flow through the flame shape
    private var animatedFlameGradient: LinearGradient {
        LinearGradient(
            colors: resolvedGradientColors,
            startPoint: flameGradientShift ? .top : .bottomLeading,
            endPoint: flameGradientShift ? .bottom : .topTrailing
        )
    }

    @ViewBuilder
    private var shapeFill: some View {
        Group {
            switch badge.category {
            case .time:
                WatchFaceView(
                    requiredDays: badge.requiredDays,
                    gradientColors: resolvedGradientColors,
                    size: size,
                    isLocked: false
                )
            case .streak:
                FlameShape()
                    .fill(animatedFlameGradient)
                    .scaleEffect(flameScale)
                    .scaleEffect(flickerScale)
            case .behavior:
                MedallionShape().fill(gradient)
            case .program:
                ProgramShieldShape().fill(gradient)
            case .tool:
                StarBurstShape().fill(gradient)
            }
        }
    }

    @ViewBuilder
    private var shapeStroke: some View {
        Group {
            switch badge.category {
            case .time:
                // WatchFaceView handles its own rendering — no separate stroke needed
                EmptyView()
            case .streak:
                // No stroke — flame fill is the only visual
                EmptyView()
            case .behavior:
                MedallionShape().stroke(strokeGradient, lineWidth: size * 0.03)
            case .program:
                ProgramShieldShape().stroke(strokeGradient, lineWidth: size * 0.03)
            case .tool:
                StarBurstShape().stroke(strokeGradient, lineWidth: size * 0.03)
            }
        }
    }

    // lockedShapeFill and lockedShapeStroke removed — locked badges now use real colors inline

    // MARK: - Tier Indicator

    private func tierIndicator(tier: Int) -> some View {
        Text(tierLabel(tier))
            .font(.system(size: size * 0.12, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, size * 0.06)
            .padding(.vertical, size * 0.02)
            .background(Capsule().fill(badgeColor))
            .offset(y: size * 0.38)
    }

    private func tierLabel(_ tier: Int) -> String {
        switch tier {
        case 1: return "I"
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
        default: return "\(tier)"
        }
    }
}

// MARK: - Glow Helper

private extension View {
    @ViewBuilder
    func applyStreakGlow(badge: MilestoneBadge, glowConfig: (color: Color, radius: CGFloat), timeGlowConfig: (color: Color, radius: CGFloat)? = nil, fallbackColor: Color) -> some View {
        if badge.category == .streak {
            // No outer glow — the flame itself has animated colors
            self
        } else if badge.category == .time, let tg = timeGlowConfig {
            self.shadow(color: tg.color, radius: tg.radius)
        } else {
            self.glowPulse(color: fallbackColor)
        }
    }
}

// MARK: - Preview

struct BadgeEmblemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Show all streak badges to visualize flame progression
            Text("Streak Flame Progression")
                .font(.system(size: 14).weight(.bold))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(MilestoneBadge.streakBadges, id: \.key) { badge in
                    VStack(spacing: 4) {
                        BadgeEmblemView(badge: badge, isUnlocked: true, size: 50)
                        Text("\(badge.requiredDays)d")
                            .font(.system(size: 10).weight(.bold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }

            // Original sample badges
            HStack(spacing: 16) {
                BadgeEmblemView(badge: MilestoneBadge.timeBadges[0], isUnlocked: true, size: 60)
                BadgeEmblemView(badge: MilestoneBadge.streakBadges[1], isUnlocked: true, size: 60)
                BadgeEmblemView(badge: MilestoneBadge.behaviorBadges[0], isUnlocked: false, size: 60)
                BadgeEmblemView(badge: MilestoneBadge.programBadges[0], isUnlocked: true, size: 60)
                BadgeEmblemView(badge: MilestoneBadge.waveRiderTrack[2], isUnlocked: true, size: 60)
            }
        }
        .padding()
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
