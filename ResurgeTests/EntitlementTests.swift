import XCTest
@testable import Resurge

final class EntitlementTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(status: SubscriptionStatus) -> EntitlementManager {
        let provider = MockIAPProvider()
        provider.subscriptionStatus = status
        return EntitlementManager(provider: provider)
    }

    // MARK: - Free Habit Limit

    func testFreeHabitLimitIsExactlyOne() {
        let sut = makeSUT(status: .free)
        XCTAssertTrue(sut.canAddHabit(currentCount: 0),
                      "Free user should be able to add first habit")
        XCTAssertFalse(sut.canAddHabit(currentCount: 1),
                       "Free user should NOT add a second habit")
    }

    func testFreeUserCannotAddHabitAtLimit() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.canAddHabit(currentCount: 1))
    }

    func testFreeUserCannotAddHabitAboveLimit() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.canAddHabit(currentCount: 5))
    }

    // MARK: - Free User Feature Access

    func testFreeUserGetsDailyMotivation() {
        let sut = makeSUT(status: .free)
        XCTAssertTrue(sut.check(.dailyMotivation))
    }

    func testFreeUserGetsVirtualCompanion() {
        let sut = makeSUT(status: .free)
        XCTAssertTrue(sut.check(.virtualCompanion))
    }

    func testFreeUserDoesNotGetAdvancedAnalytics() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.check(.advancedAnalytics))
    }

    func testFreeUserDoesNotGetUnlimitedHabits() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.check(.unlimitedHabits))
    }

    func testFreeUserDoesNotGetRecoveryLibrary() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.check(.recoveryLibrary))
    }

    func testFreeUserDoesNotGetRewardSystem() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.check(.rewardSystem))
    }

    func testFreeUserDoesNotGetCoachingPlans() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.check(.coachingPlans))
    }

    func testFreeUserDoesNotGetBiometricLock() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.check(.biometricLock))
    }

    // MARK: - Premium User Feature Access

    func testPremiumMonthlyUserGetsAllFeatures() {
        let sut = makeSUT(status: .monthly)
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(sut.check(feature),
                          "Premium monthly user should have access to \(feature.rawValue)")
        }
    }

    func testPremiumYearlyUserGetsAllFeatures() {
        let sut = makeSUT(status: .yearly)
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(sut.check(feature),
                          "Premium yearly user should have access to \(feature.rawValue)")
        }
    }

    func testPremiumLifetimeUserGetsAllFeatures() {
        let sut = makeSUT(status: .lifetime)
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(sut.check(feature),
                          "Premium lifetime user should have access to \(feature.rawValue)")
        }
    }

    // MARK: - Premium Unlimited Habits

    func testPremiumUserCanAddUnlimitedHabits() {
        let sut = makeSUT(status: .monthly)
        XCTAssertTrue(sut.canAddHabit(currentCount: 0))
        XCTAssertTrue(sut.canAddHabit(currentCount: 1))
        XCTAssertTrue(sut.canAddHabit(currentCount: 10))
        XCTAssertTrue(sut.canAddHabit(currentCount: 100))
    }

    // MARK: - isPremium Flag

    func testFreeUserIsNotPremium() {
        let sut = makeSUT(status: .free)
        XCTAssertFalse(sut.isPremium)
    }

    func testMonthlyUserIsPremium() {
        let sut = makeSUT(status: .monthly)
        XCTAssertTrue(sut.isPremium)
    }

    func testYearlyUserIsPremium() {
        let sut = makeSUT(status: .yearly)
        XCTAssertTrue(sut.isPremium)
    }

    func testLifetimeUserIsPremium() {
        let sut = makeSUT(status: .lifetime)
        XCTAssertTrue(sut.isPremium)
    }
}
