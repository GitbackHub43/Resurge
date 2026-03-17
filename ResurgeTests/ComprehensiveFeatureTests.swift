import XCTest
import CoreData
@testable import Resurge

// MARK: - Helpers

private extension Calendar {
    /// Returns a Date that is `days` days before today at start-of-day.
    func daysAgo(_ days: Int) -> Date {
        let today = startOfDay(for: Date())
        return date(byAdding: .day, value: -days, to: today)!
    }
}

// MARK: - Time Badge Tests

final class TimeBadgeTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    // Every time badge: (key, requiredDays)
    private static let timeMilestones: [(key: String, days: Int)] = [
        ("1_day", 1),
        ("3_days", 3),
        ("1_week", 7),
        ("2_weeks", 14),
        ("1_month", 30),
        ("2_months", 60),
        ("3_months", 90),
        ("6_months", 180),
        ("9_months", 270),
        ("1_year", 365),
        ("18_months", 548),
        ("2_years", 730),
        ("3_years", 1095),
        ("5_years", 1825),
    ]

    // MARK: Verify all 14 time badges exist

    func testTimeBadgeCountIs14() {
        XCTAssertEqual(MilestoneBadge.timeBadges.count, 14,
                       "There should be exactly 14 time badges")
    }

    func testAllTimeBadgeKeysPresent() {
        let keys = Set(MilestoneBadge.timeBadges.map(\.key))
        for (key, _) in Self.timeMilestones {
            XCTAssertTrue(keys.contains(key), "Time badge '\(key)' should exist")
        }
    }

    // MARK: Boundary tests — day before should NOT qualify, day of SHOULD

    func testTimeBadge_1Day_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(0))
        XCTAssertEqual(habit.daysSoberCount, 0, "0 days ago => 0 days sober")
        XCTAssertFalse(habit.daysSoberCount >= 1, "Should NOT qualify for 1-day badge at day 0")
    }

    func testTimeBadge_1Day_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(1))
        XCTAssertEqual(habit.daysSoberCount, 1)
        XCTAssertTrue(habit.daysSoberCount >= 1, "Should qualify for 1-day badge at day 1")
    }

    func testTimeBadge_3Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(2))
        XCTAssertEqual(habit.daysSoberCount, 2)
        XCTAssertFalse(habit.daysSoberCount >= 3)
    }

    func testTimeBadge_3Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(3))
        XCTAssertEqual(habit.daysSoberCount, 3)
        XCTAssertTrue(habit.daysSoberCount >= 3)
    }

    func testTimeBadge_7Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(6))
        XCTAssertFalse(habit.daysSoberCount >= 7)
    }

    func testTimeBadge_7Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(7))
        XCTAssertTrue(habit.daysSoberCount >= 7)
    }

    func testTimeBadge_14Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(13))
        XCTAssertFalse(habit.daysSoberCount >= 14)
    }

    func testTimeBadge_14Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(14))
        XCTAssertTrue(habit.daysSoberCount >= 14)
    }

    func testTimeBadge_30Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(29))
        XCTAssertFalse(habit.daysSoberCount >= 30)
    }

    func testTimeBadge_30Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(30))
        XCTAssertTrue(habit.daysSoberCount >= 30)
    }

    func testTimeBadge_60Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(59))
        XCTAssertFalse(habit.daysSoberCount >= 60)
    }

    func testTimeBadge_60Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(60))
        XCTAssertTrue(habit.daysSoberCount >= 60)
    }

    func testTimeBadge_90Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(89))
        XCTAssertFalse(habit.daysSoberCount >= 90)
    }

    func testTimeBadge_90Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(90))
        XCTAssertTrue(habit.daysSoberCount >= 90)
    }

    func testTimeBadge_180Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(179))
        XCTAssertFalse(habit.daysSoberCount >= 180)
    }

    func testTimeBadge_180Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(180))
        XCTAssertTrue(habit.daysSoberCount >= 180)
    }

    func testTimeBadge_270Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(269))
        XCTAssertFalse(habit.daysSoberCount >= 270)
    }

    func testTimeBadge_270Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(270))
        XCTAssertTrue(habit.daysSoberCount >= 270)
    }

    func testTimeBadge_365Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(364))
        XCTAssertFalse(habit.daysSoberCount >= 365)
    }

    func testTimeBadge_365Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(365))
        XCTAssertTrue(habit.daysSoberCount >= 365)
    }

    func testTimeBadge_548Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(547))
        XCTAssertFalse(habit.daysSoberCount >= 548)
    }

    func testTimeBadge_548Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(548))
        XCTAssertTrue(habit.daysSoberCount >= 548)
    }

    func testTimeBadge_730Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(729))
        XCTAssertFalse(habit.daysSoberCount >= 730)
    }

    func testTimeBadge_730Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(730))
        XCTAssertTrue(habit.daysSoberCount >= 730)
    }

    func testTimeBadge_1095Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(1094))
        XCTAssertFalse(habit.daysSoberCount >= 1095)
    }

    func testTimeBadge_1095Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(1095))
        XCTAssertTrue(habit.daysSoberCount >= 1095)
    }

    func testTimeBadge_1825Days_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(1824))
        XCTAssertFalse(habit.daysSoberCount >= 1825)
    }

    func testTimeBadge_1825Days_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(1825))
        XCTAssertTrue(habit.daysSoberCount >= 1825)
    }

    // MARK: Future start date should yield 0 days

    func testFutureStartDateYieldsZeroDays() {
        let future = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking", startDate: future)
        XCTAssertEqual(habit.daysSoberCount, 0, "Future start date should give 0 days")
    }

    // MARK: Premium flags on time badges

    func testTimeBadgePremiumFlags() {
        let premiumKeys: Set<String> = ["9_months", "1_year", "18_months", "2_years", "3_years", "5_years"]
        for badge in MilestoneBadge.timeBadges {
            if premiumKeys.contains(badge.key) {
                XCTAssertTrue(badge.isPremium, "\(badge.key) should be premium")
            } else {
                XCTAssertFalse(badge.isPremium, "\(badge.key) should be free")
            }
        }
    }
}

// MARK: - Behavior Badge Tests

