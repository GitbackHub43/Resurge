import Foundation
import CoreData

@objc(CDAchievementProgress)
public class CDAchievementProgress: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var achievementId: String
    @NSManaged public var habitId: UUID?
    @NSManaged public var tier: Int16
    @NSManaged public var currentValue: Int64
    @NSManaged public var targetValue: Int64
    @NSManaged public var unlockedAt: Date?

    // MARK: - Fetch-or-Create

    static func fetchOrCreate(in context: NSManagedObjectContext, achievementId: String) -> CDAchievementProgress {
        let request: NSFetchRequest<CDAchievementProgress> = NSFetchRequest(entityName: "CDAchievementProgress")
        request.predicate = NSPredicate(format: "achievementId == %@", achievementId)
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let progress = CDAchievementProgress(context: context)
        progress.id = UUID()
        progress.achievementId = achievementId
        progress.habitId = nil
        progress.tier = 0
        progress.currentValue = 0
        progress.targetValue = 0
        progress.unlockedAt = nil

        return progress
    }
}
