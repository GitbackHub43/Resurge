import XCTest
import CoreData
@testable import Resurge

final class SavingsCalculatorTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.preview.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func testMoneySavedCalculation() {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Test"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        habit.costPerUnit = 0.50
        habit.dailyUnits = 20
        habit.timePerUnit = 5
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()

        // 10 days × 20 units × $0.50 = $100
        let saved = habit.moneySaved
        XCTAssertEqual(saved, 100.0, accuracy: 1.0, "Money saved should be approximately $100")
    }

    func testTimeSavedCalculation() {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Test"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        habit.costPerUnit = 0.50
        habit.dailyUnits = 20
        habit.timePerUnit = 5 // 5 minutes per unit
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()

        // 10 days × 20 units × 5 min = 1000 minutes
        let timeSaved = habit.timeSavedMinutes
        XCTAssertEqual(timeSaved, 1000.0, accuracy: 10.0, "Time saved should be approximately 1000 minutes")
    }

    func testZeroDaysNoSavings() {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Test"
        habit.programType = "smoking"
        habit.startDate = Date() // started today
        habit.costPerUnit = 10
        habit.dailyUnits = 5
        habit.timePerUnit = 10
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()

        XCTAssertEqual(habit.moneySaved, 0.0, accuracy: 0.01)
        XCTAssertEqual(habit.timeSavedMinutes, 0.0, accuracy: 0.01)
    }

    func testFutureStartDateNoSavings() {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Test"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        habit.costPerUnit = 10
        habit.dailyUnits = 5
        habit.timePerUnit = 10
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()

        XCTAssertEqual(habit.moneySaved, 0.0, accuracy: 0.01)
        XCTAssertEqual(habit.daysSoberCount, 0)
    }
}
