import Foundation
import CoreData

// MARK: - Protocol

protocol CravingRepositoryProtocol {
    func fetchAll(for habit: CDHabit) -> [CDCravingEntry]
    func create(
        habit: CDHabit,
        intensity: Int,
        trigger: String?,
        tool: String?,
        didResist: Bool,
        duration: Int,
        mood: Int
    ) -> CDCravingEntry
    func fetchRecent(limit: Int) -> [CDCravingEntry]
}

// MARK: - Core Data Implementation

final class CoreDataCravingRepository: CravingRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch All

    func fetchAll(for habit: CDHabit) -> [CDCravingEntry] {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("[CravingRepository] fetchAll error: \(error)")
            return []
        }
    }

    // MARK: - Create

    @discardableResult
    func create(
        habit: CDHabit,
        intensity: Int,
        trigger: String?,
        tool: String?,
        didResist: Bool,
        duration: Int,
        mood: Int
    ) -> CDCravingEntry {
        let entry = CDCravingEntry(context: context)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.intensity = Int16(intensity)
        entry.triggerCategory = trigger
        entry.copingToolUsed = tool
        entry.didResist = didResist
        entry.durationSeconds = Int32(duration)
        entry.mood = Int16(mood)
        entry.habit = habit
        save()
        return entry
    }

    // MARK: - Fetch Recent

    func fetchRecent(limit: Int) -> [CDCravingEntry] {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = limit
        do {
            return try context.fetch(request)
        } catch {
            print("[CravingRepository] fetchRecent error: \(error)")
            return []
        }
    }

    // MARK: - Private

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("[CravingRepository] save error: \(error)")
        }
    }
}
