import SwiftUI

struct PremiumGateView: View {

    let featureName: String
    let featureDescription: String
    let onUnlock: () -> Void
    let onDismiss: () -> Void

    @EnvironmentObject var environment: AppEnvironment
    @State private var isPurchasing = false

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Card
            VStack(spacing: AppStyle.largeSpacing) {
                // Lock icon with rainbow ring
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold, .neonCyan],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 4)
                        .opacity(0.5)

                    Circle()
                        .fill(Color.premiumGold.opacity(0.1))
                        .frame(width: 90, height: 90)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.neonGold, .neonOrange, .neonMagenta],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                // Title
                Text("Premium Feature")
                    .font(Typography.largeTitle)
                    .rainbowText()

                // Feature name
                Text(featureName)
                    .font(Typography.headline)
                    .foregroundColor(.primaryTeal)

                // Description
                Text(featureDescription)
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppStyle.screenPadding)

                // Unlock button
                VStack(spacing: AppStyle.spacing) {
                    Button {
                        unlockPremium()
                    } label: {
                        HStack(spacing: 8) {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            }
                            Image(systemName: "crown.fill")
                            Text("Unlock Premium")
                        }
                    }
                    .buttonStyle(GoldButtonStyle())
                    .disabled(isPurchasing)

                    Text("7-day free trial, then $4.99/mo")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .padding(.horizontal, AppStyle.screenPadding)

                // Dismiss
                Button {
                    onDismiss()
                } label: {
                    Text("Not Now")
                        .font(Typography.callout)
                        .foregroundColor(.subtleText)
                }
            }
            .padding(AppStyle.largeSpacing)
            .background(Color.cardBackground)
            .cornerRadius(AppStyle.cornerRadius * 1.5)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius * 1.5)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan, .neonPurple, .neonMagenta, .neonGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .opacity(0.3)
            )
            .shadow(color: Color.neonPurple.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    // MARK: - Purchase

    private func unlockPremium() {
        guard let monthlyProduct = environment.entitlementManager.availableProducts.first(where: {
            $0.id == "com.looproot.premium.monthly"
        }) else {
            onDismiss()
            return
        }

        isPurchasing = true
        Task {
            let result = await environment.entitlementManager.purchase(monthlyProduct)
            await MainActor.run {
                isPurchasing = false
                switch result {
                case .success:
                    onUnlock()
                case .pending, .cancelled, .failed:
                    break
                }
            }
        }
    }
}

// MARK: - View Modifier

struct PremiumGateModifier: ViewModifier {
    let isPresented: Bool
    let featureName: String
    let featureDescription: String
    let onUnlock: () -> Void
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                PremiumGateView(
                    featureName: featureName,
                    featureDescription: featureDescription,
                    onUnlock: onUnlock,
                    onDismiss: onDismiss
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented)
            }
        }
    }
}

extension View {
    func premiumGate(
        isPresented: Bool,
        featureName: String,
        featureDescription: String,
        onUnlock: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(PremiumGateModifier(
            isPresented: isPresented,
            featureName: featureName,
            featureDescription: featureDescription,
            onUnlock: onUnlock,
            onDismiss: onDismiss
        ))
    }
}

// MARK: - Preview

struct PremiumGateView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            Text("Content Behind Gate")
                .font(Typography.title)

            PremiumGateView(
                featureName: "Advanced Analytics",
                featureDescription: "Deep insights into your progress with charts and trends.",
                onUnlock: {},
                onDismiss: {}
            )
        }
        .environmentObject(AppEnvironment.preview)
    }
}
