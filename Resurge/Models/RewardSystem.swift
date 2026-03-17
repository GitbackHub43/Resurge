import Foundation
import SwiftUI

// MARK: - Recovery Points

enum RecoveryPointAction: String, CaseIterable {
    case dailyCheckIn
    case journalEntry
    case cravingResisted
    case badgeUnlocked
    case challengeCompleted
    case streakBonus

    var points: Int {
        switch self {
        case .dailyCheckIn:        return 10
        case .journalEntry:        return 15
        case .cravingResisted:     return 25
        case .badgeUnlocked:       return 50
        case .challengeCompleted:  return 20
        case .streakBonus:         return 5 // per day, capped at 50
        }
    }

    var displayName: String {
        switch self {
        case .dailyCheckIn:        return "Daily Check-In"
        case .journalEntry:        return "Journal Entry"
        case .cravingResisted:     return "Craving Resisted"
        case .badgeUnlocked:       return "Badge Unlocked"
        case .challengeCompleted:  return "Challenge Completed"
        case .streakBonus:         return "Streak Bonus"
        }
    }

    var iconName: String {
        switch self {
        case .dailyCheckIn:        return "checkmark.circle.fill"
        case .journalEntry:        return "book.fill"
        case .cravingResisted:     return "hand.raised.fill"
        case .badgeUnlocked:       return "rosette"
        case .challengeCompleted:  return "flag.fill"
        case .streakBonus:         return "flame.fill"
        }
    }

    /// Returns the streak bonus for a given streak day count, capped at 50.
    static func streakBonusPoints(forDay day: Int) -> Int {
        min(day * 5, 50)
    }
}

// MARK: - Collectible Items

struct Collectible: Identifiable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let glowColor: String
    let requiredRP: Int
    let isPremium: Bool
    let category: CollectibleCategory
}

enum CollectibleCategory: String, CaseIterable {
    case milestone
    case program
    case legendary
}

// MARK: - Reward Catalog

enum RewardCatalog {

    // MARK: Free Milestone Collectibles (8)

    static let freeCollectibles: [Collectible] = [
        Collectible(
            id: "seed",
            name: "Recovery Seed",
            description: "Every journey begins with a single seed.",
            iconName: "leaf.fill",
            glowColor: "neonGreen",
            requiredRP: 100,
            isPremium: false,
            category: .milestone
        ),
        Collectible(
            id: "flame",
            name: "Inner Flame",
            description: "Your inner fire burns brighter than any craving.",
            iconName: "flame.fill",
            glowColor: "neonOrange",
            requiredRP: 250,
            isPremium: false,
            category: .milestone
        ),
        Collectible(
            id: "shield",
            name: "Shield of Will",
            description: "An unbreakable shield forged by discipline.",
            iconName: "shield.fill",
            glowColor: "neonCyan",
            requiredRP: 500,
            isPremium: false,
            category: .milestone
        ),
        Collectible(
            id: "phoenix_feather",
            name: "Phoenix Feather",
            description: "Rise from the ashes, lighter than before.",
            iconName: "wind",
            glowColor: "neonMagenta",
            requiredRP: 1_000,
            isPremium: false,
            category: .milestone
        ),
        Collectible(
            id: "diamond_mind",
            name: "Diamond Mind",
            description: "Pressure creates diamonds — and unshakable minds.",
            iconName: "suit.diamond.fill",
            glowColor: "neonPurple",
            requiredRP: 2_500,
            isPremium: false,
            category: .milestone
        ),
        Collectible(
            id: "golden_crown",
            name: "Golden Crown",
            description: "Wear your progress with pride.",
            iconName: "crown.fill",
            glowColor: "neonGold",
            requiredRP: 5_000,
            isPremium: false,
            category: .milestone
        ),
        Collectible(
            id: "legends_star",
            name: "Legend's Star",
            description: "Only the most dedicated reach the stars.",
            iconName: "star.fill",
            glowColor: "neonCyan",
            requiredRP: 10_000,
            isPremium: false,
            category: .milestone
        ),
        Collectible(
            id: "eternal_phoenix",
            name: "Eternal Phoenix",
            description: "You have been reborn — forever changed.",
            iconName: "bolt.fill",
            glowColor: "neonGold",
            requiredRP: 25_000,
            isPremium: false,
            category: .milestone
        )
    ]

    // MARK: Premium Program Collectibles (12)

