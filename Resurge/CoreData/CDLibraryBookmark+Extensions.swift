import Foundation
import CoreData

@objc(CDLibraryBookmark)
public class CDLibraryBookmark: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var articleKey: String
    @NSManaged public var createdAt: Date

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        articleKey: String
    ) -> CDLibraryBookmark {
        let bookmark = CDLibraryBookmark(context: context)
        bookmark.id = UUID()
        bookmark.articleKey = articleKey
        bookmark.createdAt = Date()
        return bookmark
    }
}
