import XCTest
import CoreData
@testable import Resurge

final class RepositoryTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.preview.viewContext
    }

    override func tearDown() {
        // Clean up all test entities so tests are isolated
        let habitRequest = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        if let habits = try? context.fetch(habitRequest) {
            habits.forEach { context.delete($0) }
        }
        let logRequest = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        if let logs = try? context.fetch(logRequest) {
            logs.forEach { context.delete($0) }
        }
        let cravingRequest = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        if let cravings = try? context.fetch(cravingRequest) {
            cravings.forEach { context.delete($0) }
        }
        try? context.save()
        context = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func makeHabitRepository() -> CoreDataHabitRepository {
        CoreDataHabitRepository(context: context)
    }

    private func makeLogRepository() -> CoreDataLogRepository {
        CoreDataLogRepository(context: context)
    }

    private func makeCravingRepository() -> CoreDataCravingRepository {
        CoreDataCravingRepository(context: context)
    }

    /// Creates a habit via the repository and returns it.
    @discardableResult
    private func createTestHabit(
        name: String = "Quit Smoking",
        programType: ProgramType = .smoking
    ) -> CDHabit {
        let repo = makeHabitRepository()
        return repo.create(
            name: name,
            programType: programType,
            startDate: Date(),
            goalDays: 30,
            costPerUnit: 0.50,
            timePerUnit: 5,
            dailyUnits: 20,
            reasonToQuit: "Health"
        )
    }

    // MARK: - HabitRepository: Create

    func testCreateHabitAndVerifyItExists() {
        let repo = makeHabitRepository()
        let habit = createTestHabit()

        let all = repo.fetchAll()
        XCTAssertTrue(all.contains(where: { $0.id == habit.id }),
                      "Newly created habit should appear in fetchAll results")
        XCTAssertEqual(habit.name, "Quit Smoking")
        XCTAssertEqual(habit.programType, ProgramType.smoking.rawValue)
        XCTAssertTrue(habit.isActive)
    }

    // MARK: - HabitRepository: Fetch Active

    func testFetchActiveHabitsExcludesInactive() {
        let repo = makeHabitRepository()

        let activeHabit = createTestHabit(name: "Active Habit")

        let inactiveHabit = createTestHabit(name: "Inactive Habit")
        inactiveHabit.isActive = false
        repo.update(inactiveHabit)

        let activeHabits = repo.fetchActive()
        XCTAssertTrue(activeHabits.contains(where: { $0.id == activeHabit.id }),
                      "Active habit should appear in fetchActive results")
        XCTAssertFalse(activeHabits.contains(where: { $0.id == inactiveHabit.id }),
                       "Inactive habit should not appear in fetchActive results")
    }

    // MARK: - HabitRepository: Update

    func testUpdateHabitName() {
        let repo = makeHabitRepository()
        let habit = createTestHabit(name: "Old Name")

        habit.name = "New Name"
        repo.update(habit)

        let fetched = repo.fetchAll().first(where: { $0.id == habit.id })
        XCTAssertEqual(fetched?.name, "New Name", "Habit name should be updated after save")
    }

    // MARK: - HabitRepository: Delete

    func testDeleteHabit() {
        let repo = makeHabitRepository()
        let habit = createTestHabit()
        let habitID = habit.id

        repo.delete(habit)

        let all = repo.fetchAll()
        XCTAssertFalse(all.contains(where: { $0.id == habitID }),
                       "Deleted habit should no longer appear in fetchAll results")
    }

    // MARK: - LogRepository: Create

    func testCreateDailyLogEntry() {
        let logRepo = makeLogRepository()
        let habit = createTestHabit()

        let log = logRepo.createLog(habit: habit, date: Date())

        XCTAssertNotNil(log.id)
        XCTAssertEqual(log.habit, habit)
        XCTAssertFalse(log.didPledge)
        XCTAssertFalse(log.didReflect)
        XCTAssertFalse(log.lapsedToday)
        XCTAssertEqual(log.mood, 3)
    }

    // MARK: - LogRepository: Fetch

    func testFetchLogsForHabit() {
        let logRepo = makeLogRepository()
        let habit = createTestHabit()

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        logRepo.createLog(habit: habit, date: yesterday)
        logRepo.createLog(habit: habit, date: Date())

        let logs = logRepo.fetchLogs(for: habit)
        XCTAssertEqual(logs.count, 2, "Should fetch both log entries for the habit")
    }

    // MARK: - LogRepository: Update

    func testUpdateLogPledgeAndReflection() {
        let logRepo = makeLogRepository()
        let habit = createTestHabit()

        let log = logRepo.createLog(habit: habit, date: Date())

        logRepo.updatePledge(log: log, text: "I pledge to stay clean today")
        XCTAssertTrue(log.didPledge)
        XCTAssertEqual(log.pledgeText, "I pledge to stay clean today")

        logRepo.updateReflection(log: log, text: "Felt strong today", mood: 4)
        XCTAssertTrue(log.didReflect)
        XCTAssertEqual(log.reflectionText, "Felt strong today")
        XCTAssertEqual(log.mood, 4)
    }

    // MARK: - CravingRepository: Create

    func testCreateCravingEntry() {
        let cravingRepo = makeCravingRepository()
        let habit = createTestHabit()

        let craving = cravingRepo.create(
            habit: habit,
            intensity: 7,
            trigger: "Stress",
            tool: "Deep breathing",
            didResist: true,
            duration: 120,
            mood: 2
        )

        XCTAssertNotNil(craving.id)
        XCTAssertEqual(craving.habit, habit)
        XCTAssertEqual(craving.intensity, 7)
        XCTAssertEqual(craving.triggerCategory, "Stress")
        XCTAssertEqual(craving.copingToolUsed, "Deep breathing")
        XCTAssertEqual(craving.durationSeconds, 120)
        XCTAssertEqual(craving.mood, 2)
    }

    // MARK: - CravingRepository: Fetch

    func testFetchCravingsForHabit() {
        let cravingRepo = makeCravingRepository()
        let habit = createTestHabit()

        cravingRepo.create(habit: habit, intensity: 5, trigger: "Boredom",
                           tool: nil, didResist: true, duration: 60, mood: 3)
        cravingRepo.create(habit: habit, intensity: 8, trigger: "Social",
                           tool: "Call a friend", didResist: false, duration: 300, mood: 1)

        let cravings = cravingRepo.fetchAll(for: habit)
        XCTAssertEqual(cravings.count, 2, "Should fetch both craving entries for the habit")
    }

    // MARK: - CravingRepository: didResist

    func testCravingDidResistProperty() {
        let cravingRepo = makeCravingRepository()
        let habit = createTestHabit()

        let resisted = cravingRepo.create(
            habit: habit, intensity: 6, trigger: nil,
            tool: "Meditation", didResist: true, duration: 90, mood: 3
        )
        XCTAssertTrue(resisted.didResist, "Craving marked as resisted should have didResist == true")

        let notResisted = cravingRepo.create(
            habit: habit, intensity: 9, trigger: "Party",
            tool: nil, didResist: false, duration: 0, mood: 1
        )
        XCTAssertFalse(notResisted.didResist, "Craving marked as not resisted should have didResist == false")
    }
}
