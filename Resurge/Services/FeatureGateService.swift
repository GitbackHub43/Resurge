import Foundation

final class FeatureGateService: ObservableObject {
    @Published var tier: PurchaseManager.SubscriptionTier = .free

    private let freeTools: Set<String> = [
        "breathing",
        "puzzle",
        "quotes",
        "journaling"
    ]

    func canAddHabit(currentCount: Int) -> Bool { tier.isPro || currentCount < 1 }
    func canUseTool(_ toolId: String) -> Bool { tier.isPro || freeTools.contains(toolId) }
    func canAccessFullLibrary() -> Bool { true }
    func canSeeAdvancedAnalytics() -> Bool { tier.isPro }
    func canUsePrivacyLock() -> Bool { true }  // ALWAYS FREE
    func canUseStealth() -> Bool { true }  // ALWAYS FREE
    func canUseCompanionEvolution() -> Bool { tier.isPro }
    func canUseCoachingPlans() -> Bool { tier.isPro }
    func canUseEnhancedNotifications() -> Bool { tier.isPro }
}
