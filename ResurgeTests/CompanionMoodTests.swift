import XCTest
import CoreData
@testable import Resurge

final class CompanionMoodTests: XCTestCase {

    private var stack: CoreDataStack!
    private var context: NSManagedObjectContext!
    private var service: VirtualCompanionService!

    override func setUpWithError() throws {
        stack = CoreDataStack.preview
        context = stack.viewContext
        service = VirtualCompanionService(context: context)
    }

    override func tearDownWithError() throws {
        // Clean up all entities between tests
        let entityNames = ["CDHabit", "CDJournalEntry", "CDCravingEntry", "CDVirtualCompanion"]
        for name in entityNames {
            let request = NSFetchRequest<NSManagedObject>(entityName: name)
            let objects = (try? context.fetch(request)) ?? []
            for obj in objects {
                context.delete(obj)
            }
        }
        try? context.save()
        service = nil
    }

    // MARK: - Mood: 30+ Day Streak with 3+ Journals

    func testMoodEcstaticWith30DayStreakAnd3Journals() {
        let habit = createHabit(daysAgo: 35)
        createJournalEntries(count: 3, for: habit)
        try? context.save()

        let mood = service.computeMoodFromRecovery(habits: [habit], context: context)

        XCTAssertEqual(mood, "ecstatic",
            "30+ day streak with 3+ journal entries in last 7 days should yield ecstatic mood")
    }

    func testMoodProudWith30DayStreakAnd2Journals() {
        let habit = createHabit(daysAgo: 30)
        createJournalEntries(count: 2, for: habit)
        try? context.save()

        let mood = service.computeMoodFromRecovery(habits: [habit], context: context)

        XCTAssertEqual(mood, "proud",
            "30+ day streak with 2 journal entries should yield proud mood")
    }

    // MARK: - Mood: 7-13 Day Streak

    func testMoodHappyOrBetterWith7DayStreak() {
        let habit = createHabit(daysAgo: 7)
        try? context.save()

        let mood = service.computeMoodFromRecovery(habits: [habit], context: context)
        let happyOrBetter = ["happy", "proud", "ecstatic"]

        XCTAssertTrue(happyOrBetter.contains(mood),
            "7-day streak should yield happy or better mood, got \(mood)")
    }

    func testMoodHappyWith13DayStreak() {
        let habit = createHabit(daysAgo: 13)
        try? context.save()

        let mood = service.computeMoodFromRecovery(habits: [habit], context: context)
        let happyOrBetter = ["happy", "proud", "ecstatic"]

        XCTAssertTrue(happyOrBetter.contains(mood),
            "13-day streak should yield happy or better mood, got \(mood)")
    }

    // MARK: - Mood: 0 Day Streak

    func testMoodSadWithZeroDayStreak() {
        let habit = createHabit(daysAgo: 0)
        try? context.save()

        let mood = service.computeMoodFromRecovery(habits: [habit], context: context)
        let sadOrWorried = ["sad", "worried"]

        XCTAssertTrue(sadOrWorried.contains(mood),
            "0-day streak should yield sad or worried mood, got \(mood)")
    }

    // MARK: - levelForStreak

    func testLevelForStreak0Returns1() {
        XCTAssertEqual(service.levelForStreak(0), 1)
    }

    func testLevelForStreak7Returns2() {
        XCTAssertEqual(service.levelForStreak(7), 2)
    }

    func testLevelForStreak14Returns3() {
        XCTAssertEqual(service.levelForStreak(14), 3)
    }

    func testLevelForStreak30Returns4() {
        XCTAssertEqual(service.levelForStreak(30), 4)
    }

    func testLevelForStreak60Returns5() {
        XCTAssertEqual(service.levelForStreak(60), 5)
    }

    func testLevelForStreak90Returns6() {
        XCTAssertEqual(service.levelForStreak(90), 6)
    }

    // MARK: - Contextual Message

    func testContextualMessageNonEmptyForLongStreak() {
        let habit = createHabit(daysAgo: 45)
        try? context.save()

        let message = service.contextualMessage(for: [habit], context: context)
        XCTAssertFalse(message.isEmpty, "Contextual message should not be empty for long streak")
    }

    func testContextualMessageNonEmptyForZeroStreak() {
        let habit = createHabit(daysAgo: 0)
        try? context.save()

        let message = service.contextualMessage(for: [habit], context: context)
        XCTAssertFalse(message.isEmpty, "Contextual message should not be empty for zero streak")
    }

    func testContextualMessageNonEmptyForOneWeekStreak() {
        let habit = createHabit(daysAgo: 7)
        try? context.save()

        let message = service.contextualMessage(for: [habit], context: context)
        XCTAssertFalse(message.isEmpty, "Contextual message should not be empty for 7-day streak")
    }

    func testContextualMessageNonEmptyForNoHabits() {
        let message = service.contextualMessage(for: [], context: context)
        XCTAssertFalse(message.isEmpty, "Contextual message should not be empty even with no habits")
    }

    // MARK: - addXP is a No-Op

    func testAddXPIsNoOp() {
        let companion = service.getOrCreate(context: context)
        let xpBefore = companion.xp

        service.addXP(100)

        XCTAssertEqual(companion.xp, xpBefore,
            "addXP should be a no-op; XP should not change")
    }

    // MARK: - Helpers

    /// Creates an active CDHabit with a start date `daysAgo` days in the past.
    private func createHabit(daysAgo: Int) -> CDHabit {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: Date()))!
        return CDHabit.create(
            in: context,
            name: "Test Habit",
            programType: "smoking",
            startDate: startDate
        )
    }

    /// Creates journal entries dated within the last 7 days for a given habit.
    private func createJournalEntries(count: Int, for habit: CDHabit) {
        let calendar = Calendar.current
        for i in 0..<count {
            let entry = CDJournalEntry(context: context)
            entry.id = UUID()
            entry.date = calendar.date(byAdding: .day, value: -i, to: Date())!
            entry.body = "Test journal entry \(i)"
            entry.mood = 3
            entry.isReflection = false
            entry.createdAt = Date()
            entry.updatedAt = Date()
            entry.habit = habit
        }
    }
}
