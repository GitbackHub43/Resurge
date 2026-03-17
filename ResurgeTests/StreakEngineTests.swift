import XCTest
import CoreData
@testable import Resurge

final class StreakEngineTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.preview.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func testDaysSoberFromStartDate() {
        let habit = makeHabit(daysAgo: 14)

        XCTAssertEqual(habit.daysSoberCount, 14, "Should count 14 days since start")
    }

    func testDaysSoberZeroForToday() {
        let habit = makeHabit(daysAgo: 0)

        XCTAssertEqual(habit.daysSoberCount, 0, "Should be 0 days for today's start")
    }

    func testCurrentStreakWithNoLapses() {
        let habit = makeHabit(daysAgo: 10)
        // No lapse logs means streak = days sober
        XCTAssertEqual(habit.currentStreak, 10, "Streak should equal days sober with no lapses")
    }

    func testProgressToGoal() {
        let habit = makeHabit(daysAgo: 15)
        habit.goalDays = 30

        let progress = Double(habit.daysSoberCount) / Double(habit.goalDays)
        XCTAssertEqual(progress, 0.5, accuracy: 0.01, "Should be 50% to goal")
    }

    func testGoalReached() {
        let habit = makeHabit(daysAgo: 30)
        habit.goalDays = 30

        let progress = min(1.0, Double(habit.daysSoberCount) / Double(habit.goalDays))
        XCTAssertEqual(progress, 1.0, accuracy: 0.01, "Should be 100% at goal")
    }

    func testGoalExceeded() {
        let habit = makeHabit(daysAgo: 45)
        habit.goalDays = 30

        XCTAssertGreaterThan(habit.daysSoberCount, Int(habit.goalDays), "Days should exceed goal")
    }

    // MARK: - Helpers

    private func makeHabit(daysAgo: Int) -> CDHabit {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Test Streak"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        habit.goalDays = 30
        habit.costPerUnit = 1
        habit.dailyUnits = 1
        habit.timePerUnit = 1
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()
        return habit
    }
}