final class BehaviorBadgeTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testBehaviorBadgeCountIs13() {
        XCTAssertEqual(MilestoneBadge.behaviorBadges.count, 13,
                       "There should be exactly 13 behavior badges")
    }

    // MARK: Journal badges

    func testFirstJournalBadge_NoneWritten() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let journals = (habit.journalEntries as? Set<CDJournalEntry>) ?? []
        XCTAssertEqual(journals.count, 0)
        XCTAssertFalse(journals.count >= 1, "No journal entries => first_journal not earned")
    }

    func testFirstJournalBadge_OneWritten() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        CDJournalEntry.create(in: ctx, habit: habit, body: "Day 1 reflection")
        let journals = (habit.journalEntries as? Set<CDJournalEntry>) ?? []
        XCTAssertEqual(journals.count, 1)
        XCTAssertTrue(journals.count >= 1, "1 journal entry => first_journal earned")
    }

    func testJournal10Badge_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for i in 0..<9 {
            CDJournalEntry.create(in: ctx, habit: habit, body: "Entry \(i)")
        }
        let count = (habit.journalEntries as? Set<CDJournalEntry>)?.count ?? 0
        XCTAssertEqual(count, 9)
        XCTAssertFalse(count >= 10, "9 entries should NOT qualify for journal_10")
    }

    func testJournal10Badge_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for i in 0..<10 {
            CDJournalEntry.create(in: ctx, habit: habit, body: "Entry \(i)")
        }
        let count = (habit.journalEntries as? Set<CDJournalEntry>)?.count ?? 0
        XCTAssertEqual(count, 10)
        XCTAssertTrue(count >= 10, "10 entries should qualify for journal_10")
    }

    func testJournal50Badge_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for i in 0..<49 {
            CDJournalEntry.create(in: ctx, habit: habit, body: "Entry \(i)")
        }
        let count = (habit.journalEntries as? Set<CDJournalEntry>)?.count ?? 0
        XCTAssertEqual(count, 49)
        XCTAssertFalse(count >= 50)
    }

    func testJournal50Badge_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for i in 0..<50 {
            CDJournalEntry.create(in: ctx, habit: habit, body: "Entry \(i)")
        }
        let count = (habit.journalEntries as? Set<CDJournalEntry>)?.count ?? 0
        XCTAssertEqual(count, 50)
        XCTAssertTrue(count >= 50)
    }

    // MARK: Craving resistance badges

    func testCravingCrusher10_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for _ in 0..<9 {
            CDCravingEntry.create(in: ctx, habit: habit, didResist: true)
        }
        let resisted = (habit.cravingEntries as? Set<CDCravingEntry>)?.filter { $0.didResist }.count ?? 0
        XCTAssertEqual(resisted, 9)
        XCTAssertFalse(resisted >= 10)
    }

    func testCravingCrusher10_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for _ in 0..<10 {
            CDCravingEntry.create(in: ctx, habit: habit, didResist: true)
        }
        let resisted = (habit.cravingEntries as? Set<CDCravingEntry>)?.filter { $0.didResist }.count ?? 0
        XCTAssertEqual(resisted, 10)
        XCTAssertTrue(resisted >= 10)
    }

    func testCravingConqueror50_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for _ in 0..<49 {
            CDCravingEntry.create(in: ctx, habit: habit, didResist: true)
        }
        let resisted = (habit.cravingEntries as? Set<CDCravingEntry>)?.filter { $0.didResist }.count ?? 0
        XCTAssertEqual(resisted, 49)
        XCTAssertFalse(resisted >= 50)
    }

    func testCravingConqueror50_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for _ in 0..<50 {
            CDCravingEntry.create(in: ctx, habit: habit, didResist: true)
        }
        let resisted = (habit.cravingEntries as? Set<CDCravingEntry>)?.filter { $0.didResist }.count ?? 0
        XCTAssertEqual(resisted, 50)
        XCTAssertTrue(resisted >= 50)
    }

    func testCravingResistance_MixedResults() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for _ in 0..<10 { CDCravingEntry.create(in: ctx, habit: habit, didResist: true) }
        for _ in 0..<5 { CDCravingEntry.create(in: ctx, habit: habit, didResist: false) }
        let resisted = (habit.cravingEntries as? Set<CDCravingEntry>)?.filter { $0.didResist }.count ?? 0
        XCTAssertEqual(resisted, 10, "Only resisted cravings count")
    }

    // MARK: Week Warrior (7 consecutive check-ins)

    func testWeekWarrior_6ConsecutiveDays() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(10))
        let cal = Calendar.current
        for i in 0..<6 {
            CDDailyLogEntry.create(in: ctx, habit: habit,
                                   date: cal.daysAgo(i))
        }
        let logs = (habit.dailyLogs as? Set<CDDailyLogEntry>) ?? []
        XCTAssertEqual(logs.count, 6)
        let consecutiveDays = countConsecutiveCheckIns(logs: logs)
        XCTAssertFalse(consecutiveDays >= 7, "6 consecutive days should NOT earn week_warrior")
    }

    func testWeekWarrior_7ConsecutiveDays() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(10))
        let cal = Calendar.current
        for i in 0..<7 {
            CDDailyLogEntry.create(in: ctx, habit: habit,
                                   date: cal.daysAgo(i))
        }
        let logs = (habit.dailyLogs as? Set<CDDailyLogEntry>) ?? []
        XCTAssertEqual(logs.count, 7)
        let consecutiveDays = countConsecutiveCheckIns(logs: logs)
        XCTAssertTrue(consecutiveDays >= 7, "7 consecutive days should earn week_warrior")
    }

    // MARK: Tool Explorer (5 different coping tools)

    func testToolExplorer_4Tools() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let tools = ["breathing", "journaling", "exercise", "meditation"]
        for tool in tools {
            CDCravingEntry.create(in: ctx, habit: habit, copingToolUsed: tool, didResist: true)
        }
        let uniqueTools = Set(
            ((habit.cravingEntries as? Set<CDCravingEntry>) ?? [])
                .compactMap(\.copingToolUsed)
        )
        XCTAssertEqual(uniqueTools.count, 4)
        XCTAssertFalse(uniqueTools.count >= 5, "4 tools should NOT earn tool_explorer")
    }

    func testToolExplorer_5Tools() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let tools = ["breathing", "journaling", "exercise", "meditation", "cold_shower"]
        for tool in tools {
            CDCravingEntry.create(in: ctx, habit: habit, copingToolUsed: tool, didResist: true)
        }
        let uniqueTools = Set(
            ((habit.cravingEntries as? Set<CDCravingEntry>) ?? [])
                .compactMap(\.copingToolUsed)
        )
        XCTAssertEqual(uniqueTools.count, 5)
        XCTAssertTrue(uniqueTools.count >= 5, "5 tools should earn tool_explorer")
    }

    func testToolExplorer_DuplicateToolsDoNotCount() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for _ in 0..<10 {
            CDCravingEntry.create(in: ctx, habit: habit, copingToolUsed: "breathing", didResist: true)
        }
        let uniqueTools = Set(
            ((habit.cravingEntries as? Set<CDCravingEntry>) ?? [])
                .compactMap(\.copingToolUsed)
        )
        XCTAssertEqual(uniqueTools.count, 1, "Repeated same tool should count as 1 unique")
    }

    // MARK: Money saved badges

    func testMoney100_BoundaryNotMet() {
        // $10/day * 9 days = $90
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(9),
                                   baselineCostPerDay: 10.0)
        XCTAssertLessThan(habit.moneySaved, 100.0, "$90 should NOT qualify for money_100")
    }

    func testMoney100_BoundaryMet() {
        // $10/day * 10 days = $100
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(10),
                                   baselineCostPerDay: 10.0)
        XCTAssertGreaterThanOrEqual(habit.moneySaved, 100.0, "$100 should qualify for money_100")
    }

    func testMoney500_BoundaryNotMet() {
        // $10/day * 49 days = $490
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(49),
                                   baselineCostPerDay: 10.0)
        XCTAssertLessThan(habit.moneySaved, 500.0)
    }

    func testMoney500_BoundaryMet() {
        // $10/day * 50 days = $500
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(50),
                                   baselineCostPerDay: 10.0)
        XCTAssertGreaterThanOrEqual(habit.moneySaved, 500.0)
    }

    func testMoney1000_BoundaryMet() {
        // $10/day * 100 days = $1000
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(100),
                                   baselineCostPerDay: 10.0)
        XCTAssertGreaterThanOrEqual(habit.moneySaved, 1000.0)
    }

    func testMoney5000_BoundaryMet() {
        // $10/day * 500 days = $5000
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(500),
                                   baselineCostPerDay: 10.0)
        XCTAssertGreaterThanOrEqual(habit.moneySaved, 5000.0)
    }

    func testMoneySaved_FallbackToCostPerUnit() {
        // costPerUnit=5, dailyUnits=4 => $20/day. 5 days => $100
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(5),
                                   baselineCostPerDay: 0,
                                   costPerUnit: 5.0, dailyUnits: 4.0)
        XCTAssertGreaterThanOrEqual(habit.moneySaved, 100.0,
                                    "Should fall back to costPerUnit * dailyUnits")
    }

    // MARK: Time saved badges

    func testTime100Hours_BoundaryNotMet() {
        // 60 min/day * 99 days = 5940 min < 6000
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "phone",
                                   startDate: Calendar.current.daysAgo(99),
                                   baselineTimePerDay: 60.0)
        XCTAssertLessThan(habit.timeSavedMinutes, 6000.0, "5940 min < 6000 => NOT 100 hours")
    }

    func testTime100Hours_BoundaryMet() {
        // 60 min/day * 100 days = 6000 min = 100 hours
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "phone",
                                   startDate: Calendar.current.daysAgo(100),
                                   baselineTimePerDay: 60.0)
        XCTAssertGreaterThanOrEqual(habit.timeSavedMinutes, 6000.0, "6000 min = 100 hours")
    }

    func testTime500Hours_BoundaryMet() {
        // 60 min/day * 500 days = 30000 min = 500 hours
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "phone",
                                   startDate: Calendar.current.daysAgo(500),
                                   baselineTimePerDay: 60.0)
        XCTAssertGreaterThanOrEqual(habit.timeSavedMinutes, 30000.0, "30000 min = 500 hours")
    }

    func testTimeSaved_FallbackToTimePerUnit() {
        // timePerUnit=15, dailyUnits=4 => 60 min/day. 100 days => 6000 min
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "phone",
                                   startDate: Calendar.current.daysAgo(100),
                                   baselineTimePerDay: 0,
                                   timePerUnit: 15.0, dailyUnits: 4.0)
        XCTAssertGreaterThanOrEqual(habit.timeSavedMinutes, 6000.0)
    }

    func testTimeSaved_ZeroDaysYieldsZero() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "phone",
                                   startDate: Calendar.current.daysAgo(0),
                                   baselineTimePerDay: 120.0)
        XCTAssertEqual(habit.timeSavedMinutes, 0.0, "0 days sober => 0 time saved")
    }

    // MARK: - Private helper for consecutive check-in count

    private func countConsecutiveCheckIns(logs: Set<CDDailyLogEntry>) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let logDates = Set(logs.map { cal.startOfDay(for: $0.date) })
        var streak = 0
        var cursor = today
        while logDates.contains(cursor) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }
}

