import Foundation
import CoreData

@objc(CDCravingEntry)
public class CDCravingEntry: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var intensity: Int16
    @NSManaged public var triggerCategory: String?
    @NSManaged public var triggerNote: String?
    @NSManaged public var copingToolUsed: String?
    @NSManaged public var didResist: Bool
    @NSManaged public var durationSeconds: Int32
    @NSManaged public var mood: Int16
    @NSManaged public var eventType: String
    @NSManaged public var quantity: Double
    @NSManaged public var outcome: String
    @NSManaged public var locationTag: String?
    @NSManaged public var socialTag: String?
    @NSManaged public var stateTags: String?

    // MARK: - Relationships

    @NSManaged public var habit: CDHabit?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        habit: CDHabit,
        intensity: Int16 = 5,
        triggerCategory: String? = nil,
        triggerNote: String? = nil,
        copingToolUsed: String? = nil,
        didResist: Bool = true,
        durationSeconds: Int32 = 0,
        mood: Int16 = 3
    ) -> CDCravingEntry {
        let entry = CDCravingEntry(context: context)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.intensity = intensity
        entry.triggerCategory = triggerCategory
        entry.triggerNote = triggerNote
        entry.copingToolUsed = copingToolUsed
        entry.didResist = didResist
        entry.durationSeconds = durationSeconds
        entry.mood = mood
        entry.habit = habit
        return entry
    }
}
