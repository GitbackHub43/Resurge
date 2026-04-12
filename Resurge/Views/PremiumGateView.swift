import SwiftUI

struct PremiumGateView: View {

    let featureName: String
    let featureDescription: String
    let onUnlock: () -> Void
    let onDismiss: () -> Void

    @EnvironmentObject var environment: AppEnvironment
    @State private var isPurchasing = false
    @State private var selectedPlan: PricingPlan = .yearly

    enum PricingPlan: String {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
    }

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

                // Pricing options
                HStack(spacing: 8) {
                    planButton(plan: .monthly, price: "$4.99", period: "/mo")
                    planButton(plan: .yearly, price: "$39.99", period: "/yr")
                    planButton(plan: .lifetime, price: "$99.99", period: "once")
                }

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
                            Text(selectedPlan == .lifetime ? "Purchase Lifetime" : "Subscribe Now")
                        }
                    }
                    .buttonStyle(GoldButtonStyle())
                    .disabled(isPurchasing)

                    VStack(spacing: 4) {
                        Text("Subscriptions auto-renew unless cancelled 24hrs before period ends.")
                            .font(.system(size: 9))
                            .foregroundColor(.subtleText.opacity(0.6))
                            .multilineTextAlignment(.center)

                        HStack(spacing: 12) {
                            Link("Privacy Policy", destination: URL(string: "http://thryvenex.com/LoopRoot-Support-legal/privacy-policy.html")!)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.neonCyan)
                            Text("·").foregroundColor(.subtleText.opacity(0.4))
                            Link("Terms of Use", destination: URL(string: "http://thryvenex.com/LoopRoot-Support-legal/terms-of-service.html")!)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.neonCyan)
                        }
                    }
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

    private func planButton(plan: PricingPlan, price: String, period: String) -> some View {
        let isSelected = selectedPlan == plan
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedPlan = plan }
        } label: {
            VStack(spacing: 4) {
                Text(price)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .textPrimary : .subtleText)
                Text(period)
                    .font(.system(size: 10))
                    .foregroundColor(.subtleText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.neonGold.opacity(0.1) : Color.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.neonGold : Color.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
    }

    private func unlockPremium() {
        let productId: String
        switch selectedPlan {
        case .monthly:  productId = "com.looproot.premium.monthly"
        case .yearly:   productId = "com.looproot.premium.yearly"
        case .lifetime: productId = "com.looproot.premium.lifetime"
        }

        guard let product = environment.entitlementManager.availableProducts.first(where: {
            $0.id == productId
        }) else {
            onDismiss()
            return
        }

        isPurchasing = true
        Task {
            let result = await environment.entitlementManager.purchase(product)
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
