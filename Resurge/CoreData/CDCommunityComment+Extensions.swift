import Foundation
import CoreData

@objc(CDCommunityComment)
public class CDCommunityComment: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var remoteID: String?
    @NSManaged public var authorName: String
    @NSManaged public var authorID: String
    @NSManaged public var body: String
    @NSManaged public var isFlagged: Bool
    @NSManaged public var createdAt: Date

    // MARK: - Relationships

    @NSManaged public var post: CDCommunityPost?

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        post: CDCommunityPost,
        authorName: String,
        authorID: String,
        body: String
    ) -> CDCommunityComment {
        let comment = CDCommunityComment(context: context)
        comment.id = UUID()
        comment.remoteID = nil
        comment.authorName = authorName
        comment.authorID = authorID
        comment.body = body
        comment.isFlagged = false
        comment.createdAt = Date()
        comment.post = post
        return comment
    }
}
