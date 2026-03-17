import Foundation
import CoreData

@objc(CDMotivationPackPurchase)
public class CDMotivationPackPurchase: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var packIdentifier: String
    @NSManaged public var purchasedAt: Date
    @NSManaged public var transactionID: String

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        packIdentifier: String,
        transactionID: String
    ) -> CDMotivationPackPurchase {
        let purchase = CDMotivationPackPurchase(context: context)
        purchase.id = UUID()
        purchase.packIdentifier = packIdentifier
        purchase.purchasedAt = Date()
        purchase.transactionID = transactionID
        return purchase
    }
}
