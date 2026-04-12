import SwiftUI

struct SubscriptionStatusView: View {
    @EnvironmentObject var environment: AppEnvironment

    @State private var isPurchasing = false
    @State private var selectedPlan: PricingPlan = .yearly

    enum PricingPlan: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
    }

    private var currentPlan: String {
        environment.entitlementManager.subscriptionStatus.displayName
    }

    private var isPremium: Bool {
        environment.entitlementManager.isPremium
    }

    private struct FeatureRow: Identifiable {
        let id = UUID()
        let name: String
        let freeIncluded: Bool
        let premiumIncluded: Bool
    }

    private let featureComparison: [FeatureRow] = [
        FeatureRow(name: "Track 1 habit", freeIncluded: true, premiumIncluded: true),
        FeatureRow(name: "Daily loop (3 check-ins)", freeIncluded: true, premiumIncluded: true),
        FeatureRow(name: "Craving tools & emergency", freeIncluded: true, premiumIncluded: true),
        FeatureRow(name: "Journal & basic badges", freeIncluded: true, premiumIncluded: true),
        FeatureRow(name: "1 daily motivational quote", freeIncluded: true, premiumIncluded: true),
        FeatureRow(name: "Earn Surges (15/day)", freeIncluded: true, premiumIncluded: true),
        FeatureRow(name: "Unlimited habits", freeIncluded: false, premiumIncluded: true),
        FeatureRow(name: "Advanced analytics", freeIncluded: false, premiumIncluded: true),
        FeatureRow(name: "5x daily motivation", freeIncluded: false, premiumIncluded: true),
        FeatureRow(name: "Daily coaching", freeIncluded: false, premiumIncluded: true),
        FeatureRow(name: "Unlock all badges", freeIncluded: false, premiumIncluded: true),
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    if isPremium {
                        premiumUserSection
                    } else {
                        freeUserUpgradeSection
                    }

                    // MARK: - Feature Comparison
                    featureComparisonSection

                    // MARK: - Manage Subscription
                    if isPremium {
                        Button {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Manage Subscription")
                                .font(.subheadline)
                                .foregroundColor(.neonCyan)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Free User Upgrade Section

    private var freeUserUpgradeSection: some View {
        VStack(spacing: 20) {
            // Crown icon with rainbow glow
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.neonGold.opacity(0.2), Color.neonOrange.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 15)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.neonGold, .neonOrange, .neonMagenta],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .neonGold.opacity(0.5), radius: 12, x: 0, y: 0)
                }

                Text("Unlock Premium")
                    .font(Typography.largeTitle)
                    .rainbowText()

                Text("Get the most out of your recovery journey.")
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Pricing cards
            HStack(spacing: 10) {
                pricingCard(plan: .monthly, price: "$4.99", period: "/mo", savings: nil)
                pricingCard(plan: .yearly, price: "$39.99", period: "/yr", savings: "Save 33%")
                pricingCard(plan: .lifetime, price: "$99.99", period: "once", savings: "Best Value")
            }
            .padding(.horizontal)

            // Purchase button
            VStack(spacing: 8) {
                Button {
                    startPurchase()
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
                .buttonStyle(RainbowButtonStyle())
                .disabled(isPurchasing)

                VStack(spacing: 4) {
                    Text("Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Payment is charged to your Apple ID account.")
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
            .padding(.horizontal)
        }
    }

    // MARK: - Premium User Section

    private var premiumUserSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundColor(.neonGold)

            Text("Current Plan")
                .font(.subheadline)
                .foregroundColor(.subtleText)

            Text(currentPlan)
                .font(.title.weight(.bold))
                .foregroundColor(.appText)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        .padding(.horizontal)
    }

    // MARK: - Feature Comparison Section

    private var featureComparisonSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Feature")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.subtleText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Free")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.subtleText)
                    .frame(width: 50)
                Text("Premium")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.neonGold)
                    .frame(width: 70)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            ForEach(featureComparison) { feature in
                HStack {
                    Text(feature.name)
                        .font(.subheadline)
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: feature.freeIncluded ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(feature.freeIncluded ? .neonCyan : .subtleText.opacity(0.4))
                        .frame(width: 50)
                    Image(systemName: feature.premiumIncluded ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(feature.premiumIncluded ? .neonGold : .subtleText.opacity(0.4))
                        .frame(width: 70)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                Divider()
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        .padding(.horizontal)
    }

    // MARK: - Pricing Card

    private func pricingCard(plan: PricingPlan, price: String, period: String, savings: String?) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlan = plan
            }
        } label: {
            VStack(spacing: 6) {
                if let savings = savings {
                    Text(savings)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(plan == .lifetime ? .appBackground : .neonGold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(plan == .lifetime ? Color.neonGold : Color.neonGold.opacity(0.2))
                        .cornerRadius(4)
                } else {
                    Spacer().frame(height: 16)
                }

                Text(price)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .appText : .subtleText)

                Text(period)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)

                Text(plan.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .neonGold : .subtleText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.neonGold.opacity(0.1) : Color.cardBackground)
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(isSelected ? Color.neonGold : Color.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
    }

    // MARK: - Purchase

    private func startPurchase() {
        let productId: String
        switch selectedPlan {
        case .monthly:  productId = "com.looproot.premium.monthly"
        case .yearly:   productId = "com.looproot.premium.yearly"
        case .lifetime: productId = "com.looproot.premium.lifetime"
        }

        guard let product = environment.entitlementManager.availableProducts.first(where: {
            $0.id == productId
        }) else {
            return
        }

        isPurchasing = true
        Task {
            _ = await environment.entitlementManager.purchase(product)
            await MainActor.run {
                isPurchasing = false
            }
        }
    }
}

// MARK: - Preview

struct SubscriptionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            SubscriptionStatusView()
                .environmentObject(env)
        }
    }
}
