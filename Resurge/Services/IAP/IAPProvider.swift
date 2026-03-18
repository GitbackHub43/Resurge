import Foundation

// MARK: - PurchaseProduct

struct PurchaseProduct: Identifiable, Equatable {
    let id: String
    let displayName: String
    let displayPrice: String
    let tier: SubscriptionStatus
    let trialDays: Int?

    static func == (lhs: PurchaseProduct, rhs: PurchaseProduct) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - PurchaseResult

enum PurchaseResult {
    case success
    case pending
    case cancelled
    case failed(Error)
}

// MARK: - IAPProviderProtocol

protocol IAPProviderProtocol {
    var isPremium: Bool { get }
    var subscriptionStatus: SubscriptionStatus { get }
    var availableProducts: [PurchaseProduct] { get }

    func purchase(_ product: PurchaseProduct) async -> PurchaseResult
    func restorePurchases() async
}

// MARK: - MockIAPProvider

final class MockIAPProvider: IAPProviderProtocol {

    var isPremium: Bool {
        subscriptionStatus.isPaid
    }

    var subscriptionStatus: SubscriptionStatus = .free

    var availableProducts: [PurchaseProduct] {
        [
            PurchaseProduct(
                id: "com.looproot.premium.monthly",
                displayName: "Premium Monthly",
                displayPrice: "$4.99/mo",
                tier: .monthly,
                trialDays: 7
            ),
            PurchaseProduct(
                id: "com.looproot.premium.yearly",
                displayName: "Premium Yearly",
                displayPrice: "$29.99/yr",
                tier: .yearly,
                trialDays: 7
            ),
            PurchaseProduct(
                id: "com.looproot.lifetime",
                displayName: "Lifetime",
                displayPrice: "$59.99",
                tier: .lifetime,
                trialDays: nil
            ),
        ]
    }

    func purchase(_ product: PurchaseProduct) async -> PurchaseResult {
        // Simulate a short delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        subscriptionStatus = product.tier
        return .success
    }

    func restorePurchases() async {
        // Simulate a short delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        // In mock mode, nothing to restore
    }
}