// MARK: - Streak Badge Tests

final class StreakBadgeTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testStreakBadgeCountIs8() {
        XCTAssertEqual(MilestoneBadge.streakBadges.count, 8,
                       "There should be exactly 8 streak badges")
    }

    private static let streakThresholds: [(key: String, days: Int)] = [
        ("streak_3", 3),
        ("streak_7", 7),
        ("streak_14", 14),
        ("streak_30", 30),
        ("streak_60", 60),
        ("streak_100", 100),
        ("streak_200", 200),
        ("streak_365", 365),
    ]

    func testAllStreakBadgeKeysExist() {
        let keys = Set(MilestoneBadge.streakBadges.map(\.key))
        for (key, _) in Self.streakThresholds {
            XCTAssertTrue(keys.contains(key), "Streak badge '\(key)' should exist")
        }
    }

    // MARK: currentStreak with no lapses equals daysSoberCount

    func testStreakWithNoLapsesEqualsDaysSober() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(30))
        XCTAssertEqual(habit.currentStreak, habit.daysSoberCount,
                       "With no daily logs, streak should equal days sober")
    }

    // MARK: Streak boundary tests

    func testStreak3_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(2))
        XCTAssertFalse(habit.currentStreak >= 3)
    }

    func testStreak3_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(3))
        XCTAssertTrue(habit.currentStreak >= 3)
    }

    func testStreak7_BoundaryNotMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(6))
        XCTAssertFalse(habit.currentStreak >= 7)
    }

    func testStreak7_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(7))
        XCTAssertTrue(habit.currentStreak >= 7)
    }

    func testStreak14_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(14))
        XCTAssertTrue(habit.currentStreak >= 14)
    }

    func testStreak30_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(30))
        XCTAssertTrue(habit.currentStreak >= 30)
    }

    func testStreak60_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(60))
        XCTAssertTrue(habit.currentStreak >= 60)
    }

    func testStreak100_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(100))
        XCTAssertTrue(habit.currentStreak >= 100)
    }

    func testStreak200_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(200))
        XCTAssertTrue(habit.currentStreak >= 200)
    }

    func testStreak365_BoundaryMet() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(365))
        XCTAssertTrue(habit.currentStreak >= 365)
    }

    // MARK: Streak broken by lapse

    func testStreakBrokenByLapseYesterday() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(30))
        // Lapse yesterday breaks streak to just today (1 day: today)
        CDDailyLogEntry.create(in: ctx, habit: habit,
                               date: cal.daysAgo(1), lapsedToday: true)
        XCTAssertEqual(habit.currentStreak, 1,
                       "Lapse yesterday should reset streak to 1 (today only)")
    }

    func testStreakBrokenByLapseToday() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(30))
        CDDailyLogEntry.create(in: ctx, habit: habit,
                               date: cal.daysAgo(0), lapsedToday: true)
        XCTAssertEqual(habit.currentStreak, 0,
                       "Lapse today should reset streak to 0")
    }

    func testStreakNotBrokenByOldLapse() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(30))
        // Lapse 20 days ago => streak is 20 (days 19...0 are clean)
        CDDailyLogEntry.create(in: ctx, habit: habit,
                               date: cal.daysAgo(20), lapsedToday: true)
        XCTAssertEqual(habit.currentStreak, 20,
                       "Lapse at day 20 means 20 clean days from 19 to today")
    }

    // MARK: Premium flags on streak badges

    func testStreakBadgePremiumFlags() {
        let premiumKeys: Set<String> = ["streak_60", "streak_100", "streak_200", "streak_365"]
        for badge in MilestoneBadge.streakBadges {
            if premiumKeys.contains(badge.key) {
                XCTAssertTrue(badge.isPremium, "\(badge.key) should be premium")
            } else {
                XCTAssertFalse(badge.isPremium, "\(badge.key) should be free")
            }
        }
    }
}

// MARK: - Program Badge Tests

final class ProgramBadgeTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testProgramBadgeCountIs36() {
        XCTAssertEqual(MilestoneBadge.programBadges.count, 36,
                       "There should be exactly 36 program badges (3 per 12 programs)")
    }

    // All 12 programs (excluding .custom which has no badges)
    private static let programs: [ProgramType] = [
        .smoking, .alcohol, .porn, .phone, .socialMedia, .gaming,
        .procrastination, .sugar, .emotionalEating, .shopping, .gambling, .sleep
    ]

    func testEachProgramHasExactly3Badges() {
        for program in Self.programs {
            let badges = MilestoneBadge.programBadges.filter { $0.programType == program }
            XCTAssertEqual(badges.count, 3,
                           "\(program.rawValue) should have exactly 3 program badges")
        }
    }

    func testEachProgramHas7d_30d_90dBadges() {
        for program in Self.programs {
            let badges = MilestoneBadge.programBadges.filter { $0.programType == program }
            let days = Set(badges.map(\.requiredDays))
            XCTAssertTrue(days.contains(7), "\(program.rawValue) should have a 7-day badge")
            XCTAssertTrue(days.contains(30), "\(program.rawValue) should have a 30-day badge")
            XCTAssertTrue(days.contains(90), "\(program.rawValue) should have a 90-day badge")
        }
    }

    func testAllProgramBadgesAreFree() {
        for badge in MilestoneBadge.programBadges {
            XCTAssertFalse(badge.isPremium, "Program badge '\(badge.key)' should be free")
        }
    }

    // MARK: Program badge unlock simulation for each program

    func testSmoking7dBoundary() {
        assertProgramBadgeBoundary(program: .smoking, days: 7, key: "smoking_7d")
    }

    func testSmoking30dBoundary() {
        assertProgramBadgeBoundary(program: .smoking, days: 30, key: "smoking_30d")
    }

    func testSmoking90dBoundary() {
        assertProgramBadgeBoundary(program: .smoking, days: 90, key: "smoking_90d")
    }

    func testAlcohol7dBoundary() {
        assertProgramBadgeBoundary(program: .alcohol, days: 7, key: "alcohol_7d")
    }

    func testAlcohol30dBoundary() {
        assertProgramBadgeBoundary(program: .alcohol, days: 30, key: "alcohol_30d")
    }

    func testAlcohol90dBoundary() {
        assertProgramBadgeBoundary(program: .alcohol, days: 90, key: "alcohol_90d")
    }

    func testPorn7dBoundary() {
        assertProgramBadgeBoundary(program: .porn, days: 7, key: "porn_7d")
    }

    func testPorn30dBoundary() {
        assertProgramBadgeBoundary(program: .porn, days: 30, key: "porn_30d")
    }

    func testPorn90dBoundary() {
        assertProgramBadgeBoundary(program: .porn, days: 90, key: "porn_90d")
    }

    func testPhone7dBoundary() {
        assertProgramBadgeBoundary(program: .phone, days: 7, key: "phone_7d")
    }

    func testPhone30dBoundary() {
        assertProgramBadgeBoundary(program: .phone, days: 30, key: "phone_30d")
    }

    func testPhone90dBoundary() {
        assertProgramBadgeBoundary(program: .phone, days: 90, key: "phone_90d")
    }

    func testSocial7dBoundary() {
        assertProgramBadgeBoundary(program: .socialMedia, days: 7, key: "social_7d")
    }

    func testSocial30dBoundary() {
        assertProgramBadgeBoundary(program: .socialMedia, days: 30, key: "social_30d")
    }

    func testSocial90dBoundary() {
        assertProgramBadgeBoundary(program: .socialMedia, days: 90, key: "social_90d")
    }

    func testGaming7dBoundary() {
        assertProgramBadgeBoundary(program: .gaming, days: 7, key: "gaming_7d")
    }

    func testGaming30dBoundary() {
        assertProgramBadgeBoundary(program: .gaming, days: 30, key: "gaming_30d")
    }

    func testGaming90dBoundary() {
        assertProgramBadgeBoundary(program: .gaming, days: 90, key: "gaming_90d")
    }

    func testProcrastination7dBoundary() {
        assertProgramBadgeBoundary(program: .procrastination, days: 7, key: "procrastination_7d")
    }

    func testProcrastination30dBoundary() {
        assertProgramBadgeBoundary(program: .procrastination, days: 30, key: "procrastination_30d")
    }

    func testProcrastination90dBoundary() {
        assertProgramBadgeBoundary(program: .procrastination, days: 90, key: "procrastination_90d")
    }

    func testSugar7dBoundary() {
        assertProgramBadgeBoundary(program: .sugar, days: 7, key: "sugar_7d")
    }

    func testSugar30dBoundary() {
        assertProgramBadgeBoundary(program: .sugar, days: 30, key: "sugar_30d")
    }

    func testSugar90dBoundary() {
        assertProgramBadgeBoundary(program: .sugar, days: 90, key: "sugar_90d")
    }

    func testEmotionalEating7dBoundary() {
        assertProgramBadgeBoundary(program: .emotionalEating, days: 7, key: "emotional_eating_7d")
    }

    func testEmotionalEating30dBoundary() {
        assertProgramBadgeBoundary(program: .emotionalEating, days: 30, key: "emotional_eating_30d")
    }

    func testEmotionalEating90dBoundary() {
        assertProgramBadgeBoundary(program: .emotionalEating, days: 90, key: "emotional_eating_90d")
    }

    func testShopping7dBoundary() {
        assertProgramBadgeBoundary(program: .shopping, days: 7, key: "shopping_7d")
    }

    func testShopping30dBoundary() {
        assertProgramBadgeBoundary(program: .shopping, days: 30, key: "shopping_30d")
    }

    func testShopping90dBoundary() {
        assertProgramBadgeBoundary(program: .shopping, days: 90, key: "shopping_90d")
    }

    func testGambling7dBoundary() {
        assertProgramBadgeBoundary(program: .gambling, days: 7, key: "gambling_7d")
    }

    func testGambling30dBoundary() {
        assertProgramBadgeBoundary(program: .gambling, days: 30, key: "gambling_30d")
    }

    func testGambling90dBoundary() {
        assertProgramBadgeBoundary(program: .gambling, days: 90, key: "gambling_90d")
    }

    func testSleep7dBoundary() {
        assertProgramBadgeBoundary(program: .sleep, days: 7, key: "sleep_7d")
    }

    func testSleep30dBoundary() {
        assertProgramBadgeBoundary(program: .sleep, days: 30, key: "sleep_30d")
    }

    func testSleep90dBoundary() {
        assertProgramBadgeBoundary(program: .sleep, days: 90, key: "sleep_90d")
    }

    // MARK: - Helper

    private func assertProgramBadgeBoundary(program: ProgramType, days: Int, key: String,
                                             file: StaticString = #filePath, line: UInt = #line) {
        let cal = Calendar.current

        // Day before: should NOT qualify
        let habitBefore = CDHabit.create(in: ctx, name: "Test", programType: program.rawValue,
                                          startDate: cal.daysAgo(days - 1))
        let badge = MilestoneBadge.programBadges.first { $0.key == key }!
        XCTAssertFalse(habitBefore.daysSoberCount >= badge.requiredDays,
                       "\(key): day \(days - 1) should NOT qualify", file: file, line: line)

        // Day of: SHOULD qualify
        let habitAt = CDHabit.create(in: ctx, name: "Test", programType: program.rawValue,
                                      startDate: cal.daysAgo(days))
        XCTAssertTrue(habitAt.daysSoberCount >= badge.requiredDays,
                      "\(key): day \(days) SHOULD qualify", file: file, line: line)

        // Verify correct program type on badge
        XCTAssertEqual(badge.programType, program,
                       "\(key) should belong to \(program.rawValue)", file: file, line: line)
    }
}

