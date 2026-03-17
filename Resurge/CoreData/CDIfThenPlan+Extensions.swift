import Foundation
import CoreData

@objc(CDIfThenPlan)
public class CDIfThenPlan: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var habitId: UUID?
    @NSManaged public var triggerType: String
    @NSManaged public var triggerDetails: String?
    @NSManaged public var thenSteps: String?
    @NSManaged public var responseDetail: String?
    @NSManaged public var activeFlag: Bool
    @NSManaged public var successCount: Int32
    @NSManaged public var failureCount: Int32
    @NSManaged public var createdAt: Date

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        triggerType: String,
        triggerDetails: String? = nil,
        thenSteps: String? = nil,
        responseDetail: String? = nil,
        habitId: UUID? = nil
    ) -> CDIfThenPlan {
        let plan = CDIfThenPlan(context: context)
        plan.id = UUID()
        plan.habitId = habitId
        plan.triggerType = triggerType
        plan.triggerDetails = triggerDetails
        plan.thenSteps = thenSteps
        plan.responseDetail = responseDetail
        plan.activeFlag = true
        plan.successCount = 0
        plan.failureCount = 0
        plan.createdAt = Date()
        return plan
    }
}
