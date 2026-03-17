import Foundation
import CoreData

// MARK: - Protocol

protocol JournalRepositoryProtocol {
    func fetchAll() -> [CDJournalEntry]
    func fetchForHabit(_ habit: CDHabit) -> [CDJournalEntry]
    func create(
        habit: CDHabit,
        title: String?,
        body: String,
        mood: Int,
        isReflection: Bool,
        prompt: String?
    ) -> CDJournalEntry
    func update(_ entry: CDJournalEntry)
    func delete(_ entry: CDJournalEntry)
}

// MARK: - Core Data Implementation

final class CoreDataJournalRepository: JournalRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch All

    func fetchAll() -> [CDJournalEntry] {
        let request = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("[JournalRepository] fetchAll error: \(error)")
            return []
        }
    }

    // MARK: - Fetch For Habit

    func fetchForHabit(_ habit: CDHabit) -> [CDJournalEntry] {
        let request = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("[JournalRepository] fetchForHabit error: \(error)")
            return []
        }
    }

    // MARK: - Create

    @discardableResult
    func create(
        habit: CDHabit,
        title: String?,
        body: String,
        mood: Int,
        isReflection: Bool,
        prompt: String?
    ) -> CDJournalEntry {
        let entry = CDJournalEntry(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.title = title
        entry.body = body
        entry.mood = Int16(mood)
        entry.isReflection = isReflection
        entry.promptUsed = prompt
        let now = Date()
        entry.createdAt = now
        entry.updatedAt = now
        entry.habit = habit
        save()
        return entry
    }

    // MARK: - Update

    func update(_ entry: CDJournalEntry) {
        entry.updatedAt = Date()
        save()
    }

    // MARK: - Delete

    func delete(_ entry: CDJournalEntry) {
        context.delete(entry)
        save()
    }

    // MARK: - Private

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("[JournalRepository] save error: \(error)")
        }
    }
}
