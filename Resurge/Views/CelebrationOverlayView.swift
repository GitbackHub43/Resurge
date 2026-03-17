import SwiftUI

// MARK: - Celebration Type

enum CelebrationType: String {
    case rainbowBurst = "celebration_rainbow_burst"
    case goldenShower = "celebration_golden_shower"
    case neonRain = "celebration_neon_rain"
    case cosmicSparkle = "celebration_cosmic_sparkle"
}

// MARK: - Celebration Manager

/// Manages triggering full-screen celebration animations.
/// Checks if the user owns the celebration pack before showing.
final class CelebrationManager: ObservableObject {
    static let shared = CelebrationManager()

    @Published var activeCelebration: CelebrationType?
    @Published var isShowing: Bool = false

    private init() {}

    /// Trigger a celebration if the user owns the pack.
    func trigger(_ type: CelebrationType) {
        let owned = UserDefaults.standard.bool(forKey: "owns_\(type.rawValue)")
        guard owned else { return }
        DispatchQueue.main.async {
            self.activeCelebration = type
            self.isShowing = true
        }
        // Auto-dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.isShowing = false
            self.activeCelebration = nil
        }
    }

    /// Mark a celebration as owned (called after purchase).
    static func markOwned(_ type: CelebrationType) {
        UserDefaults.standard.set(true, forKey: "owns_\(type.rawValue)")
    }

    /// Check if a celebration is owned.
    static func isOwned(_ type: CelebrationType) -> Bool {
        UserDefaults.standard.bool(forKey: "owns_\(type.rawValue)")
    }
}

// MARK: - Celebration Overlay View

/// Full-screen overlay that plays the celebration animation.
/// Add this to the root of the app (e.g., in ResurgeApp or MainTabView).
struct CelebrationOverlayView: View {
    @ObservedObject var manager = CelebrationManager.shared

    var body: some View {
        ZStack {
            if manager.isShowing, let type = manager.activeCelebration {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)

                Group {
                    switch type {
                    case .rainbowBurst: FullScreenRainbowBurst()
                    case .goldenShower: FullScreenGoldenShower()
                    case .neonRain: FullScreenNeonRain()
                    case .cosmicSparkle: FullScreenCosmicSparkle()
                    }
                }
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: manager.isShowing)
        .allowsHitTesting(false)
    }
}

// MARK: - Full Screen Rainbow Burst

/// Rainbow particles explode outward from the center of the screen
private struct FullScreenRainbowBurst: View {
    @State private var phase: CGFloat = 0
    private let colors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2
            let maxR = max(geo.size.width, geo.size.height) * 0.5

            ZStack {
                ForEach(0..<36, id: \.self) { i in
                    let angle = Double(i) * 10
                    let r = phase * maxR
                    let size: CGFloat = 8 - phase * 4
                    Circle()
                        .fill(colors[i % colors.count])
                        .frame(width: max(size, 2), height: max(size, 2))
                        .shadow(color: colors[i % colors.count].opacity(0.8), radius: 6)
                        .position(
                            x: cx + r * CGFloat(Foundation.cos(angle * .pi / 180)),
                            y: cy + r * CGFloat(Foundation.sin(angle * .pi / 180))
                        )
                        .opacity(Double(1.0 - phase * 0.8))
                }

                // Second wave offset
                ForEach(0..<36, id: \.self) { i in
                    let angle = Double(i) * 10 + 5
                    let r = max(0, phase - 0.15) * maxR
                    Circle()
                        .fill(colors[(i + 3) % colors.count])
                        .frame(width: 5, height: 5)
                        .shadow(color: colors[(i + 3) % colors.count].opacity(0.6), radius: 4)
                        .position(
                            x: cx + r * CGFloat(Foundation.cos(angle * .pi / 180)),
                            y: cy + r * CGFloat(Foundation.sin(angle * .pi / 180))
                        )
                        .opacity(Double(max(0, 1.0 - phase)))
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                phase = 1.0
            }
        }
    }
}

