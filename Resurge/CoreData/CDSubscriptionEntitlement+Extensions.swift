import Foundation
import CoreData

@objc(CDSubscriptionEntitlement)
public class CDSubscriptionEntitlement: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var activeTier: Int16
    @NSManaged public var entitledProductIDs: String?
    @NSManaged public var lastVerifiedAt: Date
    @NSManaged public var expiresAt: Date?
    @NSManaged public var gracePeriodExpiresAt: Date?
    @NSManaged public var lastErrorCode: String?

    // MARK: - Fetch-or-Create Singleton

    static func fetchOrCreate(in context: NSManagedObjectContext) -> CDSubscriptionEntitlement {
        let request: NSFetchRequest<CDSubscriptionEntitlement> = NSFetchRequest(entityName: "CDSubscriptionEntitlement")
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let entitlement = CDSubscriptionEntitlement(context: context)
        entitlement.id = UUID()
        entitlement.activeTier = 0
        entitlement.entitledProductIDs = nil
        entitlement.lastVerifiedAt = Date()
        entitlement.expiresAt = nil
        entitlement.gracePeriodExpiresAt = nil
        entitlement.lastErrorCode = nil

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Failed to save new CDSubscriptionEntitlement: \(nsError), \(nsError.userInfo)")
        }

        return entitlement
    }
}
