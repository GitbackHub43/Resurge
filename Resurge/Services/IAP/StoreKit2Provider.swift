import Foundation
import StoreKit

final class StoreKit2Provider: IAPProviderProtocol {

    private static let productIdentifiers: Set<String> = [
        "com.looproot.premium.monthly",
        "com.looproot.premium.yearly",
        "com.looproot.premium.lifetime",
    ]

    private var storeProducts: [Product] = []
    private var purchasedProductIDs: Set<String> = []
    private var transactionListener: Task<Void, Error>?

    var isPremium: Bool {
        subscriptionStatus.isPaid
    }

    var subscriptionStatus: SubscriptionStatus {
        if purchasedProductIDs.contains(where: { $0.contains("lifetime") }) {
            return .lifetime
        } else if purchasedProductIDs.contains(where: { $0.contains("yearly") }) {
            return .yearly
        } else if purchasedProductIDs.contains(where: { $0.contains("monthly") }) {
            return .monthly
        }
        return .free
    }

    var availableProducts: [PurchaseProduct] {
        storeProducts.map { product in
            let tier: SubscriptionStatus
            if product.id.contains("lifetime") {
                tier = .lifetime
            } else if product.id.contains("yearly") {
                tier = .yearly
            } else {
                tier = .monthly
            }
            var trialDays: Int?
            if let intro = product.subscription?.introductoryOffer,
               intro.paymentMode == .freeTrial {
                trialDays = intro.period.value * (intro.period.unit == .day ? 1 : intro.period.unit == .week ? 7 : 30)
            }
            return PurchaseProduct(
                id: product.id,
                displayName: product.displayName,
                displayPrice: product.displayPrice,
                tier: tier,
                trialDays: trialDays
            )
        }
    }

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Purchase

    func purchase(_ product: PurchaseProduct) async -> PurchaseResult {
        guard let storeProduct = storeProducts.first(where: { $0.id == product.id }) else {
            return .failed(NSError(domain: "StoreKit2", code: -1,
                                   userInfo: [NSLocalizedDescriptionKey: "Product not found"]))
        }

        do {
            let result = try await storeProduct.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchasedProductIDs.insert(transaction.productID)
                return .success
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .cancelled
            }
        } catch {
            return .failed(error)
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        await updatePurchasedProducts()
    }

    // MARK: - Private

    private func loadProducts() async {
        do {
            storeProducts = try await Product.products(for: Self.productIdentifiers)
        } catch {
            print("StoreKit2 failed to load products: \(error.localizedDescription)")
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    self?.purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
