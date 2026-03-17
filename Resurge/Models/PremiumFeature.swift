import Foundation

enum PremiumFeature: String, CaseIterable, Codable, Identifiable {
    case advancedAnalytics
    case unlimitedHabits
    case recoveryLibrary
    case dailyMotivation
    case rewardSystem
    case virtualCompanion
    case coachingPlans
    case biometricLock

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .advancedAnalytics:  return "Advanced Analytics"
        case .unlimitedHabits:   return "Unlimited Habits"
        case .recoveryLibrary:   return "Recovery Library"
        case .dailyMotivation:   return "Daily Motivation"
        case .rewardSystem:      return "Rewards & Collectibles"
        case .virtualCompanion:  return "Virtual Companion"
        case .coachingPlans:     return "Coaching Plans"
        case .biometricLock:     return "Face ID / Touch ID"
        }
    }

    var iconName: String {
        switch self {
        case .advancedAnalytics:  return "chart.bar.xaxis"
        case .unlimitedHabits:   return "infinity"
        case .recoveryLibrary:   return "books.vertical.fill"
        case .dailyMotivation:   return "quote.bubble.fill"
        case .rewardSystem:      return "trophy.fill"
        case .virtualCompanion:  return "hare.fill"
        case .coachingPlans:     return "map.fill"
        case .biometricLock:     return "faceid"
        }
    }

    var description: String {
        switch self {
        case .advancedAnalytics:  return "Deep insights into your progress with charts and trends."
        case .unlimitedHabits:   return "Track as many habits as you need."
        case .recoveryLibrary:   return "CBT, ACT, SMART Recovery & mindfulness exercises."
        case .dailyMotivation:   return "4 daily motivational notifications tailored to your habit."
        case .rewardSystem:      return "Earn points, unlock collectibles, and build your trophy case."
        case .virtualCompanion:  return "Grow a companion that evolves with your progress."
        case .coachingPlans:     return "Structured day-by-day plans tailored to your habit."
        case .biometricLock:     return "Protect your private data with Face ID or Touch ID."
        }
    }
}
