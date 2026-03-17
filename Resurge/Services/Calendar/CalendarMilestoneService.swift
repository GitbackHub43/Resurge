import Foundation
import EventKit

// MARK: - CalendarMilestoneServiceProtocol

protocol CalendarMilestoneServiceProtocol {
    func requestAccess() async -> Bool
    func addMilestone(title: String, date: Date) async throws
}

// MARK: - CalendarMilestoneService

final class CalendarMilestoneService: CalendarMilestoneServiceProtocol {

    private let eventStore = EKEventStore()

    // MARK: - Request Access

    func requestAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, error in
                    if let error = error {
                        print("Calendar access error: \(error.localizedDescription)")
                    }
                    continuation.resume(returning: granted)
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        print("Calendar access error: \(error.localizedDescription)")
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    // MARK: - Add Milestone

    func addMilestone(title: String, date: Date) async throws {
        let granted = await requestAccess()
        guard granted else {
            throw CalendarError.accessDenied
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = date
        event.isAllDay = true
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.notes = "Milestone reached in Resurge!"

        // Add an alert 1 hour before
        let alarm = EKAlarm(relativeOffset: -3600)
        event.addAlarm(alarm)

        try eventStore.save(event, span: .thisEvent)
    }
}

// MARK: - CalendarError

enum CalendarError: LocalizedError {
    case accessDenied

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access was denied. Please enable calendar access in Settings."
        }
    }
}
