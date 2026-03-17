import SwiftUI

struct SubscriptionOfferView: View {

    let onNext: () -> Void

    @EnvironmentObject var environment: AppEnvironment
    @State private var isPurchasing = false
    @State private var selectedPlan: PricingPlan = .yearly
    @State private var showPurchaseError = false
    @State private var purchaseErrorMessage = ""

    enum PricingPlan: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
    }

    private let premiumFeatures: [(icon: String, title: String, description: String)] = [
        ("chart.bar.xaxis", "Advanced Analytics", "Deep insights into your progress with charts and trends."),
        ("infinity", "Unlimited Habits", "Track as many habits as you need, all in one place."),
        ("quote.bubble.fill", "4x Daily Motivation", "Personalized motivational quotes sent to your phone."),
        ("trophy.fill", "Rewards & Collectibles", "Earn Surges, unlock collectibles, build your trophy case."),
        ("map.fill", "Coaching Plans", "Structured day-by-day plans tailored to your habit."),
        ("rosette", "Unlock All Badges", "Access every achievement badge available for you to earn throughout your journey.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header with glow
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
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppStyle.largeSpacing)

                // Feature list
                VStack(spacing: 0) {
                    ForEach(Array(premiumFeatures.enumerated()), id: \.offset) { index, feature in
                        featureRow(icon: feature.icon, title: feature.title, description: feature.description)

                        if index < premiumFeatures.count - 1 {
                            Divider()
                                .background(Color.cardBorder)
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [.neonGold, .neonOrange, .neonMagenta, .neonPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .opacity(0.4)
                )
                .padding(.horizontal, AppStyle.screenPadding)

                // Pricing cards
                HStack(spacing: 10) {
                    pricingCard(plan: .monthly, price: "$4.99", period: "/mo", savings: nil)
                    pricingCard(plan: .yearly, price: "$29.99", period: "/yr", savings: "Save 50%")
                    pricingCard(plan: .lifetime, price: "$59.99", period: "once", savings: "Best Value")
                }
                .padding(.horizontal, AppStyle.screenPadding)

                // CTA Button
                VStack(spacing: 8) {
                    Button {
                        startPurchase()
                    } label: {
                        HStack(spacing: 8) {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(selectedPlan == .lifetime ? "Purchase Lifetime" : "Start Free Trial")
                        }
                    }
                    .buttonStyle(GoldButtonStyle())
                    .disabled(isPurchasing)

                    if selectedPlan != .lifetime {
                        Text("7-day free trial, then \(selectedPlan == .monthly ? "$4.99/mo" : "$29.99/yr")")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Text("Cancel anytime. No commitment.")
                        .font(Typography.footnote)
                        .foregroundColor(.textSecondary.opacity(0.7))
                }
                .padding(.horizontal, AppStyle.screenPadding)

                // Skip link
                Button {
                    onNext()
                } label: {
                    Text("Continue with Free")
                        .font(Typography.callout)
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, AppStyle.largeSpacing)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .alert("Purchase Issue", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseErrorMessage)
        }
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
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)

                Text(period)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)

                Text(plan.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .neonGold : .textSecondary)
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

    // MARK: - Feature Row

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: AppStyle.spacing) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.neonGold)
                .frame(width: 36, height: 36)
                .background(Color.neonGold.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, AppStyle.cardPadding)
        .padding(.vertical, 12)
    }

    // MARK: - Purchase

    private func startPurchase() {
        let productId: String
        switch selectedPlan {
        case .monthly:  productId = "com.resurge.premium.monthly"
        case .yearly:   productId = "com.resurge.premium.yearly"
        case .lifetime: productId = "com.resurge.premium.lifetime"
        }

        guard let product = environment.entitlementManager.availableProducts.first(where: {
            $0.id == productId
        }) else {
            purchaseErrorMessage = "Unable to load products. Please check your connection and try again."
            showPurchaseError = true
            return
        }

        isPurchasing = true
        Task {
            let result = await environment.entitlementManager.purchase(product)
            await MainActor.run {
                isPurchasing = false
                switch result {
                case .success, .pending:
                    onNext()
                case .cancelled:
                    break
                case .failed(let error):
                    purchaseErrorMessage = "Purchase failed: \(error.localizedDescription). Please try again."
                    showPurchaseError = true
                }
            }
        }
    }
}

// MARK: - Preview

struct SubscriptionOfferView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionOfferView(onNext: {})
            .environmentObject(AppEnvironment.preview)
    }
}
