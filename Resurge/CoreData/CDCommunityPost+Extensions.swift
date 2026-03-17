import Foundation
import CoreData

@objc(CDCommunityPost)
public class CDCommunityPost: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var remoteID: String?
    @NSManaged public var authorName: String
    @NSManaged public var authorID: String
    @NSManaged public var habitCategory: String
    @NSManaged public var title: String
    @NSManaged public var body: String
    @NSManaged public var imageURL: String?
    @NSManaged public var sharedAchievementKey: String?
    @NSManaged public var likeCount: Int32
    @NSManaged public var commentCount: Int32
    @NSManaged public var isFlagged: Bool
    @NSManaged public var markedAsDeleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // MARK: - Relationships

    @NSManaged public var comments: NSSet?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        authorName: String,
        authorID: String,
        habitCategory: String,
        title: String,
        body: String,
        imageURL: String? = nil,
        sharedAchievementKey: String? = nil
    ) -> CDCommunityPost {
        let post = CDCommunityPost(context: context)
        post.id = UUID()
        post.remoteID = nil
        post.authorName = authorName
        post.authorID = authorID
        post.habitCategory = habitCategory
        post.title = title
        post.body = body
        post.imageURL = imageURL
        post.sharedAchievementKey = sharedAchievementKey
        post.likeCount = 0
        post.commentCount = 0
        post.isFlagged = false
        post.markedAsDeleted = false
        post.createdAt = Date()
        post.updatedAt = Date()
        return post
    }
}

// MARK: - Generated Accessors for comments

extension CDCommunityPost {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: CDCommunityComment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: CDCommunityComment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)
}
