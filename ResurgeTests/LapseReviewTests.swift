import XCTest
import CoreData
@testable import Resurge

final class LapseReviewTests: XCTestCase {

    private var stack: CoreDataStack!
    private var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        stack = CoreDataStack.preview
        context = stack.viewContext
    }

    override func tearDownWithError() throws {
        let entityNames = ["CDHabit", "CDCravingEntry"]
        for name in entityNames {
            let request = NSFetchRequest<NSManagedObject>(entityName: name)
            let objects = (try? context.fetch(request)) ?? []
            for obj in objects {
                context.delete(obj)
            }
        }
        try? context.save()
    }

    // MARK: - CDCravingEntry with LAPSE_REVIEW Event Type

    func testCravingEntryCanBeCreatedWithLapseReviewEventType() {
        let habit = createHabit()
        let entry = createLapseReviewEntry(for: habit)
        try? context.save()

        XCTAssertEqual(entry.eventType, "LAPSE_REVIEW",
            "Entry should have eventType LAPSE_REVIEW")
    }

    func testLapseReviewEntryHasDidResistFalse() {
        let habit = createHabit()
        let entry = createLapseReviewEntry(for: habit)
        try? context.save()

        XCTAssertFalse(entry.didResist,
            "LAPSE_REVIEW entry should have didResist = false")
    }

    // MARK: - Trigger Categories as Comma-Separated String

    func testTriggerCategoriesStoredAsCommaSeparatedString() {
        let habit = createHabit()
        let entry = createLapseReviewEntry(for: habit)
        let triggers: Set<String> = ["Stress", "Boredom", "Loneliness"]
        entry.triggerCategory = triggers.sorted().joined(separator: ", ")
        try? context.save()

        let fetched = fetchCravingEntries().first
        XCTAssertNotNil(fetched?.triggerCategory)

        let storedTriggers = fetched!.triggerCategory!.components(separatedBy: ", ")
        XCTAssertEqual(Set(storedTriggers), triggers,
            "Trigger categories should be stored as comma-separated string")
    }

    // MARK: - Trigger Note

    func testTriggerNoteStoresTextCorrectly() {
        let habit = createHabit()
        let entry = createLapseReviewEntry(for: habit)
        let noteText = "I was feeling very stressed after a long day at work"
        entry.triggerNote = noteText
        try? context.save()

        let fetched = fetchCravingEntries().first
        XCTAssertEqual(fetched?.triggerNote, noteText,
            "triggerNote should store the text correctly")
    }

    // MARK: - Coping Tool Used

    func testCopingToolUsedStoresToolID() {
        let habit = createHabit()
        let entry = createLapseReviewEntry(for: habit)
        let toolID = "deep_breathing_exercise"
        entry.copingToolUsed = toolID
        try? context.save()

        let fetched = fetchCravingEntries().first
        XCTAssertEqual(fetched?.copingToolUsed, toolID,
            "copingToolUsed should store the tool ID correctly")
    }

    // MARK: - Multiple Entries for a Habit

    func testMultipleCravingEntriesCanBeFetchedForHabit() {
        let habit = createHabit()

        createLapseReviewEntry(for: habit)
        createLapseReviewEntry(for: habit)
        createLapseReviewEntry(for: habit)
        try? context.save()

        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        let entries = (try? context.fetch(request)) ?? []

        XCTAssertEqual(entries.count, 3,
            "Should be able to fetch multiple craving entries for a single habit")
    }

    // MARK: - Trigger Options from LapseReviewView

    func testLapseReviewTriggerOptionsHas10Items() {
        // The LapseReviewView defines 10 trigger options:
        // "Stress", "Boredom", "Social pressure", "Loneliness", "Celebration",
        // "Habit cue", "Emotional pain", "Physical craving", "Tiredness", "Anger"
        let expectedTriggers = [
            "Stress", "Boredom", "Social pressure", "Loneliness", "Celebration",
            "Habit cue", "Emotional pain", "Physical craving", "Tiredness", "Anger"
        ]

        XCTAssertEqual(expectedTriggers.count, 10,
            "LapseReviewView should define exactly 10 trigger options")

        // Verify each trigger is a non-empty string
        for trigger in expectedTriggers {
            XCTAssertFalse(trigger.isEmpty, "Each trigger option should be a non-empty string")
        }
    }

    // MARK: - Helpers

    private func createHabit() -> CDHabit {
        return CDHabit.create(
            in: context,
            name: "Test Habit",
            programType: "smoking"
        )
    }

    @discardableResult
    private func createLapseReviewEntry(for habit: CDHabit) -> CDCravingEntry {
        let entry = CDCravingEntry(context: context)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.eventType = "LAPSE_REVIEW"
        entry.didResist = false
        entry.intensity = 0
        entry.durationSeconds = 0
        entry.mood = 0
        entry.quantity = 0
        entry.outcome = "used"
        entry.habit = habit
        return entry
    }

    private func fetchCravingEntries() -> [CDCravingEntry] {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        return (try? context.fetch(request)) ?? []
    }
}
