import Foundation
import CoreData

@objc(CDCosmeticUnlock)
public class CDCosmeticUnlock: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var cosmeticId: String
    @NSManaged public var unlockedAt: Date

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        cosmeticId: String
    ) -> CDCosmeticUnlock {
        let unlock = CDCosmeticUnlock(context: context)
        unlock.id = UUID()
        unlock.cosmeticId = cosmeticId
        unlock.unlockedAt = Date()
        return unlock
    }
}
