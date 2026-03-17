import Foundation
import CoreData

@objc(CDLibraryItemProgress)
public class CDLibraryItemProgress: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var libraryItemId: String
    @NSManaged public var bookmarked: Bool
    @NSManaged public var completedAt: Date?

    // MARK: - Fetch-or-Create

    static func fetchOrCreate(in context: NSManagedObjectContext, libraryItemId: String) -> CDLibraryItemProgress {
        let request: NSFetchRequest<CDLibraryItemProgress> = NSFetchRequest(entityName: "CDLibraryItemProgress")
        request.predicate = NSPredicate(format: "libraryItemId == %@", libraryItemId)
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let progress = CDLibraryItemProgress(context: context)
        progress.id = UUID()
        progress.libraryItemId = libraryItemId
        progress.bookmarked = false
        progress.completedAt = nil

        return progress
    }
}