// MARK: - Achievement Unlock Core Data Tests

final class AchievementUnlockTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testCreateAchievementUnlock() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let unlock = CDAchievementUnlock.create(in: ctx, habit: habit, achievementKey: "1_day")

        XCTAssertEqual(unlock.achievementKey, "1_day")
        XCTAssertFalse(unlock.seen)
        XCTAssertEqual(unlock.habit, habit)
    }

    func testAchievementUnlockLinkedToHabit() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        CDAchievementUnlock.create(in: ctx, habit: habit, achievementKey: "1_day")
        CDAchievementUnlock.create(in: ctx, habit: habit, achievementKey: "3_days")

        let unlocks = habit.achievementUnlocks as? Set<CDAchievementUnlock> ?? []
        let keys = Set(unlocks.map(\.achievementKey))
        XCTAssertEqual(keys.count, 2)
        XCTAssertTrue(keys.contains("1_day"))
        XCTAssertTrue(keys.contains("3_days"))
    }

    func testMarkAchievementAsSeen() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let unlock = CDAchievementUnlock.create(in: ctx, habit: habit, achievementKey: "1_day")
        XCTAssertFalse(unlock.seen)

        unlock.seen = true
        XCTAssertTrue(unlock.seen)
    }

    func testAchievementUnlockPersistsToFetch() throws {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        CDAchievementUnlock.create(in: ctx, habit: habit, achievementKey: "streak_7")
        try ctx.save()

        let request = NSFetchRequest<CDAchievementUnlock>(entityName: "CDAchievementUnlock")
        request.predicate = NSPredicate(format: "achievementKey == %@", "streak_7")
        let results = try ctx.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.achievementKey, "streak_7")
    }

    func testNoDuplicateAchievementKeys() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        CDAchievementUnlock.create(in: ctx, habit: habit, achievementKey: "1_day")
        CDAchievementUnlock.create(in: ctx, habit: habit, achievementKey: "1_day")

        let unlocks = habit.achievementUnlocks as? Set<CDAchievementUnlock> ?? []
        // Core Data allows duplicates; app logic should prevent this.
        // This test documents that two objects are created (the app must check before creating).
        XCTAssertEqual(unlocks.count, 2,
                       "Core Data does not prevent duplicates; app layer must guard against them")
    }
}

// MARK: - All Badges Structural Tests

final class AllBadgesStructuralTests: XCTestCase {

    func testAllBadgesCount() {
        // 14 time + 13 behavior + 8 streak + 36 program = 71
        XCTAssertEqual(MilestoneBadge.allBadges.count, 71,
                       "Total badges should be 71 (14+13+8+36)")
    }

    func testAllBadgesHaveUniqueKeys() {
        let keys = MilestoneBadge.allBadges.map(\.key)
        let unique = Set(keys)
        XCTAssertEqual(keys.count, unique.count, "All badge keys should be unique")
    }

    func testAllBadgesHaveNonEmptyTitles() {
        for badge in MilestoneBadge.allBadges {
            XCTAssertFalse(badge.title.isEmpty, "Badge '\(badge.key)' should have a title")
        }
    }

    func testAllBadgesHaveNonEmptyDescriptions() {
        for badge in MilestoneBadge.allBadges {
            XCTAssertFalse(badge.description.isEmpty, "Badge '\(badge.key)' should have a description")
        }
    }

    func testAllBadgesHaveNonEmptyIconNames() {
        for badge in MilestoneBadge.allBadges {
            XCTAssertFalse(badge.iconName.isEmpty, "Badge '\(badge.key)' should have an icon")
        }
    }

    func testAllBadgesRequiredDaysNonNegative() {
        for badge in MilestoneBadge.allBadges {
            XCTAssertGreaterThanOrEqual(badge.requiredDays, 0,
                                        "Badge '\(badge.key)' requiredDays should be >= 0")
        }
    }

    func testAllBadgesSortedByRequiredDays() {
        let days = MilestoneBadge.allBadges.map(\.requiredDays)
        for i in 1..<days.count {
            XCTAssertGreaterThanOrEqual(days[i], days[i - 1],
                                        "allBadges should be sorted by requiredDays")
        }
    }

    func testBadgeCategoryCounts() {
        let grouped = Dictionary(grouping: MilestoneBadge.allBadges, by: \.category)
        XCTAssertEqual(grouped[.time]?.count, 14)
        XCTAssertEqual(grouped[.behavior]?.count, 13)
        XCTAssertEqual(grouped[.streak]?.count, 8)
        XCTAssertEqual(grouped[.program]?.count, 36)
    }

    func testBadgeCategoryAllCases() {
        XCTAssertEqual(BadgeCategory.allCases.count, 4)
        XCTAssertTrue(BadgeCategory.allCases.contains(.time))
        XCTAssertTrue(BadgeCategory.allCases.contains(.behavior))
        XCTAssertTrue(BadgeCategory.allCases.contains(.streak))
        XCTAssertTrue(BadgeCategory.allCases.contains(.program))
    }
}

// MARK: - Journal Feature Tests

