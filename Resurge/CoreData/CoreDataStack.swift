import Foundation
import CoreData

final class CoreDataStack {

    // MARK: - Singleton

    static let shared = CoreDataStack()

    // MARK: - Preview / In-Memory Store

    static var preview: CoreDataStack = {
        let stack = CoreDataStack(inMemory: true)
        return stack
    }()

    // MARK: - Persistent Container

    let persistentContainer: NSPersistentContainer

    // MARK: - Contexts

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    // MARK: - Init

    private init(inMemory: Bool = false) {
        guard let modelURL = Bundle.main.url(forResource: "Resurge", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            // Fallback: try loading the model by name through the default mechanism.
            // This covers unit-test bundles and SwiftUI previews where the momd may
            // be resolved automatically by NSPersistentContainer.
            persistentContainer = NSPersistentContainer(name: "Resurge")
            configureContainer(inMemory: inMemory)
            return
        }

        persistentContainer = NSPersistentContainer(name: "Resurge",
                                                    managedObjectModel: managedObjectModel)
        configureContainer(inMemory: inMemory)
    }

    private func configureContainer(inMemory: Bool) {
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // In production you may want to migrate or present an alert.
                // For now we log and continue so the app does not silently swallow
                // the error during development.
                print("Core Data failed to load persistent store: \(error), \(error.userInfo)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Helpers

    func save(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            let nsError = error as NSError
            print("Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }

    func saveInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            block(context)
            guard context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data background save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
