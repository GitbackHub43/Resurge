import XCTest
import CoreData
@testable import Resurge

final class BadgeUnlockTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.preview.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // MARK: - Badge Unlock Eligibility

    func testDay1HasNotEarned7DayBadge() {
        let timeBadges = MilestoneBadge.timeBadges
        let sevenDayBadge = timeBadges.first { $0.requiredDays == 7 }
        XCTAssertNotNil(sevenDayBadge, "7-day badge should exist")

        let earnedBadges = timeBadges.filter { $0.requiredDays <= 1 }
        let contains7Day = earnedBadges.contains { $0.requiredDays == 7 }
        XCTAssertFalse(contains7Day, "A habit at day 1 should NOT have earned the 7-day badge")
    }

    func testDay7HasEarned7DayBadge() {
        let timeBadges = MilestoneBadge.timeBadges
        let earnedBadges = timeBadges.filter { $0.requiredDays <= 7 }
        let has7DayBadge = earnedBadges.contains { $0.requiredDays == 7 }
        XCTAssertTrue(has7DayBadge, "A habit at day 7 should have earned the 7-day badge")

        // Verify the first badge where requiredDays <= 7 exists
        let firstEligible = timeBadges.sorted(by: { $0.requiredDays < $1.requiredDays })
            .first { $0.requiredDays <= 7 }
        XCTAssertNotNil(firstEligible, "There should be at least one badge with requiredDays <= 7")
    }

    func testDay30HasEarnedAllBadgesUpTo30Days() {
        let allBadges = MilestoneBadge.allBadges
        let earnedBadges = allBadges.filter { $0.requiredDays <= 30 && $0.requiredDays > 0 }

        // Should include time badges: 1, 3, 7, 14, 30 and streak badges: 3, 7, 14, 30
        XCTAssertGreaterThanOrEqual(earnedBadges.count, 5,
            "A habit at day 30 should have earned at least 5 time/streak badges")

        // Verify specific milestones are included
        let earnedDays = Set(earnedBadges.map(\.requiredDays))
        XCTAssertTrue(earnedDays.contains(1), "Should have earned the 1-day badge")
        XCTAssertTrue(earnedDays.contains(3), "Should have earned the 3-day badge")
        XCTAssertTrue(earnedDays.contains(7), "Should have earned the 7-day badge")
        XCTAssertTrue(earnedDays.contains(14), "Should have earned the 14-day badge")
        XCTAssertTrue(earnedDays.contains(30), "Should have earned the 30-day badge")

        // Verify no badges beyond 30 days are included
        let beyond30 = earnedBadges.filter { $0.requiredDays > 30 }
        XCTAssertTrue(beyond30.isEmpty, "Should not have earned badges requiring more than 30 days")
    }

    func testAllTimeBadgesHavePositiveRequiredDays() {
        let timeBadges = MilestoneBadge.timeBadges
        for badge in timeBadges {
            XCTAssertGreaterThan(badge.requiredDays, 0,
                "Time badge '\(badge.key)' should have requiredDays > 0")
        }
    }

    func testBadgeRequiredDaysAreInAscendingOrder() {
        let allBadges = MilestoneBadge.allBadges
        for i in 0..<allBadges.count - 1 {
            XCTAssertLessThanOrEqual(allBadges[i].requiredDays, allBadges[i + 1].requiredDays,
                "Badge '\(allBadges[i].key)' (\(allBadges[i].requiredDays) days) should come before '\(allBadges[i + 1].key)' (\(allBadges[i + 1].requiredDays) days)")
        }
    }

    // MARK: - CDHabit daysSoberCount

    func testDaysSoberCountCalculatesCorrectly() {
        let daysAgo = 25
        let habit = makeHabit(daysAgo: daysAgo)
        XCTAssertEqual(habit.daysSoberCount, daysAgo,
            "daysSoberCount should match the number of days since startDate")
    }

    // MARK: - CDHabit currentStreak

    func testCurrentStreakWithNoLapsesMatchesDaysSober() {
        let daysAgo = 12
        let habit = makeHabit(daysAgo: daysAgo)
        // With no daily logs (no lapses), currentStreak should equal daysSoberCount
        XCTAssertEqual(habit.currentStreak, habit.daysSoberCount,
            "currentStreak should equal daysSoberCount when there are no lapses")
        XCTAssertEqual(habit.currentStreak, daysAgo,
            "currentStreak should be \(daysAgo) for a habit started \(daysAgo) days ago with no lapses")
    }

    // MARK: - Helpers

    private func makeHabit(daysAgo: Int) -> CDHabit {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Test Badge Habit"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        habit.goalDays = 90
        habit.costPerUnit = 0
        habit.dailyUnits = 0
        habit.timePerUnit = 0
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()
        return habit
    }
}
