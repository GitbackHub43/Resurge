import XCTest
import CoreData
@testable import Resurge

final class MetricsEngineTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.preview.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func makeHabit(startDaysAgo: Int = 10, dailyUnits: Double = 0) -> CDHabit {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Test"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -startDaysAgo, to: Date()) ?? Date()
        habit.dailyUnits = dailyUnits
        habit.costPerUnit = 0
        habit.timePerUnit = 0
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()
        return habit
    }

    private func makeDailyLog(habit: CDHabit, daysAgo: Int, lapsed: Bool) {
        let log = CDDailyLogEntry(context: context)
        log.id = UUID()
        log.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        log.lapsedToday = lapsed
        log.mood = 3
        log.createdAt = Date()
        log.habit = habit
        habit.addToDailyLogs(log)
    }

    private func makeCravingEntry(
        habit: CDHabit,
        daysAgo: Int,
        eventType: String = "CRAVING",
        outcome: String = "resisted",
        quantity: Double = 0
    ) {
        let entry = CDCravingEntry(context: context)
        entry.id = UUID()
        entry.timestamp = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        entry.eventType = eventType
        entry.outcome = outcome
        entry.quantity = quantity
        entry.intensity = 5
        entry.durationSeconds = 0
        entry.mood = 3
        entry.habit = habit
        habit.addToCravingEntries(entry)
    }

    // MARK: - bestStreak

    func testBestStreakNoLapses() {
        let habit = makeHabit(startDaysAgo: 5)
        // No daily logs means no lapses; streak should cover all days including today
        let result = MetricsEngine.bestStreak(for: habit)
        // 5 days ago through today = 6 days
        XCTAssertEqual(result, 6, "Best streak with no lapses should be startDaysAgo + 1 (including today)")
    }

    func testBestStreakWithLapseInMiddle() {
        let habit = makeHabit(startDaysAgo: 6)
        // Lapse on day 3 ago splits the streak
        makeDailyLog(habit: habit, daysAgo: 3, lapsed: true)

        let result = MetricsEngine.bestStreak(for: habit)
        // Days 6,5,4 = 3 clean days, then lapse on day 3, then days 2,1,0 = 3 clean days
        // The first segment (days 6..4) is 3 days, the second (days 2..0) is 3 days
        // But from start: days 6,5,4 = 3 consecutive, then lapse resets, then 2,1,0 = 3
        XCTAssertEqual(result, 3, "Best streak should be 3 when a lapse splits 7 days into two halves")
    }

    func testBestStreakAllLapsed() {
        let habit = makeHabit(startDaysAgo: 3)
        for d in 0...3 {
            makeDailyLog(habit: habit, daysAgo: d, lapsed: true)
        }
        let result = MetricsEngine.bestStreak(for: habit)
        XCTAssertEqual(result, 0, "Best streak should be 0 when every day is a lapse")
    }

    func testBestStreakFutureStartDate() {
        let habit = makeHabit(startDaysAgo: -5) // 5 days in the future
        let result = MetricsEngine.bestStreak(for: habit)
        XCTAssertEqual(result, 0, "Best streak should be 0 for a future start date")
    }

    func testBestStreakLapseOnFirstDay() {
        let habit = makeHabit(startDaysAgo: 4)
        makeDailyLog(habit: habit, daysAgo: 4, lapsed: true)

        let result = MetricsEngine.bestStreak(for: habit)
        // Lapse on day 4 (start), then clean days 3,2,1,0 = 4
        XCTAssertEqual(result, 4, "Best streak should skip the lapse on the first day")
    }

    // MARK: - rolling7dFrequency

    func testRolling7dFrequencyNoEpisodes() {
        let habit = makeHabit()
        let result = MetricsEngine.rolling7dFrequency(for: habit)
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "Frequency should be 0 with no use episodes")
    }

    func testRolling7dFrequencyWithEpisodes() {
        let habit = makeHabit()
        // 3 USE_EPISODE entries within last 7 days
        makeCravingEntry(habit: habit, daysAgo: 1, eventType: "USE_EPISODE", quantity: 2)
        makeCravingEntry(habit: habit, daysAgo: 3, eventType: "USE_EPISODE", quantity: 1)
        makeCravingEntry(habit: habit, daysAgo: 5, eventType: "USE_EPISODE", quantity: 3)
        // 1 non-USE_EPISODE entry (should be ignored)
        makeCravingEntry(habit: habit, daysAgo: 2, eventType: "CRAVING", quantity: 0)

        let result = MetricsEngine.rolling7dFrequency(for: habit)
        XCTAssertEqual(result, 3.0 / 7.0, accuracy: 0.001, "Frequency should be 3/7 with 3 episodes in 7 days")
    }

    func testRolling7dFrequencyIgnoresOldEpisodes() {
        let habit = makeHabit(startDaysAgo: 20)
        // Episode outside the 7-day window
        makeCravingEntry(habit: habit, daysAgo: 10, eventType: "USE_EPISODE", quantity: 5)
        // Episode inside the 7-day window
        makeCravingEntry(habit: habit, daysAgo: 2, eventType: "USE_EPISODE", quantity: 1)

        let result = MetricsEngine.rolling7dFrequency(for: habit)
        XCTAssertEqual(result, 1.0 / 7.0, accuracy: 0.001, "Only episodes within the last 7 days should count")
    }

    // MARK: - rolling7dQuantityAvg

    func testRolling7dQuantityAvgNoEpisodes() {
        let habit = makeHabit()
        let result = MetricsEngine.rolling7dQuantityAvg(for: habit)
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "Average quantity should be 0 with no episodes")
    }

    func testRolling7dQuantityAvgWithEpisodes() {
        let habit = makeHabit()
        makeCravingEntry(habit: habit, daysAgo: 1, eventType: "USE_EPISODE", quantity: 4)
        makeCravingEntry(habit: habit, daysAgo: 3, eventType: "USE_EPISODE", quantity: 6)
        makeCravingEntry(habit: habit, daysAgo: 5, eventType: "USE_EPISODE", quantity: 2)

        let result = MetricsEngine.rolling7dQuantityAvg(for: habit)
        // (4 + 6 + 2) / 3 = 4.0
        XCTAssertEqual(result, 4.0, accuracy: 0.001, "Average quantity should be the mean of episode quantities")
    }

    func testRolling7dQuantityAvgIgnoresNonEpisodes() {
        let habit = makeHabit()
        makeCravingEntry(habit: habit, daysAgo: 1, eventType: "USE_EPISODE", quantity: 10)
        makeCravingEntry(habit: habit, daysAgo: 2, eventType: "CRAVING", quantity: 100)

        let result = MetricsEngine.rolling7dQuantityAvg(for: habit)
        XCTAssertEqual(result, 10.0, accuracy: 0.001, "Average should only include USE_EPISODE entries")
    }

    // MARK: - resilienceRate

    func testResilienceRateNoCravings() {
        let habit = makeHabit()
        let result = MetricsEngine.resilienceRate(for: habit)
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "Resilience rate should be 1.0 when there are no cravings")
    }

    func testResilienceRateAllResisted() {
        let habit = makeHabit()
        makeCravingEntry(habit: habit, daysAgo: 1, outcome: "resisted")
        makeCravingEntry(habit: habit, daysAgo: 2, outcome: "resisted")
        makeCravingEntry(habit: habit, daysAgo: 3, outcome: "resisted")

        let result = MetricsEngine.resilienceRate(for: habit)
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "Resilience rate should be 1.0 when all cravings were resisted")
    }

    func testResilienceRateNoneResisted() {
        let habit = makeHabit()
        makeCravingEntry(habit: habit, daysAgo: 1, outcome: "gave_in")
        makeCravingEntry(habit: habit, daysAgo: 2, outcome: "gave_in")

        let result = MetricsEngine.resilienceRate(for: habit)
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "Resilience rate should be 0.0 when no cravings were resisted")
    }

    func testResilienceRateMixed() {
        let habit = makeHabit()
        makeCravingEntry(habit: habit, daysAgo: 1, outcome: "resisted")
        makeCravingEntry(habit: habit, daysAgo: 2, outcome: "gave_in")
        makeCravingEntry(habit: habit, daysAgo: 3, outcome: "resisted")
        makeCravingEntry(habit: habit, daysAgo: 4, outcome: "gave_in")

        let result = MetricsEngine.resilienceRate(for: habit)
        XCTAssertEqual(result, 0.5, accuracy: 0.001, "Resilience rate should be 0.5 when half were resisted")
    }

    func testResilienceRateIgnoresOldEntries() {
        let habit = makeHabit(startDaysAgo: 20)
        // Old entry outside 7-day window
        makeCravingEntry(habit: habit, daysAgo: 10, outcome: "gave_in")
        // Recent entry inside 7-day window
        makeCravingEntry(habit: habit, daysAgo: 1, outcome: "resisted")

        let result = MetricsEngine.resilienceRate(for: habit)
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "Resilience rate should only consider last 7 days")
    }

    // MARK: - improvementVsBaseline

    func testImprovementVsBaselineZeroDailyUnits() {
        let habit = makeHabit(dailyUnits: 0)
        let result = MetricsEngine.improvementVsBaseline(for: habit)
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "Improvement should be 0 when dailyUnits is 0")
    }

    func testImprovementVsBaselineNoEpisodes() {
        let habit = makeHabit(dailyUnits: 10)
        // No USE_EPISODE entries means rolling avg is 0 → improvement = (10 - 0) / 10 = 1.0
        let result = MetricsEngine.improvementVsBaseline(for: habit)
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "Full improvement when no recent use episodes")
    }

    func testImprovementVsBaselinePartialImprovement() {
        let habit = makeHabit(dailyUnits: 10)
        // Two episodes averaging quantity 4 → improvement = (10 - 4) / 10 = 0.6
        makeCravingEntry(habit: habit, daysAgo: 1, eventType: "USE_EPISODE", quantity: 2)
        makeCravingEntry(habit: habit, daysAgo: 2, eventType: "USE_EPISODE", quantity: 6)

        let result = MetricsEngine.improvementVsBaseline(for: habit)
        XCTAssertEqual(result, 0.6, accuracy: 0.001, "Improvement should reflect partial reduction from baseline")
    }

    func testImprovementVsBaselineNoImprovement() {
        let habit = makeHabit(dailyUnits: 5)
        // Average quantity equals baseline → improvement = 0
        makeCravingEntry(habit: habit, daysAgo: 1, eventType: "USE_EPISODE", quantity: 5)

        let result = MetricsEngine.improvementVsBaseline(for: habit)
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "No improvement when average equals baseline")
    }

    func testImprovementVsBaselineClampedAtZero() {
        let habit = makeHabit(dailyUnits: 5)
        // Average quantity exceeds baseline → should clamp to 0
        makeCravingEntry(habit: habit, daysAgo: 1, eventType: "USE_EPISODE", quantity: 10)

        let result = MetricsEngine.improvementVsBaseline(for: habit)
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "Improvement should clamp to 0 when usage exceeds baseline")
    }

    func testImprovementVsBaselineClampedAtOne() {
        let habit = makeHabit(dailyUnits: 20)
        // No episodes → rolling avg = 0 → improvement = 1.0 (clamped)
        let result = MetricsEngine.improvementVsBaseline(for: habit)
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "Improvement should clamp to 1.0 at maximum")
    }
}