final class JournalFeatureTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testCreateJournalEntry_SavesToCoreData() throws {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Feeling strong today",
                                           title: "Day 1", mood: 4)
        try ctx.save()

        let request = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        let results = try ctx.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.body, "Feeling strong today")
        XCTAssertEqual(results.first?.title, "Day 1")
        XCTAssertEqual(results.first?.mood, 4)
    }

    func testJournalMoodRange() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for mood: Int16 in 0...4 {
            let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Mood \(mood)", mood: mood)
            XCTAssertEqual(entry.mood, mood, "Mood \(mood) should persist correctly")
        }
    }

    func testJournalEntryLinkedToHabit() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Test entry")
        XCTAssertEqual(entry.habit, habit)
        let journals = habit.journalEntries as? Set<CDJournalEntry> ?? []
        XCTAssertTrue(journals.contains(entry))
    }

    func testJournalEntryDefaultMood() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Default mood")
        XCTAssertEqual(entry.mood, 3, "Default mood should be 3")
    }

    func testJournalReflectionFlag() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Reflection",
                                           isReflection: true)
        XCTAssertTrue(entry.isReflection)
    }

    func testJournalPromptUsed() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Prompted entry",
                                           promptUsed: "What are you grateful for?")
        XCTAssertEqual(entry.promptUsed, "What are you grateful for?")
    }

    func testJournalEntryTimestamps() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let before = Date()
        let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Timestamp test")
        let after = Date()

        XCTAssertGreaterThanOrEqual(entry.createdAt, before)
        XCTAssertLessThanOrEqual(entry.createdAt, after)
        XCTAssertGreaterThanOrEqual(entry.updatedAt, before)
        XCTAssertLessThanOrEqual(entry.updatedAt, after)
    }

    func testMultipleJournalEntriesForOneHabit() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        for i in 0..<25 {
            CDJournalEntry.create(in: ctx, habit: habit, body: "Entry \(i)")
        }
        let journals = habit.journalEntries as? Set<CDJournalEntry> ?? []
        XCTAssertEqual(journals.count, 25)
    }
}

// MARK: - Lapse Flow Tests

final class LapseFlowTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testCravingEntryWithLapseReviewEventType() throws {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDCravingEntry(context: ctx)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.intensity = 8
        entry.didResist = false
        entry.eventType = "LAPSE_REVIEW"
        entry.outcome = "lapsed"
        entry.habit = habit
        try ctx.save()

        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "eventType == %@", "LAPSE_REVIEW")
        let results = try ctx.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.eventType, "LAPSE_REVIEW")
        XCTAssertFalse(results.first!.didResist)
    }

    func testLapseTriggerStoredAsCommaSeparatedString() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDCravingEntry.create(in: ctx, habit: habit, didResist: false)
        entry.eventType = "LAPSE_REVIEW"
        entry.outcome = "lapsed"
        entry.stateTags = "stress,boredom,loneliness"

        let tags = entry.stateTags?.components(separatedBy: ",") ?? []
        XCTAssertEqual(tags.count, 3)
        XCTAssertTrue(tags.contains("stress"))
        XCTAssertTrue(tags.contains("boredom"))
        XCTAssertTrue(tags.contains("loneliness"))
    }

    func testFreshStartAfterLapse() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(30))
        XCTAssertEqual(habit.daysSoberCount, 30)

        // Simulate fresh start by resetting startDate
        habit.startDate = cal.startOfDay(for: Date())
        XCTAssertEqual(habit.daysSoberCount, 0, "After fresh start, days sober should be 0")
    }

    func testLapseBreaksStreakButDaysCountContinues() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(30))

        // Log a lapse 5 days ago
        CDDailyLogEntry.create(in: ctx, habit: habit,
                               date: cal.daysAgo(5), lapsedToday: true)

        XCTAssertEqual(habit.daysSoberCount, 30, "daysSoberCount is from startDate, not affected by lapse")
        XCTAssertEqual(habit.currentStreak, 5, "Streak should be 5 (days since lapse)")
    }

    func testCravingEntryDidResistFalse() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDCravingEntry.create(in: ctx, habit: habit, didResist: false)
        XCTAssertFalse(entry.didResist)
    }

    func testCravingEntryIntensityStored() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDCravingEntry.create(in: ctx, habit: habit, intensity: 9, didResist: true)
        XCTAssertEqual(entry.intensity, 9)
    }

    func testCravingEntryTriggerFields() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDCravingEntry.create(in: ctx, habit: habit,
                                           triggerCategory: "emotional",
                                           triggerNote: "Had a stressful meeting",
                                           didResist: true)
        XCTAssertEqual(entry.triggerCategory, "emotional")
        XCTAssertEqual(entry.triggerNote, "Had a stressful meeting")
    }

    func testCravingLocationAndSocialTags() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let entry = CDCravingEntry.create(in: ctx, habit: habit, didResist: true)
        entry.locationTag = "home"
        entry.socialTag = "alone"
        XCTAssertEqual(entry.locationTag, "home")
        XCTAssertEqual(entry.socialTag, "alone")
    }
}

// MARK: - Companion Mood Tests

final class CompanionMoodFeatureTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!
    private var service: VirtualCompanionService!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
        service = VirtualCompanionService(context: ctx)
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    // MARK: moodForStreak (legacy convenience)

    func testMoodForStreak_0_IsSad() {
        XCTAssertEqual(service.moodForStreak(0), "sad")
    }

    func testMoodForStreak_1_IsWorried() {
        XCTAssertEqual(service.moodForStreak(1), "worried")
    }

    func testMoodForStreak_2_IsWorried() {
        XCTAssertEqual(service.moodForStreak(2), "worried")
    }

    func testMoodForStreak_3_IsNeutral() {
        XCTAssertEqual(service.moodForStreak(3), "neutral")
    }

    func testMoodForStreak_6_IsNeutral() {
        XCTAssertEqual(service.moodForStreak(6), "neutral")
    }

    func testMoodForStreak_7_IsHappy() {
        XCTAssertEqual(service.moodForStreak(7), "happy")
    }

    func testMoodForStreak_13_IsHappy() {
        XCTAssertEqual(service.moodForStreak(13), "happy")
    }

    func testMoodForStreak_14_IsProud() {
        XCTAssertEqual(service.moodForStreak(14), "proud")
    }

    func testMoodForStreak_29_IsProud() {
        XCTAssertEqual(service.moodForStreak(29), "proud")
    }

    func testMoodForStreak_30_IsEcstatic() {
        XCTAssertEqual(service.moodForStreak(30), "ecstatic")
    }

    func testMoodForStreak_365_IsEcstatic() {
        XCTAssertEqual(service.moodForStreak(365), "ecstatic")
    }

    // MARK: levelForStreak

    func testLevelForStreak_0to6_IsLevel1() {
        for day in 0...6 {
            XCTAssertEqual(service.levelForStreak(day), 1,
                           "Day \(day) should be level 1")
        }
    }

    func testLevelForStreak_7to13_IsLevel2() {
        for day in 7...13 {
            XCTAssertEqual(service.levelForStreak(day), 2,
                           "Day \(day) should be level 2")
        }
    }

    func testLevelForStreak_14to29_IsLevel3() {
        for day in 14...29 {
            XCTAssertEqual(service.levelForStreak(day), 3,
                           "Day \(day) should be level 3")
        }
    }

    func testLevelForStreak_30to59_IsLevel4() {
        for day in 30...59 {
            XCTAssertEqual(service.levelForStreak(day), 4,
                           "Day \(day) should be level 4")
        }
    }

    func testLevelForStreak_60to89_IsLevel5() {
        for day in 60...89 {
            XCTAssertEqual(service.levelForStreak(day), 5,
                           "Day \(day) should be level 5")
        }
    }

    func testLevelForStreak_90Plus_IsLevel6() {
        for day in [90, 100, 200, 365, 730] {
            XCTAssertEqual(service.levelForStreak(day), 6,
                           "Day \(day) should be level 6")
        }
    }

    // MARK: Level boundary tests

    func testLevelBoundary_6to7() {
        XCTAssertEqual(service.levelForStreak(6), 1)
        XCTAssertEqual(service.levelForStreak(7), 2)
    }

    func testLevelBoundary_13to14() {
        XCTAssertEqual(service.levelForStreak(13), 2)
        XCTAssertEqual(service.levelForStreak(14), 3)
    }

    func testLevelBoundary_29to30() {
        XCTAssertEqual(service.levelForStreak(29), 3)
        XCTAssertEqual(service.levelForStreak(30), 4)
    }

    func testLevelBoundary_59to60() {
        XCTAssertEqual(service.levelForStreak(59), 4)
        XCTAssertEqual(service.levelForStreak(60), 5)
    }

    func testLevelBoundary_89to90() {
        XCTAssertEqual(service.levelForStreak(89), 5)
        XCTAssertEqual(service.levelForStreak(90), 6)
    }

    // MARK: computeMoodFromRecovery

    func testComputeMood_Ecstatic_30DayStreak3Journals() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(30))
        // 3 journal entries in the last 7 days
        for i in 0..<3 {
            let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Entry \(i)")
            entry.date = cal.daysAgo(i)
        }
        let mood = service.computeMoodFromRecovery(habits: [habit], context: ctx)
        XCTAssertEqual(mood, "ecstatic")
    }

    func testComputeMood_Proud_14DayStreak2Journals() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(14))
        for i in 0..<2 {
            let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Entry \(i)")
            entry.date = cal.daysAgo(i)
        }
        let mood = service.computeMoodFromRecovery(habits: [habit], context: ctx)
        XCTAssertEqual(mood, "proud")
    }

    func testComputeMood_Happy_7DayStreak() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(7))
        let mood = service.computeMoodFromRecovery(habits: [habit], context: ctx)
        XCTAssertEqual(mood, "happy")
    }

    func testComputeMood_Neutral_3DayStreak() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(3))
        let mood = service.computeMoodFromRecovery(habits: [habit], context: ctx)
        XCTAssertEqual(mood, "neutral")
    }

    func testComputeMood_Worried_1DayStreak() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(1))
        let mood = service.computeMoodFromRecovery(habits: [habit], context: ctx)
        XCTAssertEqual(mood, "worried")
    }

    func testComputeMood_Sad_0DayStreak() {
        let mood = service.computeMoodFromRecovery(habits: [], context: ctx)
        XCTAssertEqual(mood, "sad", "No active habits => 0 streak => sad")
    }

    // MARK: longestActiveStreak

    func testLongestActiveStreak_NoHabits() {
        XCTAssertEqual(service.longestActiveStreak(habits: []), 0)
    }

    func testLongestActiveStreak_MultipleHabits() {
        let cal = Calendar.current
        let habit1 = CDHabit.create(in: ctx, name: "H1", programType: "smoking",
                                    startDate: cal.daysAgo(10))
        let habit2 = CDHabit.create(in: ctx, name: "H2", programType: "alcohol",
                                    startDate: cal.daysAgo(30))
        let longest = service.longestActiveStreak(habits: [habit1, habit2])
        XCTAssertEqual(longest, 30, "Should return the longest streak among active habits")
    }

    func testLongestActiveStreak_IgnoresInactive() {
        let cal = Calendar.current
        let habit1 = CDHabit.create(in: ctx, name: "H1", programType: "smoking",
                                    startDate: cal.daysAgo(100))
        habit1.isActive = false
        let habit2 = CDHabit.create(in: ctx, name: "H2", programType: "alcohol",
                                    startDate: cal.daysAgo(5))
        let longest = service.longestActiveStreak(habits: [habit1, habit2])
        XCTAssertEqual(longest, 5, "Should ignore inactive habits")
    }
}

