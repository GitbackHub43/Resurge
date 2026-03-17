import Foundation
import CoreData

// MARK: - Protocol

protocol HabitRepositoryProtocol {
    func fetchAll() -> [CDHabit]
    func fetchActive() -> [CDHabit]
    func create(
        name: String,
        programType: ProgramType,
        startDate: Date,
        goalDays: Int,
        costPerUnit: Double,
        timePerUnit: Double,
        dailyUnits: Double,
        reasonToQuit: String?
    ) -> CDHabit
    func update(_ habit: CDHabit)
    func delete(_ habit: CDHabit)
    func canAddMore(isPremium: Bool) -> Bool
}

// MARK: - Core Data Implementation

final class CoreDataHabitRepository: HabitRepositoryProtocol {

    private let context: NSManagedObjectContext
    private static let freeHabitLimit = 3

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch

    func fetchAll() -> [CDHabit] {
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        do {
            return try context.fetch(request)
        } catch {
            print("[HabitRepository] fetchAll error: \(error)")
            return []
        }
    }

    func fetchActive() -> [CDHabit] {
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        do {
            return try context.fetch(request)
        } catch {
            print("[HabitRepository] fetchActive error: \(error)")
            return []
        }
    }

    // MARK: - Create

    @discardableResult
    func create(
        name: String,
        programType: ProgramType,
        startDate: Date,
        goalDays: Int,
        costPerUnit: Double,
        timePerUnit: Double,
        dailyUnits: Double,
        reasonToQuit: String?
    ) -> CDHabit {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = name
        habit.programType = programType.rawValue
        habit.startDate = startDate
        habit.goalDays = Int32(goalDays)
        habit.costPerUnit = costPerUnit
        habit.timePerUnit = timePerUnit
        habit.dailyUnits = dailyUnits
        habit.baselineCostPerDay = costPerUnit * dailyUnits
        habit.baselineTimePerDay = timePerUnit * dailyUnits
        habit.reasonToQuit = reasonToQuit
        habit.isActive = true
        habit.sortOrder = Int16(fetchAll().count)
        habit.colorHex = programType.colorHex
        habit.iconName = programType.iconName
        let now = Date()
        habit.createdAt = now
        habit.updatedAt = now
        save()
        return habit
    }

    // MARK: - Update

    func update(_ habit: CDHabit) {
        habit.updatedAt = Date()
        save()
    }

    // MARK: - Delete

    func delete(_ habit: CDHabit) {
        context.delete(habit)
        save()
    }

    // MARK: - Limit Check

    func canAddMore(isPremium: Bool) -> Bool {
        if isPremium { return true }
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.predicate = NSPredicate(format: "isActive == YES")
        do {
            let count = try context.count(for: request)
            return count < Self.freeHabitLimit
        } catch {
            print("[HabitRepository] canAddMore count error: \(error)")
            return false
        }
    }

    // MARK: - Private

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("[HabitRepository] save error: \(error)")
        }
    }
}
