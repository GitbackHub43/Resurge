import Foundation
import CoreData

@objc(CDGroupMembership)
public class CDGroupMembership: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var userID: String
    @NSManaged public var role: String
    @NSManaged public var joinedAt: Date

    // MARK: - Relationships

    @NSManaged public var group: CDPrivateGroup?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        group: CDPrivateGroup,
        userID: String,
        role: String = "member"
    ) -> CDGroupMembership {
        let membership = CDGroupMembership(context: context)
        membership.id = UUID()
        membership.userID = userID
        membership.role = role
        membership.joinedAt = Date()
        membership.group = group
        return membership
    }
}
