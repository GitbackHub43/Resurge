import Foundation
import CoreData

@objc(CDAchievementUnlock)
public class CDAchievementUnlock: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var achievementKey: String
    @NSManaged public var unlockedAt: Date
    @NSManaged public var seen: Bool

    // MARK: - Relationships

    @NSManaged public var habit: CDHabit?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        habit: CDHabit,
        achievementKey: String,
        seen: Bool = false
    ) -> CDAchievementUnlock {
        let unlock = CDAchievementUnlock(context: context)
        unlock.id = UUID()
        unlock.achievementKey = achievementKey
        unlock.unlockedAt = Date()
        unlock.seen = seen
        unlock.habit = habit
        return unlock
    }
}
