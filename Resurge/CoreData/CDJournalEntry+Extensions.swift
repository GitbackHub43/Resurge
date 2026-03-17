import Foundation
import CoreData

@objc(CDJournalEntry)
public class CDJournalEntry: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var title: String?
    @NSManaged public var body: String
    @NSManaged public var mood: Int16
    @NSManaged public var isReflection: Bool
    @NSManaged public var promptUsed: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // MARK: - Relationships

    @NSManaged public var habit: CDHabit?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        habit: CDHabit,
        body: String,
        title: String? = nil,
        mood: Int16 = 3,
        isReflection: Bool = false,
        promptUsed: String? = nil
    ) -> CDJournalEntry {
        let entry = CDJournalEntry(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.title = title
        entry.body = body
        entry.mood = mood
        entry.isReflection = isReflection
        entry.promptUsed = promptUsed
        entry.createdAt = Date()
        entry.updatedAt = Date()
        entry.habit = habit
        return entry
    }
}
