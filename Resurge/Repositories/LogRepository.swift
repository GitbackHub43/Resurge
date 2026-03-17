import Foundation
import CoreData

// MARK: - Protocol

protocol LogRepositoryProtocol {
    func fetchLogs(for habit: CDHabit) -> [CDDailyLogEntry]
    func fetchLog(for habit: CDHabit, date: Date) -> CDDailyLogEntry?
    func createLog(habit: CDHabit, date: Date) -> CDDailyLogEntry
    func updatePledge(log: CDDailyLogEntry, text: String)
    func updateReflection(log: CDDailyLogEntry, text: String, mood: Int)
    func logLapse(log: CDDailyLogEntry, notes: String?)
}

// MARK: - Core Data Implementation

final class CoreDataLogRepository: LogRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch All Logs

    func fetchLogs(for habit: CDHabit) -> [CDDailyLogEntry] {
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("[LogRepository] fetchLogs error: \(error)")
            return []
        }
    }

    // MARK: - Fetch Single Log by Date

    func fetchLog(for habit: CDHabit, date: Date) -> CDDailyLogEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        ])
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print("[LogRepository] fetchLog error: \(error)")
            return nil
        }
    }

    // MARK: - Create

    @discardableResult
    func createLog(habit: CDHabit, date: Date) -> CDDailyLogEntry {
        // Return existing log if one already exists for this date
        if let existing = fetchLog(for: habit, date: date) {
            return existing
        }

        let log = CDDailyLogEntry(context: context)
        log.id = UUID()
        log.date = Calendar.current.startOfDay(for: date)
        log.didPledge = false
        log.didReflect = false
        log.lapsedToday = false
        log.mood = 3
        log.createdAt = Date()
        log.habit = habit
        save()
        return log
    }

    // MARK: - Update Pledge

    func updatePledge(log: CDDailyLogEntry, text: String) {
        log.didPledge = true
        log.pledgeText = text
        save()
    }

    // MARK: - Update Reflection

    func updateReflection(log: CDDailyLogEntry, text: String, mood: Int) {
        log.didReflect = true
        log.reflectionText = text
        log.mood = Int16(mood)
        save()
    }

    // MARK: - Log Lapse

    func logLapse(log: CDDailyLogEntry, notes: String?) {
        log.lapsedToday = true
        log.lapseNotes = notes
        // Reset the habit's recovery timer on lapse
        log.habit?.resetOnLapse()
        save()
    }

    // MARK: - Private

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("[LogRepository] save error: \(error)")
        }
    }
}