// MARK: - Premium Gating Tests

final class PremiumGatingTests: XCTestCase {

    // MARK: Free user feature access

    func testFreeUser_DailyMotivation_Allowed() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertTrue(manager.check(.dailyMotivation))
    }

    func testFreeUser_VirtualCompanion_Allowed() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertTrue(manager.check(.virtualCompanion))
    }

    func testFreeUser_AdvancedAnalytics_Blocked() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.check(.advancedAnalytics))
    }

    func testFreeUser_UnlimitedHabits_Blocked() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.check(.unlimitedHabits))
    }

    func testFreeUser_RecoveryLibrary_Blocked() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.check(.recoveryLibrary))
    }

    func testFreeUser_RewardSystem_Blocked() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.check(.rewardSystem))
    }

    func testFreeUser_CoachingPlans_Blocked() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.check(.coachingPlans))
    }

    func testFreeUser_BiometricLock_Blocked() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.check(.biometricLock))
    }

    // MARK: Premium user feature access

    func testPremiumUser_AllFeaturesUnlocked() {
        let manager = EntitlementManager(provider: mockProvider(premium: true))
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(manager.check(feature),
                          "Premium user should have access to \(feature.rawValue)")
        }
    }

    // MARK: Habit limit

    func testFreeUser_CanAddFirstHabit() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertTrue(manager.canAddHabit(currentCount: 0),
                      "Free user with 0 habits should be able to add one")
    }

    func testFreeUser_BlockedAtSecondHabit() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.canAddHabit(currentCount: 1),
                       "Free user with 1 habit should be blocked from adding another")
    }

    func testFreeUser_BlockedAtThirdHabit() {
        let manager = EntitlementManager(provider: mockProvider(premium: false))
        XCTAssertFalse(manager.canAddHabit(currentCount: 2),
                       "Free user with 2 habits should be blocked")
    }

    func testPremiumUser_UnlimitedHabits() {
        let manager = EntitlementManager(provider: mockProvider(premium: true))
        for count in [0, 1, 5, 10, 50, 100] {
            XCTAssertTrue(manager.canAddHabit(currentCount: count),
                          "Premium user should add habits at count \(count)")
        }
    }

    // MARK: Subscription status

    func testFreeStatusIsNotPremium() {
        let provider = MockIAPProvider()
        provider.subscriptionStatus = .free
        let manager = EntitlementManager(provider: provider)
        XCTAssertFalse(manager.isPremium)
    }

    func testMonthlyStatusIsPremium() {
        let provider = MockIAPProvider()
        provider.subscriptionStatus = .monthly
        let manager = EntitlementManager(provider: provider)
        XCTAssertTrue(manager.isPremium)
    }

    func testYearlyStatusIsPremium() {
        let provider = MockIAPProvider()
        provider.subscriptionStatus = .yearly
        let manager = EntitlementManager(provider: provider)
        XCTAssertTrue(manager.isPremium)
    }

    func testLifetimeStatusIsPremium() {
        let provider = MockIAPProvider()
        provider.subscriptionStatus = .lifetime
        let manager = EntitlementManager(provider: provider)
        XCTAssertTrue(manager.isPremium)
    }

    func testTrialStatusIsPremium() {
        let provider = MockIAPProvider()
        provider.subscriptionStatus = .trial
        let manager = EntitlementManager(provider: provider)
        XCTAssertTrue(manager.isPremium)
    }

    // MARK: - Helper

    private func mockProvider(premium: Bool) -> MockIAPProvider {
        let provider = MockIAPProvider()
        provider.subscriptionStatus = premium ? .lifetime : .free
        return provider
    }
}

// MARK: - Reward Points Tests

final class RewardPointsFeatureTests: XCTestCase {

    // MARK: Point values for each action

    func testAllPointValues() {
        XCTAssertEqual(RecoveryPointAction.dailyCheckIn.points, 10)
        XCTAssertEqual(RecoveryPointAction.journalEntry.points, 15)
        XCTAssertEqual(RecoveryPointAction.cravingResisted.points, 25)
        XCTAssertEqual(RecoveryPointAction.badgeUnlocked.points, 50)
        XCTAssertEqual(RecoveryPointAction.challengeCompleted.points, 20)
        XCTAssertEqual(RecoveryPointAction.streakBonus.points, 5)
    }

    // MARK: Streak bonus multiplier

