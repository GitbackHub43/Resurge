import SwiftUI

// MARK: - ShimmerEffect

/// A diagonal light sweep across the badge surface.
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    let isActive: Bool

    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geo in
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: geo.size.width * 2)
                .offset(x: phase * geo.size.width * 2)
                .mask(content)
            }
            .allowsHitTesting(false)
        )
        .onAppear {
            guard isActive else { return }
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

extension View {
    func shimmerEffect(isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
}

// MARK: - FlameFlicker

/// Random scale/rotation micro-variations for flame badges.
struct FlameFlickerModifier: ViewModifier {
    @State private var flickerScale: CGFloat = 1.0
    @State private var flickerRotation: Double = 0
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? flickerScale : 1.0)
            .rotationEffect(.degrees(isActive ? flickerRotation : 0))
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    flickerScale = 1.08
                }
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    flickerRotation = 3
                }
            }
    }
}

extension View {
    func flameFlicker(isActive: Bool = true) -> some View {
        modifier(FlameFlickerModifier(isActive: isActive))
    }
}

// MARK: - GlowPulse

/// Pulsing glow shadow effect for badge emphasis.
struct GlowPulseModifier: ViewModifier {
    @State private var glowIntensity: Double = 0.3
    let color: Color
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(glowIntensity) : .clear, radius: isActive ? 12 : 0)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowIntensity = 0.7
                }
            }
    }
}

extension View {
    func glowPulse(color: Color, isActive: Bool = true) -> some View {
        modifier(GlowPulseModifier(color: color, isActive: isActive))
    }
}

// MARK: - SpinRing

/// Rotating ring overlay for premium or special badges.
struct SpinRingModifier: ViewModifier {
    @State private var rotation: Double = 0
    let color: Color
    let isActive: Bool
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content.overlay(
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    color.opacity(isActive ? 0.5 : 0),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    guard isActive else { return }
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        )
    }
}

extension View {
    func spinRing(color: Color, lineWidth: CGFloat = 2, isActive: Bool = true) -> some View {
        modifier(SpinRingModifier(color: color, isActive: isActive, lineWidth: lineWidth))
    }
}

// MARK: - RadialBurst

/// Sparkle particles bursting outward for unlock moments.
struct RadialBurstView: View {
    let color: Color
    @State private var burst = false
    let particleCount: Int

    init(color: Color, particleCount: Int = 8) {
        self.color = color
        self.particleCount = particleCount
    }

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .offset(
                        x: burst ? CGFloat(cos(Double(i) * 2 * .pi / Double(particleCount))) * 40 : 0,
                        y: burst ? CGFloat(sin(Double(i) * 2 * .pi / Double(particleCount))) * 40 : 0
                    )
                    .opacity(burst ? 0 : 0.8)
                    .scaleEffect(burst ? 0.3 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                burst = true
            }
        }
    }
}

// MARK: - TierRings

/// Concentric rings for tiered track badges.
struct TierRingsView: View {
    let tier: Int  // 1-4
    let color: Color
    @State private var ringScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            ForEach(0..<tier, id: \.self) { i in
                Circle()
                    .stroke(
                        color.opacity(Double(tier - i) / Double(tier) * 0.6),
                        lineWidth: 1.5
                    )
                    .frame(
                        width: CGFloat(20 + i * 12),
                        height: CGFloat(20 + i * 12)
                    )
                    .scaleEffect(ringScale)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                ringScale = 1.05
            }
        }
    }
}
