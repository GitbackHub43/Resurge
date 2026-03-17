import Foundation
import CoreData

@objc(CDDailyLogEntry)
public class CDDailyLogEntry: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var entryType: String?
    @NSManaged public var didPledge: Bool
    @NSManaged public var pledgeText: String?
    @NSManaged public var didReflect: Bool
    @NSManaged public var reflectionText: String?
    @NSManaged public var lapsedToday: Bool
    @NSManaged public var lapseNotes: String?
    @NSManaged public var mood: Int16
    @NSManaged public var stress: Int16
    @NSManaged public var energy: Int16
    @NSManaged public var sleepQuality: Int16
    @NSManaged public var loneliness: Int16
    @NSManaged public var cravingToday: Int16
    @NSManaged public var wins: String?
    @NSManaged public var planForTomorrow: String?
    @NSManaged public var tags: String?
    @NSManaged public var gratitudeText: String?
    @NSManaged public var createdAt: Date

    // MARK: - Relationships

    @NSManaged public var habit: CDHabit?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        habit: CDHabit,
        date: Date = Date(),
        didPledge: Bool = false,
        pledgeText: String? = nil,
        didReflect: Bool = false,
        reflectionText: String? = nil,
        lapsedToday: Bool = false,
        lapseNotes: String? = nil,
        mood: Int16 = 3
    ) -> CDDailyLogEntry {
        let entry = CDDailyLogEntry(context: context)
        entry.id = UUID()
        entry.date = date
        entry.didPledge = didPledge
        entry.pledgeText = pledgeText
        entry.didReflect = didReflect
        entry.reflectionText = reflectionText
        entry.lapsedToday = lapsedToday
        entry.lapseNotes = lapseNotes
        entry.mood = mood
        entry.createdAt = Date()
        entry.habit = habit
        return entry
    }
}
