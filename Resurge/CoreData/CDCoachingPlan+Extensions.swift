import Foundation
import CoreData

@objc(CDCoachingPlan)
public class CDCoachingPlan: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var habitID: UUID
    @NSManaged public var planType: String
    @NSManaged public var currentDay: Int32
    @NSManaged public var tasksJSON: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var startDate: Date
    @NSManaged public var createdAt: Date

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        habitID: UUID,
        planType: String,
        tasksJSON: String? = nil
    ) -> CDCoachingPlan {
        let plan = CDCoachingPlan(context: context)
        plan.id = UUID()
        plan.habitID = habitID
        plan.planType = planType
        plan.currentDay = 1
        plan.tasksJSON = tasksJSON
        plan.isActive = true
        plan.startDate = Date()
        plan.createdAt = Date()
        return plan
    }
}
