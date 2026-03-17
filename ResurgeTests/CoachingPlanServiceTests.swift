import XCTest
@testable import Resurge

final class CoachingPlanServiceTests: XCTestCase {
    var service: CoachingPlanService!

    override func setUp() {
        super.setUp()
        service = CoachingPlanService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - generatePlan

    func testGeneratePlanReturnsTasksForSmoking() {
        let tasks = service.generatePlan(for: .smoking)
        XCTAssertGreaterThan(tasks.count, 0, "Plan should contain tasks")
    }

    func testGeneratePlanContainsPreparationTasks() {
        let tasks = service.generatePlan(for: .alcohol)
        let day1Tasks = tasks.filter { $0.dayNumber == 1 }
        XCTAssertGreaterThanOrEqual(day1Tasks.count, 2, "Day 1 should have at least 2 preparation tasks")
    }

    func testGeneratePlanContainsProgramSpecificTasks() {
        let tasks = service.generatePlan(for: .smoking)
        let specificTasks = tasks.filter { $0.dayNumber >= 10 }
        XCTAssertGreaterThan(specificTasks.count, 0, "Plan should include program-specific tasks beyond day 9")
    }

    func testAllProgramTypesProduceTasks() {
        let allPrograms: [ProgramType] = [
            .smoking, .alcohol, .porn, .phone, .socialMedia, .gaming,
            .procrastination, .sugar, .emotionalEating, .shopping, .gambling, .sleep
        ]

        for program in allPrograms {
            let tasks = service.generatePlan(for: program)
            XCTAssertGreaterThan(tasks.count, 18,
                "\(program.rawValue) should have preparation tasks (18) plus program-specific tasks")
        }
    }

    func testProgramSpecificTasksAreDifferent() {
        let smokingTasks = service.generatePlan(for: .smoking)
        let alcoholTasks = service.generatePlan(for: .alcohol)

        let smokingSpecific = smokingTasks.filter { $0.dayNumber >= 10 }.map(\.title)
        let alcoholSpecific = alcoholTasks.filter { $0.dayNumber >= 10 }.map(\.title)

        XCTAssertNotEqual(smokingSpecific, alcoholSpecific,
            "Different programs should have different specific tasks")
    }

    func testAllTasksStartNotCompleted() {
        let tasks = service.generatePlan(for: .phone)
        let completed = tasks.filter { $0.isCompleted }
        XCTAssertEqual(completed.count, 0, "All generated tasks should start as not completed")
    }

    // MARK: - todaysTasks

    func testTodaysTasksReturnsCorrectDay() {
        let context = CoreDataStack.preview.viewContext
        let plan = CDCoachingPlan(context: context)
        plan.id = UUID()
        plan.currentDay = 1
        plan.createdAt = Date()

        let allTasks = service.generatePlan(for: .smoking)
        let data = try? JSONEncoder().encode(allTasks)
        plan.tasksJSON = data.flatMap { String(data: $0, encoding: .utf8) }

        let todayTasks = service.todaysTasks(for: plan)
        XCTAssertTrue(todayTasks.allSatisfy { $0.dayNumber == 1 },
            "All returned tasks should be for the current day")
    }

    func testTodaysTasksReturnsEmptyForInvalidDay() {
        let context = CoreDataStack.preview.viewContext
        let plan = CDCoachingPlan(context: context)
        plan.id = UUID()
        plan.currentDay = 999
        plan.createdAt = Date()

        let allTasks = service.generatePlan(for: .smoking)
        let data = try? JSONEncoder().encode(allTasks)
        plan.tasksJSON = data.flatMap { String(data: $0, encoding: .utf8) }

        let todayTasks = service.todaysTasks(for: plan)
        XCTAssertEqual(todayTasks.count, 0, "Invalid day should return no tasks")
    }

    // MARK: - Task Completion

    func testMarkCompletedUpdatesTask() {
        let context = CoreDataStack.preview.viewContext
        let plan = CDCoachingPlan(context: context)
        plan.id = UUID()
        plan.currentDay = 1
        plan.createdAt = Date()

        let allTasks = service.generatePlan(for: .smoking)
        let data = try? JSONEncoder().encode(allTasks)
        plan.tasksJSON = data.flatMap { String(data: $0, encoding: .utf8) }

        let taskToComplete = service.todaysTasks(for: plan).first!
        service.markCompleted(task: taskToComplete, plan: plan)

        let updatedTasks = service.todaysTasks(for: plan)
        let completedTask = updatedTasks.first { $0.id == taskToComplete.id }
        XCTAssertTrue(completedTask?.isCompleted ?? false, "Task should be marked as completed")
    }

    // MARK: - Day Advancement

    func testDayAdvancesWhenAllTasksCompleted() {
        let context = CoreDataStack.preview.viewContext
        let plan = CDCoachingPlan(context: context)
        plan.id = UUID()
        plan.currentDay = 1
        plan.createdAt = Date()

        let allTasks = service.generatePlan(for: .smoking)
        let data = try? JSONEncoder().encode(allTasks)
        plan.tasksJSON = data.flatMap { String(data: $0, encoding: .utf8) }

        let day1Tasks = service.todaysTasks(for: plan)
        for task in day1Tasks {
            service.markCompleted(task: task, plan: plan)
        }

        XCTAssertEqual(plan.currentDay, 2, "Day should advance to 2 after completing all day 1 tasks")
    }

    func testDayDoesNotAdvanceWithIncompleteTasks() {
        let context = CoreDataStack.preview.viewContext
        let plan = CDCoachingPlan(context: context)
        plan.id = UUID()
        plan.currentDay = 1
        plan.createdAt = Date()

        let allTasks = service.generatePlan(for: .smoking)
        let data = try? JSONEncoder().encode(allTasks)
        plan.tasksJSON = data.flatMap { String(data: $0, encoding: .utf8) }

        let day1Tasks = service.todaysTasks(for: plan)
        if let firstTask = day1Tasks.first {
            service.markCompleted(task: firstTask, plan: plan)
        }

        // Day 1 has 2 tasks, so completing only 1 should not advance
        if day1Tasks.count > 1 {
            XCTAssertEqual(plan.currentDay, 1, "Day should not advance with incomplete tasks")
        }
    }

    // MARK: - Task Properties

    func testTasksHaveValidCategories() {
        let tasks = service.generatePlan(for: .gaming)
        for task in tasks {
            XCTAssertFalse(task.category.isEmpty, "Task '\(task.title)' should have a category")
        }
    }

    func testTasksHaveNonEmptyTitles() {
        let tasks = service.generatePlan(for: .sugar)
        for task in tasks {
            XCTAssertFalse(task.title.isEmpty, "All tasks should have non-empty titles")
            XCTAssertFalse(task.description.isEmpty, "All tasks should have non-empty descriptions")
        }
    }
}
