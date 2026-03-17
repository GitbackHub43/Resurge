import Foundation
import CoreData

@objc(CDPrivateGroup)
public class CDPrivateGroup: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var remoteID: String?
    @NSManaged public var name: String
    @NSManaged public var habitCategory: String
    @NSManaged public var creatorID: String
    @NSManaged public var inviteCode: String?
    @NSManaged public var createdAt: Date

    // MARK: - Relationships

    @NSManaged public var memberships: NSSet?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        name: String,
        habitCategory: String,
        creatorID: String,
        inviteCode: String? = nil
    ) -> CDPrivateGroup {
        let group = CDPrivateGroup(context: context)
        group.id = UUID()
        group.remoteID = nil
        group.name = name
        group.habitCategory = habitCategory
        group.creatorID = creatorID
        group.inviteCode = inviteCode
        group.createdAt = Date()
        return group
    }
}

// MARK: - Generated Accessors for memberships

extension CDPrivateGroup {

    @objc(addMembershipsObject:)
    @NSManaged public func addToMemberships(_ value: CDGroupMembership)

    @objc(removeMembershipsObject:)
    @NSManaged public func removeFromMemberships(_ value: CDGroupMembership)

    @objc(addMemberships:)
    @NSManaged public func addToMemberships(_ values: NSSet)

    @objc(removeMemberships:)
    @NSManaged public func removeFromMemberships(_ values: NSSet)
}
