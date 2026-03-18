import SwiftUI

struct WelcomeView: View {

    let onNext: () -> Void

    @State private var glowScale: CGFloat = 0.9
    @State private var particlesVisible = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            // Background sparkle particles
            if particlesVisible {
                SparkleParticlesView(count: 30)
                    .opacity(0.6)
                    .ignoresSafeArea()
            }

            VStack(spacing: AppStyle.largeSpacing) {
                Spacer()

                // App icon — rainbow glow rings
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold, .neonCyan],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 8)
                        .opacity(0.5)
                        .scaleEffect(glowScale)

                    Image("WelcomeLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .scaleEffect(1.15)
                        .clipShape(Circle())
                        .shadow(color: .neonPurple.opacity(0.4), radius: 20)
                        .shadow(color: .neonCyan.opacity(0.3), radius: 30)
                }
                .padding(.bottom, AppStyle.spacing)

                // Title
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(Typography.title)
                        .foregroundColor(.appText)

                    Text("LoopRoot")
                        .font(Typography.largeTitle)
                        .rainbowText()
                }

                // Subtitle
                Text("Stay in the loop. Find your root.")
                    .font(Typography.headline)
                    .foregroundColor(.neonGold)

                // Description
                Text("Take control of the habits that hold you back. LoopRoot helps you track your progress, stay motivated, and build the life you deserve — one day at a time.")
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppStyle.screenPadding)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Get Started button — rainbow
                Button(action: onNext) {
                    Text("Get Started")
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, AppStyle.largeSpacing)
            }
        }
        .onAppear {
            particlesVisible = true
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                glowScale = 1.05
            }
        }
    }
}

// MARK: - Preview

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(onNext: {})
            .preferredColorScheme(.dark)
    }
}
