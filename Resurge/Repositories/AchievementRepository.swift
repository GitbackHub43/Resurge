import Foundation
import CoreData

// MARK: - Protocol

protocol AchievementRepositoryProtocol {
    func fetchAll(for habit: CDHabit) -> [CDAchievementUnlock]
    func unlock(habit: CDHabit, key: String) -> CDAchievementUnlock
    func hasUnlocked(habit: CDHabit, key: String) -> Bool
    func fetchUnseen() -> [CDAchievementUnlock]
    func markSeen(_ unlock: CDAchievementUnlock)
}

// MARK: - Core Data Implementation

final class CoreDataAchievementRepository: AchievementRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch All

    func fetchAll(for habit: CDHabit) -> [CDAchievementUnlock] {
        let request = NSFetchRequest<CDAchievementUnlock>(entityName: "CDAchievementUnlock")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "unlockedAt", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("[AchievementRepository] fetchAll error: \(error)")
            return []
        }
    }

    // MARK: - Unlock

    @discardableResult
    func unlock(habit: CDHabit, key: String) -> CDAchievementUnlock {
        // Prevent duplicates
        if let existing = findUnlock(habit: habit, key: key) {
            return existing
        }

        let unlock = CDAchievementUnlock(context: context)
        unlock.id = UUID()
        unlock.achievementKey = key
        unlock.unlockedAt = Date()
        unlock.seen = false
        unlock.habit = habit
        save()
        return unlock
    }

    // MARK: - Has Unlocked

    func hasUnlocked(habit: CDHabit, key: String) -> Bool {
        return findUnlock(habit: habit, key: key) != nil
    }

    // MARK: - Fetch Unseen

    func fetchUnseen() -> [CDAchievementUnlock] {
        let request = NSFetchRequest<CDAchievementUnlock>(entityName: "CDAchievementUnlock")
        request.predicate = NSPredicate(format: "seen == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "unlockedAt", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("[AchievementRepository] fetchUnseen error: \(error)")
            return []
        }
    }

    // MARK: - Mark Seen

    func markSeen(_ unlock: CDAchievementUnlock) {
        unlock.seen = true
        save()
    }

    // MARK: - Private Helpers

    private func findUnlock(habit: CDHabit, key: String) -> CDAchievementUnlock? {
        let request = NSFetchRequest<CDAchievementUnlock>(entityName: "CDAchievementUnlock")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "achievementKey == %@", key)
        ])
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("[AchievementRepository] findUnlock error: \(error)")
            return nil
        }
    }

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("[AchievementRepository] save error: \(error)")
        }
    }
}