    static let premiumCollectibles: [Collectible] = [
        Collectible(
            id: "clear_lungs",
            name: "Clear Lungs",
            description: "Breathe freely, live fully.",
            iconName: "lungs.fill",
            glowColor: "neonCyan",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "sharp_mind",
            name: "Sharp Mind",
            description: "Clarity is the ultimate high.",
            iconName: "brain.head.profile",
            glowColor: "neonPurple",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "pure_gaze",
            name: "Pure Gaze",
            description: "See the world with fresh eyes.",
            iconName: "eye.fill",
            glowColor: "neonMagenta",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "free_hands",
            name: "Free Hands",
            description: "Your hands are free to create.",
            iconName: "hand.raised.fill",
            glowColor: "neonCyan",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "real_connection",
            name: "Real Connection",
            description: "The best moments are offline.",
            iconName: "person.2.fill",
            glowColor: "neonGreen",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "life_player",
            name: "Life Player",
            description: "The real game is out there.",
            iconName: "gamecontroller.fill",
            glowColor: "neonOrange",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "momentum",
            name: "Momentum",
            description: "Action beats perfection every time.",
            iconName: "bolt.circle.fill",
            glowColor: "neonGold",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "natural_energy",
            name: "Natural Energy",
            description: "Your body thrives without sugar.",
            iconName: "leaf.arrow.circlepath",
            glowColor: "neonGreen",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "inner_peace",
            name: "Inner Peace",
            description: "Nourish your soul, not your stress.",
            iconName: "heart.fill",
            glowColor: "neonMagenta",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "true_wealth",
            name: "True Wealth",
            description: "The richest life needs no receipt.",
            iconName: "banknote.fill",
            glowColor: "neonGold",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "safe_bet",
            name: "Safe Bet",
            description: "The house always loses when you walk away.",
            iconName: "dice.fill",
            glowColor: "neonOrange",
            requiredRP: 500,
            isPremium: true,
            category: .program
        ),
        Collectible(
            id: "deep_rest",
            name: "Deep Rest",
            description: "Sleep is the foundation of strength.",
            iconName: "moon.fill",
            glowColor: "neonPurple",
            requiredRP: 500,
            isPremium: true,
            category: .program
        )
    ]

    // MARK: Legendary Collectibles (4)

    static let legendaryCollectibles: [Collectible] = [
        Collectible(
            id: "warriors_heart",
            name: "Warrior's Heart",
            description: "A heart tempered by every battle won.",
            iconName: "heart.circle.fill",
            glowColor: "neonMagenta",
            requiredRP: 50_000,
            isPremium: true,
            category: .legendary
        ),
        Collectible(
            id: "unbreakable",
            name: "Unbreakable",
            description: "Nothing can shatter what you've built.",
            iconName: "lock.shield.fill",
            glowColor: "neonCyan",
            requiredRP: 100_000,
            isPremium: true,
            category: .legendary
        ),
        Collectible(
            id: "transcendence",
            name: "Transcendence",
            description: "You have risen beyond the pull of old habits.",
            iconName: "sparkles",
            glowColor: "neonPurple",
            requiredRP: 200_000,
            isPremium: true,
            category: .legendary
        ),
        Collectible(
            id: "immortal",
            name: "Immortal",
            description: "Your legacy of recovery is eternal.",
            iconName: "infinity",
            glowColor: "neonGold",
            requiredRP: 500_000,
            isPremium: true,
            category: .legendary
        )
    ]

    // MARK: Helpers

    static var allCollectibles: [Collectible] {
        freeCollectibles + premiumCollectibles + legendaryCollectibles
    }

    static func unlockedCollectibles(totalRP: Int, isPremium: Bool) -> [Collectible] {
        allCollectibles.filter { collectible in
            totalRP >= collectible.requiredRP && (isPremium || !collectible.isPremium)
        }
    }

    static func nextCollectible(totalRP: Int, isPremium: Bool) -> Collectible? {
        let available = isPremium ? allCollectibles : allCollectibles.filter { !$0.isPremium }
        return available
            .sorted { $0.requiredRP < $1.requiredRP }
            .first { $0.requiredRP > totalRP }
    }

    /// Returns progress toward the next collectible as a value from 0.0 to 1.0.
    static func progressToNext(totalRP: Int, isPremium: Bool) -> Double {
        guard let next = nextCollectible(totalRP: totalRP, isPremium: isPremium) else {
            return 1.0
        }

        let available = isPremium ? allCollectibles : allCollectibles.filter { !$0.isPremium }
        let sorted = available.sorted { $0.requiredRP < $1.requiredRP }

        let previousRP = sorted
            .last { $0.requiredRP <= totalRP }
            .map(\.requiredRP) ?? 0

        let range = next.requiredRP - previousRP
        guard range > 0 else { return 1.0 }

        return Double(totalRP - previousRP) / Double(range)
    }
}