    func testStreakBonusDay1() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 1), 5)
    }

    func testStreakBonusDay2() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 2), 10)
    }

    func testStreakBonusDay5() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 5), 25)
    }

    func testStreakBonusDay9() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 9), 45)
    }

    func testStreakBonusDay10_CappedAt50() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 10), 50)
    }

    func testStreakBonusDay11_StillCappedAt50() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 11), 50)
    }

    func testStreakBonusDay100_CappedAt50() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 100), 50)
    }

    func testStreakBonusDay0_IsZero() {
        XCTAssertEqual(RecoveryPointAction.streakBonusPoints(forDay: 0), 0)
    }

    // MARK: Collectible unlock thresholds

    func testFreeCollectibleThresholds() {
        let expected: [(id: String, rp: Int)] = [
            ("seed", 100), ("flame", 250), ("shield", 500),
            ("phoenix_feather", 1_000), ("diamond_mind", 2_500),
            ("golden_crown", 5_000), ("legends_star", 10_000),
            ("eternal_phoenix", 25_000),
        ]
        for (id, rp) in expected {
            let c = RewardCatalog.freeCollectibles.first { $0.id == id }
            XCTAssertNotNil(c, "Free collectible '\(id)' should exist")
            XCTAssertEqual(c?.requiredRP, rp, "'\(id)' should require \(rp) RP")
            XCTAssertFalse(c?.isPremium ?? true, "'\(id)' should be free")
        }
    }

    func testPremiumCollectibleThresholds() {
        for c in RewardCatalog.premiumCollectibles {
            XCTAssertEqual(c.requiredRP, 500, "Premium program collectible '\(c.id)' should require 500 RP")
            XCTAssertTrue(c.isPremium, "'\(c.id)' should be premium")
        }
    }

    func testLegendaryCollectibleThresholds() {
        let expected: [(id: String, rp: Int)] = [
            ("warriors_heart", 50_000), ("unbreakable", 100_000),
            ("transcendence", 200_000), ("immortal", 500_000),
        ]
        for (id, rp) in expected {
            let c = RewardCatalog.legendaryCollectibles.first { $0.id == id }
            XCTAssertNotNil(c, "Legendary collectible '\(id)' should exist")
            XCTAssertEqual(c?.requiredRP, rp)
            XCTAssertTrue(c?.isPremium ?? false, "'\(id)' should be premium")
        }
    }

    // MARK: Unlock boundary tests

    func testUnlock_99RP_NoSeed() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 99, isPremium: false)
        XCTAssertFalse(unlocked.contains { $0.id == "seed" },
                       "99 RP should NOT unlock Recovery Seed (requires 100)")
    }

    func testUnlock_100RP_GetsSeed() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 100, isPremium: false)
        XCTAssertTrue(unlocked.contains { $0.id == "seed" },
                      "100 RP should unlock Recovery Seed")
    }

    func testUnlock_249RP_NoFlame() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 249, isPremium: false)
        XCTAssertFalse(unlocked.contains { $0.id == "flame" })
    }

    func testUnlock_250RP_GetsFlame() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 250, isPremium: false)
        XCTAssertTrue(unlocked.contains { $0.id == "flame" })
    }

    func testUnlock_499RP_NoShield() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 499, isPremium: false)
        XCTAssertFalse(unlocked.contains { $0.id == "shield" })
    }

    func testUnlock_500RP_GetsShield() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 500, isPremium: false)
        XCTAssertTrue(unlocked.contains { $0.id == "shield" })
    }

    func testUnlock_500RP_PremiumGetsProgramCollectibles() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 500, isPremium: true)
        let premiumUnlocked = unlocked.filter { $0.isPremium }
        XCTAssertEqual(premiumUnlocked.count, 12,
                       "Premium user at 500 RP should unlock all 12 program collectibles")
    }

    func testUnlock_500RP_FreeGetsNoProgramCollectibles() {
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: 500, isPremium: false)
        let premiumUnlocked = unlocked.filter { $0.isPremium }
        XCTAssertEqual(premiumUnlocked.count, 0,
                       "Free user should not unlock premium program collectibles")
    }

    // MARK: Simulated point accumulation

    func testPointAccumulation_30DayScenario() {
        // Simulate 30 days: daily check-in + 1 journal/week + 2 cravings resisted/week
        var totalPoints = 0
        for day in 1...30 {
            totalPoints += RecoveryPointAction.dailyCheckIn.points // 10
            totalPoints += RecoveryPointAction.streakBonusPoints(forDay: day) // 5*day capped at 50
            if day % 7 == 0 {
                totalPoints += RecoveryPointAction.journalEntry.points // 15
            }
            if day % 3 == 0 {
                totalPoints += RecoveryPointAction.cravingResisted.points // 25
            }
        }
        XCTAssertGreaterThan(totalPoints, 0, "30-day scenario should accumulate points")
        // Expected: 30*10 + (5+10+15+20+25+30+35+40+45+50*21) + 4*15 + 10*25
        // The key point: the user should have unlocked some collectibles
        let unlocked = RewardCatalog.unlockedCollectibles(totalRP: totalPoints, isPremium: false)
        XCTAssertGreaterThan(unlocked.count, 0,
                             "30 days of activity (\(totalPoints) RP) should unlock at least 1 collectible")
    }
}

// MARK: - Daily Log Entry Tests

final class DailyLogEntryTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testCreateDailyLogEntry() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let log = CDDailyLogEntry.create(in: ctx, habit: habit, didPledge: true,
                                          pledgeText: "I will stay strong")
        XCTAssertTrue(log.didPledge)
        XCTAssertEqual(log.pledgeText, "I will stay strong")
        XCTAssertFalse(log.lapsedToday)
        XCTAssertEqual(log.habit, habit)
    }

    func testDailyLogLapseFlag() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let log = CDDailyLogEntry.create(in: ctx, habit: habit, lapsedToday: true,
                                          lapseNotes: "Gave in after dinner")
        XCTAssertTrue(log.lapsedToday)
        XCTAssertEqual(log.lapseNotes, "Gave in after dinner")
    }

    func testDailyLogMoodDefault() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let log = CDDailyLogEntry.create(in: ctx, habit: habit)
        XCTAssertEqual(log.mood, 3)
    }

    func testDailyLogLinkedToHabit() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        CDDailyLogEntry.create(in: ctx, habit: habit)
        CDDailyLogEntry.create(in: ctx, habit: habit)
        let logs = habit.dailyLogs as? Set<CDDailyLogEntry> ?? []
        XCTAssertEqual(logs.count, 2)
    }

    func testDailyLogDatePersists() throws {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking")
        let specificDate = Calendar.current.daysAgo(5)
        CDDailyLogEntry.create(in: ctx, habit: habit, date: specificDate)
        try ctx.save()

        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        let results = try ctx.fetch(request)
        XCTAssertEqual(results.count, 1)
        let cal = Calendar.current
        XCTAssertEqual(cal.startOfDay(for: results.first!.date),
                       cal.startOfDay(for: specificDate))
    }
}

// MARK: - Habit Creation Tests

final class HabitCreationTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    func testHabitDefaultsAreCorrect() {
        let habit = CDHabit.create(in: ctx, name: "Quit Smoking", programType: "smoking")
        XCTAssertEqual(habit.name, "Quit Smoking")
        XCTAssertEqual(habit.programType, "smoking")
        XCTAssertTrue(habit.isActive)
        XCTAssertEqual(habit.goalDays, 30)
        XCTAssertEqual(habit.sortOrder, 0)
        XCTAssertEqual(habit.baselineCostPerDay, 0)
        XCTAssertEqual(habit.baselineTimePerDay, 0)
    }

    func testHabitCustomFields() {
        let habit = CDHabit.create(in: ctx, name: "No Alcohol", programType: "alcohol",
                                   goalDays: 90, baselineCostPerDay: 15.0,
                                   baselineTimePerDay: 120.0,
                                   costPerUnit: 8.0, timePerUnit: 30.0, dailyUnits: 3.0,
                                   reasonToQuit: "For my family")
        XCTAssertEqual(habit.goalDays, 90)
        XCTAssertEqual(habit.baselineCostPerDay, 15.0)
        XCTAssertEqual(habit.baselineTimePerDay, 120.0)
        XCTAssertEqual(habit.costPerUnit, 8.0)
        XCTAssertEqual(habit.timePerUnit, 30.0)
        XCTAssertEqual(habit.dailyUnits, 3.0)
        XCTAssertEqual(habit.reasonToQuit, "For my family")
    }

    func testHabitPersistsToFetch() throws {
        CDHabit.create(in: ctx, name: "Quit Gaming", programType: "gaming")
        try ctx.save()

        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.predicate = NSPredicate(format: "programType == %@", "gaming")
        let results = try ctx.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Quit Gaming")
    }

    func testHabitStartDateAffectsDaysSober() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: cal.daysAgo(42))
        XCTAssertEqual(habit.daysSoberCount, 42)
    }

    func testHabitMoneySavedCalculation() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(20),
                                   baselineCostPerDay: 12.50)
        XCTAssertEqual(habit.moneySaved, 250.0, accuracy: 0.01)
    }

    func testHabitTimeSavedCalculation() {
        let habit = CDHabit.create(in: ctx, name: "Test", programType: "phone",
                                   startDate: Calendar.current.daysAgo(10),
                                   baselineTimePerDay: 90.0)
        XCTAssertEqual(habit.timeSavedMinutes, 900.0, accuracy: 0.01)
    }
}

// MARK: - ProgramType Coverage Tests

final class ProgramTypeCoverageTests: XCTestCase {

    func testAllProgramTypesExist() {
        let expected: [ProgramType] = [
            .smoking, .alcohol, .porn, .phone, .socialMedia, .gaming,
            .procrastination, .sugar, .emotionalEating, .shopping,
            .gambling, .sleep, .custom
        ]
        XCTAssertEqual(ProgramType.allCases.count, expected.count)
        for pt in expected {
            XCTAssertTrue(ProgramType.allCases.contains(pt), "\(pt.rawValue) should exist")
        }
    }

    func testEveryNonCustomProgramHasBadges() {
        let programsWithBadges: [ProgramType] = [
            .smoking, .alcohol, .porn, .phone, .socialMedia, .gaming,
            .procrastination, .sugar, .emotionalEating, .shopping,
            .gambling, .sleep
        ]
        for program in programsWithBadges {
            let badges = MilestoneBadge.programBadges.filter { $0.programType == program }
            XCTAssertEqual(badges.count, 3,
                           "\(program.rawValue) should have 3 program badges")
        }
    }

    func testCustomProgramHasNoBadges() {
        let badges = MilestoneBadge.programBadges.filter { $0.programType == .custom }
        XCTAssertEqual(badges.count, 0, "Custom program should have no program badges")
    }

