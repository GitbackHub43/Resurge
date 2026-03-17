import StoreKit
import CoreData

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var activeTier: SubscriptionTier = .free
    @Published var availableProducts: [Product] = []
    private var transactionListener: Task<Void, Error>?

    enum SubscriptionTier: Int16 {
        case free = 0, proMonthly = 1, proYearly = 2, proLifetime = 3
        var isPro: Bool { self != .free }
    }

    private let productIDs: Set<String> = [
        "com.resurge.premium.monthly",
        "com.resurge.premium.yearly",
        "com.resurge.premium.lifetime"
    ]

    func start(context: NSManagedObjectContext) {
        transactionListener = listenForTransactions(context: context)
        Task { await loadProducts(); await refreshEntitlements(context: context) }
    }

    private func loadProducts() async {
        availableProducts = (try? await Product.products(for: productIDs)) ?? []
    }

    func refreshEntitlements(context: NSManagedObjectContext) async {
        var purchasedIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result {
                purchasedIDs.insert(tx.productID)
                await tx.finish()
            }
        }

        // Determine tier
        let tier: SubscriptionTier
        if purchasedIDs.contains("com.resurge.premium.lifetime") {
            tier = .proLifetime
        } else if purchasedIDs.contains("com.resurge.premium.yearly") {
            tier = .proYearly
        } else if purchasedIDs.contains("com.resurge.premium.monthly") {
            tier = .proMonthly
        } else {
            tier = .free
        }

        activeTier = tier
        UserDefaults.standard.set(tier.isPro, forKey: "isPremium")

        // Persist to CDSubscriptionEntitlement
        let entitlement = CDSubscriptionEntitlement.fetchOrCreate(in: context)
        entitlement.activeTier = tier.rawValue
        entitlement.entitledProductIDs = try? String(data: JSONEncoder().encode(Array(purchasedIDs)), encoding: .utf8)
        entitlement.lastVerifiedAt = Date()
        try? context.save()
    }

    func purchase(_ product: Product, context: NSManagedObjectContext) async -> PurchaseResult {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let tx) = verification {
                    await tx.finish()
                }
                await refreshEntitlements(context: context)
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

    func restorePurchases(context: NSManagedObjectContext) async {
        try? await AppStore.sync()
        await refreshEntitlements(context: context)
    }

    private func listenForTransactions(context: NSManagedObjectContext) -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let tx) = result {
                    await tx.finish()
                    await self?.refreshEntitlements(context: context)
                }
            }
        }
    }
}
