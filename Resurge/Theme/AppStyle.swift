import SwiftUI

enum AppStyle {
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
    static let spacing: CGFloat = 12
    static let largeSpacing: CGFloat = 24
    static let iconSize: CGFloat = 24
    static let avatarSize: CGFloat = 44
    static let progressRingSize: CGFloat = 120
    static let progressRingLineWidth: CGFloat = 10

    static let cardShadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.neonPurple.opacity(0.12), 10, 0, 4
    )
}

// MARK: - Neon Card Modifier

struct NeonCardModifier: ViewModifier {
    var glowColor: Color = .neonCyan

    func body(content: Content) -> some View {
        content
            .padding(AppStyle.cardPadding)
            .background(Color.cardBackground)
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(glowColor.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: glowColor.opacity(0.12), radius: 10, x: 0, y: 4)
    }
}

/// A card with a rainbow-gradient border glow
struct RainbowCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppStyle.cardPadding)
            .background(Color.cardBackground)
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .opacity(0.5)
            )
            .shadow(color: Color.neonPurple.opacity(0.1), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func neonCard(glow: Color = .neonCyan) -> some View {
        self.modifier(NeonCardModifier(glowColor: glow))
    }

    func rainbowCard() -> some View {
        self.modifier(RainbowCardModifier())
    }
}

// MARK: - Primary Button (Gradient Glow)

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .neonCyan

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppStyle.cornerRadius)
            .shadow(color: color.opacity(configuration.isPressed ? 0.2 : 0.45), radius: 14, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Rainbow Primary Button

struct RainbowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppStyle.cornerRadius)
            .shadow(color: Color.neonPurple.opacity(configuration.isPressed ? 0.2 : 0.5), radius: 16, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button (Outline Glow)

struct SecondaryButtonStyle: ButtonStyle {
    var color: Color = .neonCyan

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(color.opacity(0.08))
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(color.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 2)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Gold / Premium Button

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [.neonGold, .neonOrange, .neonMagenta],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppStyle.cornerRadius)
            .shadow(color: Color.neonGold.opacity(configuration.isPressed ? 0.2 : 0.5), radius: 14, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Emergency Button Style

struct EmergencyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [.neonOrange, .neonMagenta, .neonPurple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppStyle.cornerRadius)
            .shadow(color: Color.neonMagenta.opacity(configuration.isPressed ? 0.3 : 0.5), radius: 16, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Sparkle Particle View (mimics the logo's floating light dots)

struct SparkleParticlesView: View {
    let particleCount: Int
    let colors: [Color]

    init(count: Int = 20, colors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]) {
        self.particleCount = count
        self.colors = colors
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { i in
                    Circle()
                        .fill(colors[i % colors.count])
                        .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .opacity(Double.random(in: 0.2...0.7))
                        .blur(radius: CGFloat.random(in: 0...2))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Rainbow Divider

struct RainbowDivider: View {
    var height: CGFloat = 1

    var body: some View {
        LinearGradient(
            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: height)
        .opacity(0.5)
    }
}

// MARK: - Rainbow Text Modifier

struct RainbowTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
            )
    }
}

extension View {
    func rainbowText() -> some View {
        self.modifier(RainbowTextModifier())
    }
}