    func testAllProgramTypesHaveDisplayNames() {
        for pt in ProgramType.allCases {
            XCTAssertFalse(pt.displayName.isEmpty, "\(pt.rawValue) should have a display name")
        }
    }

    func testAllProgramTypesHaveIcons() {
        for pt in ProgramType.allCases {
            XCTAssertFalse(pt.iconName.isEmpty, "\(pt.rawValue) should have an icon")
        }
    }

    func testAllProgramTypesHaveColorHex() {
        for pt in ProgramType.allCases {
            XCTAssertTrue(pt.colorHex.hasPrefix("#"), "\(pt.rawValue) colorHex should start with #")
        }
    }

    func testAllProgramTypesHaveTaglines() {
        for pt in ProgramType.allCases {
            XCTAssertFalse(pt.tagline.isEmpty, "\(pt.rawValue) should have a tagline")
        }
    }
}

// MARK: - Integration: Full Badge Evaluation Simulation

final class BadgeEvaluationSimulationTests: XCTestCase {

    private var stack: CoreDataStack!
    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack.preview
        ctx = stack.viewContext
    }

    override func tearDown() {
        ctx.rollback()
        super.tearDown()
    }

    /// Simulates evaluating all badges for a 90-day smoking recovery user.
    func testFullBadgeEvaluation_90DaySmokingUser() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Quit Smoking", programType: ProgramType.smoking.rawValue,
                                   startDate: cal.daysAgo(90),
                                   baselineCostPerDay: 15.0, baselineTimePerDay: 30.0)

        // Create 25 journal entries
        for i in 0..<25 {
            let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Journal \(i)")
            entry.date = cal.daysAgo(i * 3)
        }

        // Create 30 resisted cravings with 6 different tools
        let tools = ["breathing", "exercise", "journaling", "meditation", "cold_shower", "walking"]
        for i in 0..<30 {
            CDCravingEntry.create(in: ctx, habit: habit,
                                  copingToolUsed: tools[i % tools.count], didResist: true)
        }

        let daysSober = habit.daysSoberCount
        let streak = habit.currentStreak

        // Time badges earned
        let earnedTimeBadges = MilestoneBadge.timeBadges.filter { daysSober >= $0.requiredDays }
        let expectedTimeKeys: Set<String> = ["1_day", "3_days", "1_week", "2_weeks", "1_month", "2_months", "3_months"]
        XCTAssertEqual(Set(earnedTimeBadges.map(\.key)), expectedTimeKeys,
                       "90-day user should earn 7 time badges")

        // Streak badges earned (no lapses => streak == daysSober)
        XCTAssertEqual(streak, daysSober)
        let earnedStreakBadges = MilestoneBadge.streakBadges.filter { streak >= $0.requiredDays }
        let expectedStreakKeys: Set<String> = ["streak_3", "streak_7", "streak_14", "streak_30", "streak_60"]
        XCTAssertEqual(Set(earnedStreakBadges.map(\.key)), expectedStreakKeys,
                       "90-day streak should earn 5 streak badges")

        // Program badges earned
        let earnedProgramBadges = MilestoneBadge.programBadges.filter {
            $0.programType == .smoking && daysSober >= $0.requiredDays
        }
        XCTAssertEqual(earnedProgramBadges.count, 3, "90-day smoking user earns all 3 smoking badges")

        // Behavior badges
        let journalCount = (habit.journalEntries as? Set<CDJournalEntry>)?.count ?? 0
        XCTAssertTrue(journalCount >= 1, "first_journal earned")
        XCTAssertTrue(journalCount >= 10, "journal_10 earned")
        XCTAssertFalse(journalCount >= 50, "journal_50 NOT earned (only 25)")

        let resistedCount = (habit.cravingEntries as? Set<CDCravingEntry>)?.filter { $0.didResist }.count ?? 0
        XCTAssertTrue(resistedCount >= 10, "craving_crusher_10 earned")
        XCTAssertFalse(resistedCount >= 50, "craving_crusher_50 NOT earned (only 30)")

        let uniqueTools = Set(((habit.cravingEntries as? Set<CDCravingEntry>) ?? []).compactMap(\.copingToolUsed))
        XCTAssertTrue(uniqueTools.count >= 5, "tool_explorer earned (6 tools used)")

        // Money saved: 90 * 15 = $1350
        XCTAssertGreaterThanOrEqual(habit.moneySaved, 1000.0, "money_1000 earned")
        XCTAssertLessThan(habit.moneySaved, 5000.0, "money_5000 NOT earned")

        // Time saved: 90 * 30 = 2700 min = 45 hours
        XCTAssertLessThan(habit.timeSavedMinutes, 6000.0, "time_100 NOT earned (only 45 hours)")
    }

    /// Simulates a 365-day power user who has earned everything possible.
    func testFullBadgeEvaluation_365DayPowerUser() {
        let cal = Calendar.current
        let habit = CDHabit.create(in: ctx, name: "Quit Alcohol", programType: ProgramType.alcohol.rawValue,
                                   startDate: cal.daysAgo(365),
                                   baselineCostPerDay: 20.0, baselineTimePerDay: 60.0)

        // 50 journal entries
        for i in 0..<50 {
            let entry = CDJournalEntry.create(in: ctx, habit: habit, body: "Journal \(i)")
            entry.date = cal.daysAgo(i * 7)
        }

        // 50 resisted cravings
        let tools = ["breathing", "exercise", "journaling", "meditation", "cold_shower", "walking", "calling_friend"]
        for i in 0..<50 {
            CDCravingEntry.create(in: ctx, habit: habit,
                                  copingToolUsed: tools[i % tools.count], didResist: true)
        }

        let daysSober = habit.daysSoberCount

        // All time badges up to 1 year
        let earnedTimeBadges = MilestoneBadge.timeBadges.filter { daysSober >= $0.requiredDays }
        XCTAssertEqual(earnedTimeBadges.count, 10,
                       "365-day user should earn 10 time badges (up to 1_year)")

        // All streak badges up to streak_200 (no lapses)
        let streak = habit.currentStreak
        XCTAssertEqual(streak, 365)
        let earnedStreakBadges = MilestoneBadge.streakBadges.filter { streak >= $0.requiredDays }
        XCTAssertEqual(earnedStreakBadges.count, 8, "365-day streak should earn all 8 streak badges")

        // All 3 alcohol program badges
        let earnedProgramBadges = MilestoneBadge.programBadges.filter {
            $0.programType == .alcohol && daysSober >= $0.requiredDays
        }
        XCTAssertEqual(earnedProgramBadges.count, 3)

        // Behavior: journal_50 earned
        let journalCount = (habit.journalEntries as? Set<CDJournalEntry>)?.count ?? 0
        XCTAssertTrue(journalCount >= 50, "journal_50 earned")

        // Behavior: craving_crusher_50 earned
        let resistedCount = (habit.cravingEntries as? Set<CDCravingEntry>)?.filter { $0.didResist }.count ?? 0
        XCTAssertTrue(resistedCount >= 50, "craving_crusher_50 earned")

        // Money: 365 * 20 = $7300
        XCTAssertGreaterThanOrEqual(habit.moneySaved, 5000.0, "money_5000 earned")

        // Time: 365 * 60 = 21900 min = 365 hours
        XCTAssertGreaterThanOrEqual(habit.timeSavedMinutes, 6000.0, "time_100 earned")
        XCTAssertFalse(habit.timeSavedMinutes >= 30000.0, "time_500 NOT earned (365 hours)")
    }

    /// Tests that a brand new user on day 0 earns zero badges.
    func testFullBadgeEvaluation_DayZeroUser() {
        let habit = CDHabit.create(in: ctx, name: "Fresh Start", programType: "smoking",
                                   startDate: Calendar.current.daysAgo(0))

        let daysSober = habit.daysSoberCount
        XCTAssertEqual(daysSober, 0)

        let earnedTimeBadges = MilestoneBadge.timeBadges.filter { daysSober >= $0.requiredDays }
        XCTAssertEqual(earnedTimeBadges.count, 0, "Day 0 user should earn no time badges")

        let earnedStreakBadges = MilestoneBadge.streakBadges.filter { habit.currentStreak >= $0.requiredDays }
        XCTAssertEqual(earnedStreakBadges.count, 0, "Day 0 user should earn no streak badges")

        let earnedProgramBadges = MilestoneBadge.programBadges.filter {
            $0.programType == .smoking && daysSober >= $0.requiredDays
        }
        XCTAssertEqual(earnedProgramBadges.count, 0, "Day 0 user should earn no program badges")

        XCTAssertEqual(habit.moneySaved, 0.0, "Day 0 user has saved no money")
        XCTAssertEqual(habit.timeSavedMinutes, 0.0, "Day 0 user has saved no time")
    }
}
