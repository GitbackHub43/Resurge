import SwiftUI

struct SurgesIntroView: View {
    let onNext: () -> Void

    @State private var shimmer = false
    @State private var iconBounce: CGFloat = 0

    private let rewardItems: [(name: String, color: Color)] = [
        ("Owlet", .neonCyan),
        ("Cosmic Sparkle", .neonMagenta),
        ("Ultraviolet", .neonPurple),
        ("Watch Skins", .neonPurple),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer().frame(height: 10)

                // Surges icon
                ZStack {
                    Circle()
                        .fill(Color.neonGold.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold, .neonCyan],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(shimmer ? 360 : 0))

                    Image(systemName: "diamond.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.neonGold)
                        .shadow(color: .neonGold.opacity(0.6), radius: 12)
                        .offset(y: iconBounce)
                }

                // Title
                VStack(spacing: 8) {
                    Text("Introducing")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                        .tracking(2)
                        .textCase(.uppercase)

                    Text("Surges")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .rainbowText()

                    Text("Your recovery reward currency")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                }

                // How it works
                VStack(spacing: 16) {
                    howItWorksRow(
                        icon: "sunrise.fill",
                        color: .neonGold,
                        title: "Morning Plan",
                        subtitle: "+5 Surges"
                    )
                    howItWorksRow(
                        icon: "sun.max.fill",
                        color: .neonCyan,
                        title: "Afternoon Check-In",
                        subtitle: "+5 Surges"
                    )
                    howItWorksRow(
                        icon: "moon.stars.fill",
                        color: .neonPurple,
                        title: "Evening Review",
                        subtitle: "+5 Surges"
                    )

                    HStack {
                        Spacer()
                        Text("= 15 Surges per day")
                            .font(Typography.headline)
                            .foregroundColor(.neonGold)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
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
                        .opacity(0.4)
                )
                .padding(.horizontal, AppStyle.screenPadding)

                // Where they're stored
                HStack(spacing: 12) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.neonGold)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vault Shop")
                            .font(Typography.headline)
                            .foregroundColor(.appText)
                        Text("Spend your Surges on rewards in the Vault Shop, found in your Achievements tab.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }
                }
                .padding(AppStyle.cardPadding)
                .background(Color.neonGold.opacity(0.06))
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonGold.opacity(0.25), lineWidth: 1)
                )
                .padding(.horizontal, AppStyle.screenPadding)

                // What you can unlock — animated previews
                VStack(spacing: 12) {
                    Text("What you can unlock")
                        .font(Typography.headline)
                        .foregroundColor(.appText)

                    HStack(spacing: 0) {
                        // Owlet pet
                        VStack(spacing: 6) {
                            OwlPetView(size: 50)
                                .frame(width: 54, height: 54)
                            Text("Owlet")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.subtleText)
                        }
                        .frame(maxWidth: .infinity)

                        // Cosmic Sparkle celebration
                        VStack(spacing: 6) {
                            CosmicSparkleOnboardingPreview()
                                .frame(width: 54, height: 54)
                            Text("Celebrations")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.subtleText)
                        }
                        .frame(maxWidth: .infinity)

                        // Ultraviolet theme
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(
                                    colors: [Color(hex: "0E0520"), Color(hex: "E040FB"), Color(hex: "AA00FF"), Color(hex: "FF4081")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 50)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
                            Text("Themes")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.subtleText)
                        }
                        .frame(maxWidth: .infinity)

                        // Watch Skins
                        VStack(spacing: 6) {
                            WatchSkinOnboardingPreview()
                                .frame(width: 54, height: 54)
                            Text("Watch Skins")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.subtleText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
                .padding(.horizontal, AppStyle.screenPadding)

                // Start button
                Button {
                    onNext()
                } label: {
                    HStack(spacing: 8) {
                        Text("Let's Go!")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.top, 8)

                Spacer().frame(height: 20)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                shimmer = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                iconBounce = -6
            }
        }
    }

    private func howItWorksRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }

            Text(title)
                .font(Typography.body)
                .foregroundColor(.appText)

            Spacer()

            Text(subtitle)
                .font(Typography.headline)
                .foregroundColor(.neonGold)
        }
    }
}

// MARK: - Animated Onboarding Previews

private struct CosmicSparkleOnboardingPreview: View {
    @State private var twinkle = false
    var body: some View {
        ZStack {
            Circle().fill(Color(hex: "0A0A2E")).frame(width: 48, height: 48)
            Image(systemName: "sparkle").font(.system(size: 6)).foregroundColor(.white).offset(x: -12, y: -10).opacity(twinkle ? 0.3 : 1)
            Image(systemName: "sparkle").font(.system(size: 8)).foregroundColor(.neonGold).offset(x: 10, y: -14).opacity(twinkle ? 1 : 0.3)
            Image(systemName: "sparkle").font(.system(size: 5)).foregroundColor(.neonCyan).offset(x: -8, y: 12).opacity(twinkle ? 0.4 : 0.9)
            Image(systemName: "sparkle").font(.system(size: 7)).foregroundColor(.neonMagenta).offset(x: 12, y: 8).opacity(twinkle ? 0.8 : 0.2)
            Image(systemName: "sparkle").font(.system(size: 10)).foregroundColor(.white).offset(x: 0, y: 0).opacity(twinkle ? 0.5 : 1).scaleEffect(twinkle ? 0.8 : 1.2)
        }
        .onAppear { withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { twinkle = true } }
    }
}

private struct WatchSkinOnboardingPreview: View {
    @State private var rainbowPhase: CGFloat = 0
    var body: some View {
        ZStack {
            Circle().fill(Color(hex: "0A0A2E")).frame(width: 48, height: 48)
            Circle()
                .stroke(
                    AngularGradient(colors: [.neonCyan, .neonPurple, .neonMagenta, .neonGold, .neonCyan], center: .center, startAngle: .degrees(rainbowPhase), endAngle: .degrees(rainbowPhase + 360)),
                    lineWidth: 2.5
                )
                .frame(width: 42, height: 42)
            Image(systemName: "clock.fill").font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(colors: [.neonCyan, .neonPurple, .neonMagenta, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
        .onAppear { withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) { rainbowPhase = 360 } }
    }
}
