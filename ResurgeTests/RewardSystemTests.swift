import XCTest
@testable import Resurge

final class RewardSystemTests: XCTestCase {

    // MARK: - RecoveryPointAction Point Values

    func testDailyCheckInPoints() {
        XCTAssertEqual(RecoveryPointAction.dailyCheckIn.points, 10)
    }

    func testJournalEntryPoints() {
        XCTAssertEqual(RecoveryPointAction.journalEntry.points, 15)
    }

    func testCravingResistedPoints() {
        XCTAssertEqual(RecoveryPointAction.cravingResisted.points, 25)
    }

    func testBadgeUnlockedPoints() {
        XCTAssertEqual(RecoveryPointAction.badgeUnlocked.points, 50)
    }

    func testChallengeCompletedPoints() {
        XCTAssertEqual(RecoveryPointAction.challengeCompleted.points, 20)
    }

    func testStreakBonusBasePoints() {
        XCTAssertEqual(RecoveryPointAction.streakBonus.points, 5)
    }

    // MARK: - Streak Bonus Calculation

    func testStreakBonusDay1() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 1), 5)
    }

    func testStreakBonusDay5() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 5), 25)
    }

    func testStreakBonusDay10CappedAt50() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 10), 50)
    }

    func testStreakBonusDay100CappedAt50() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 100), 50,
            "Streak bonus should be capped at 50")
    }

    func testStreakBonusDay0() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 0), 0)
    }

    // MARK: - Reward Catalog Counts

    func testFreeCollectiblesCount() {
        XCTAssertEqual(RewardCatalog.freeCollectibles.count, 8,
            "Should have 8 free milestone collectibles")
    }

    func testPremiumCollectiblesCount() {
        XCTAssertEqual(RewardCatalog.premiumCollectibles.count, 12,
            "Should have 12 premium program collectibles")
    }

    func testLegendaryCollectiblesCount() {
        XCTAssertEqual(RewardCatalog.legendaryCollectibles.count, 4,
            "Should have 4 legendary collectibles")
    }

    func testAllCollectiblesCount() {
        XCTAssertEqual(RewardCatalog.allCollectibles.count, 24,
            "Should have 24 total collectibles (8 + 12 + 4)")
    }

    // MARK: - Unlocked Collectibles

    func testZeroRPUnlocksNothing() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 0, isPremium: true)
        XCTAssertEqual(unlocked.count, 0, "0 RP should unlock no collectibles")
    }

    func testFreeUserUnlocksOnlyFreeCollectibles() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 1_000, isPremium: false)
        let hasPremium = unlocked.contains { $0.isPremium }
        XCTAssertFalse(hasPremium, "Free user should not unlock premium collectibles")
    }

    func testPremiumUserUnlocksPremiumCollectibles() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 1_000, isPremium: true)
        let hasPremium = unlocked.contains { $0.isPremium }
        XCTAssertTrue(hasPremium, "Premium user with 1000 RP should unlock some premium collectibles")
    }

    func testUnlockAtExactThreshold() {
        // Recovery Seed requires 100 RP
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 100, isPremium: false)
        let hasSeed = unlocked.contains { $0.id == "seed" }
        XCTAssertTrue(hasSeed, "Exactly 100 RP should unlock the Recovery Seed")
    }

    func testHighRPUnlocksMultiple() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 5_000, isPremium: false)
        XCTAssertGreaterThanOrEqual(unlocked.count, 5,
            "5000 RP free user should unlock multiple collectibles")
    }

    func testMaxRPUnlocksEverything() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 500_000, isPremium: true)
        XCTAssertEqual(unlocked.count, RewardCatalog.allCollectibles.count,
            "500000 RP premium user should unlock all collectibles")
    }

    // MARK: - Progress to Next

    func testProgressToNextAtZeroRP() {
        let progress = RewardCatalog.progressToNext(totalRP: 0, isPremium: false)
        XCTAssertGreaterThanOrEqual(progress, 0.0, "Progress should be >= 0")
        XCTAssertLessThanOrEqual(progress, 1.0, "Progress should be <= 1")
    }

    func testProgressToNextMidway() {
        // First free collectible is at 100 RP
        let progress = RewardCatalog.progressToNext(totalRP: 50, isPremium: false)
        XCTAssertEqual(progress, 0.5, accuracy: 0.01, "50 RP should be 50% to first collectible at 100 RP")
    }

    func testProgressToNextAtMaxRP() {
        let progress = RewardCatalog.progressToNext(totalRP: 500_000, isPremium: true)
        XCTAssertEqual(progress, 1.0, "Should be 1.0 when all collectibles are unlocked")
    }

    func testProgressToNextAlwaysInRange() {
        let testValues = [0, 50, 100, 250, 500, 1000, 5000, 10000, 25000, 100000]
        for rp in testValues {
            let progress = RewardCatalog.progressToNext(totalRP: rp, isPremium: false)
            XCTAssertGreaterThanOrEqual(progress, 0.0, "Progress at \(rp) RP should be >= 0")
            XCTAssertLessThanOrEqual(progress, 1.0, "Progress at \(rp) RP should be <= 1")
        }
    }

    // MARK: - Next Collectible

    func testNextCollectibleAtZeroRP() {
        let next = RewardCatalog.nextCollectible(totalRP: 0, isPremium: false)
        XCTAssertNotNil(next, "Should have a next collectible at 0 RP")
        XCTAssertEqual(next?.id, "seed", "First collectible should be Recovery Seed")
    }

    func testNextCollectibleAfterFirst() {
        let next = RewardCatalog.nextCollectible(totalRP: 100, isPremium: false)
        XCTAssertNotNil(next, "Should have a next collectible after unlocking first")
        XCTAssertEqual(next?.id, "flame", "Next after seed should be Inner Flame")
    }

    func testNextCollectibleNilAtMax() {
        let next = RewardCatalog.nextCollectible(totalRP: 500_000, isPremium: true)
        XCTAssertNil(next, "Should return nil when all collectibles are unlocked")
    }

    func testNextCollectibleFreeUserSkipsPremium() {
        let next = RewardCatalog.nextCollectible(totalRP: 100, isPremium: false)
        XCTAssertNotNil(next)
        XCTAssertFalse(next!.isPremium, "Free user's next collectible should not be premium")
    }

    // MARK: - Collectible Properties

    func testAllCollectiblesHaveUniqueIDs() {
        let ids = Set(RewardCatalog.allCollectibles.map(\.id))
        XCTAssertEqual(ids.count, RewardCatalog.allCollectibles.count,
            "All collectible IDs should be unique")
    }

    func testAllCollectiblesHaveNonEmptyFields() {
        for collectible in RewardCatalog.allCollectibles {
            XCTAssertFalse(collectible.name.isEmpty, "\(collectible.id) should have a name")
            XCTAssertFalse(collectible.description.isEmpty, "\(collectible.id) should have a description")
            XCTAssertFalse(collectible.iconName.isEmpty, "\(collectible.id) should have an icon")
            XCTAssertGreaterThan(collectible.requiredRP, 0, "\(collectible.id) should require positive RP")
        }
    }

    // MARK: - RecoveryPointAction Coverage

    func testAllActionsHaveDisplayNames() {
        for action in RecoveryPointAction.allCases {
            XCTAssertFalse(action.displayName.isEmpty, "\(action.rawValue) should have a display name")
        }
    }

    func testAllActionsHaveIconNames() {
        for action in RecoveryPointAction.allCases {
            XCTAssertFalse(action.iconName.isEmpty, "\(action.rawValue) should have an icon name")
        }
    }
}
