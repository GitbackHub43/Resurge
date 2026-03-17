import Foundation
import CoreData

@objc(CDRewardTransaction)
public class CDRewardTransaction: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var actionType: String
    @NSManaged public var amount: Int32
    @NSManaged public var reason: String
    @NSManaged public var timestamp: Date
    @NSManaged public var habitID: UUID?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        actionType: String,
        amount: Int32,
        reason: String,
        habitID: UUID? = nil
    ) -> CDRewardTransaction {
        let transaction = CDRewardTransaction(context: context)
        transaction.id = UUID()
        transaction.actionType = actionType
        transaction.amount = amount
        transaction.reason = reason
        transaction.timestamp = Date()
        transaction.habitID = habitID
        return transaction
    }
}