// MARK: - Full Screen Golden Shower

/// Gold drops rain down the entire screen from top to bottom
private struct FullScreenGoldenShower: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<40, id: \.self) { i in
                    GoldenScreenDrop(
                        screenWidth: geo.size.width,
                        screenHeight: geo.size.height,
                        index: i
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct GoldenScreenDrop: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let index: Int

    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0

    private var xPos: CGFloat {
        CGFloat(index % 10) * (screenWidth / 10) + CGFloat.random(in: -15...15)
    }
    private var delay: Double { Double(index) * 0.04 }
    private var duration: Double { Double.random(in: 0.6...1.2) }
    private var size: CGFloat { CGFloat.random(in: 3...6) }

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .frame(width: size, height: size * 3)
            .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 4)
            .position(x: xPos, y: -20 + offset)
            .opacity(opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    opacity = 0.9
                    withAnimation(.linear(duration: duration).repeatCount(3, autoreverses: false)) {
                        offset = screenHeight + 40
                    }
                }
            }
    }
}

// MARK: - Full Screen Neon Rain

/// Neon-colored streaks fall across the entire screen
private struct FullScreenNeonRain: View {
    private let colors: [Color] = [.neonCyan, .neonPurple, .neonMagenta, .neonGreen, .neonBlue, .neonOrange, .neonGold]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<50, id: \.self) { i in
                    NeonScreenDrop(
                        screenWidth: geo.size.width,
                        screenHeight: geo.size.height,
                        color: colors[i % colors.count],
                        index: i
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct NeonScreenDrop: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let color: Color
    let index: Int

    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0

    private var xPos: CGFloat {
        CGFloat(index % 12) * (screenWidth / 12) + CGFloat.random(in: -10...10)
    }
    private var delay: Double { Double(index) * 0.03 }
    private var duration: Double { Double.random(in: 0.4...0.9) }

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: 2, height: CGFloat.random(in: 12...24))
            .shadow(color: color.opacity(0.8), radius: 4)
            .position(x: xPos, y: -30 + offset)
            .opacity(opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    opacity = 0.85
                    withAnimation(.linear(duration: duration).repeatCount(4, autoreverses: false)) {
                        offset = screenHeight + 50
                    }
                }
            }
    }
}

// MARK: - Full Screen Cosmic Sparkle

/// Stars and sparkles burst across the entire screen
private struct FullScreenCosmicSparkle: View {
    @State private var sparkles: [SparkleParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(sparkles) { sparkle in
                    CosmicSparkleParticle(sparkle: sparkle)
                }
            }
            .onAppear {
                // Generate sparkle positions across the screen
                var particles: [SparkleParticle] = []
                for i in 0..<30 {
                    particles.append(SparkleParticle(
                        id: i,
                        x: CGFloat.random(in: 20...geo.size.width - 20),
                        y: CGFloat.random(in: 40...geo.size.height - 40),
                        size: CGFloat.random(in: 8...24),
                        delay: Double.random(in: 0...0.8),
                        color: [Color.white, .neonGold, .neonCyan, .neonMagenta, .neonPurple][i % 5]
                    ))
                }
                sparkles = particles
            }
        }
        .ignoresSafeArea()
    }
}

private struct SparkleParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let delay: Double
    let color: Color
}

private struct CosmicSparkleParticle: View {
    let sparkle: SparkleParticle
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: sparkle.size))
            .foregroundColor(sparkle.color)
            .shadow(color: sparkle.color.opacity(0.8), radius: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .position(x: sparkle.x, y: sparkle.y)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + sparkle.delay) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        scale = 1.2
                        opacity = 1.0
                        rotation = 45
                    }
                    // Fade out
                    DispatchQueue.main.asyncAfter(deadline: .now() + sparkle.delay + 1.0) {
                        withAnimation(.easeIn(duration: 0.6)) {
                            scale = 0.3
                            opacity = 0
                            rotation = 90
                        }
                    }
                }
            }
    }
}
