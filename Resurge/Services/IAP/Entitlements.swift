import Foundation
import SwiftUI

final class EntitlementManager: ObservableObject {

    @Published var isPremium: Bool {
        didSet {
            // Always sync to UserDefaults so @AppStorage("isPremium") views stay in sync
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }

    private let provider: IAPProviderProtocol

    private static let freeHabitLimit = 1

    init(provider: IAPProviderProtocol) {
        self.provider = provider
        self.isPremium = provider.isPremium
        // Sync initial state to UserDefaults
        UserDefaults.standard.set(provider.isPremium, forKey: "isPremium")
    }

    // MARK: - Feature Check

    func check(_ feature: PremiumFeature) -> Bool {
        if isPremium { return true }

        // Some features are available to free users
        switch feature {
        case .dailyMotivation,
             .virtualCompanion:
            return true // Free — keeps users engaged
        case .biometricLock,
             .advancedAnalytics,
             .unlimitedHabits,
             .recoveryLibrary,
             .rewardSystem,
             .coachingPlans:
            return false
        }
    }

    // MARK: - Habit Limit

    func canAddHabit(currentCount: Int) -> Bool {
        if isPremium { return true }
        return currentCount < Self.freeHabitLimit
    }

    // MARK: - Refresh

    func refresh() {
        isPremium = provider.isPremium
    }

    // MARK: - Current Status

    var subscriptionStatus: SubscriptionStatus {
        provider.subscriptionStatus
    }

    var availableProducts: [PurchaseProduct] {
        provider.availableProducts
    }

    func purchase(_ product: PurchaseProduct) async -> PurchaseResult {
        let result = await provider.purchase(product)
        if case .success = result {
            await MainActor.run { isPremium = provider.isPremium }
        }
        return result
    }

    func restorePurchases() async {
        await provider.restorePurchases()
        await MainActor.run { isPremium = provider.isPremium }
    }
}
