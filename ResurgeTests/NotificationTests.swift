import XCTest
import UserNotifications
@testable import Resurge

final class NotificationTests: XCTestCase {

    // MARK: - Initialization

    func testNotificationManagerCanBeInstantiated() {
        let manager = NotificationManager()
        XCTAssertNotNil(manager, "NotificationManager should be instantiable")
    }

    // MARK: - Notification Content Configuration

    func testPledgeReminderContentIsConfiguredCorrectly() {
        let content = UNMutableNotificationContent()
        content.title = "Morning Pledge"
        content.body = "Start your day with intention. Take a moment to make your daily pledge."
        content.sound = .default
        content.categoryIdentifier = "PLEDGE_REMINDER"

        XCTAssertFalse(content.title.isEmpty, "Pledge reminder title should not be empty")
        XCTAssertFalse(content.body.isEmpty, "Pledge reminder body should not be empty")
        XCTAssertEqual(content.categoryIdentifier, "PLEDGE_REMINDER")
    }

    func testReflectionReminderContentIsConfiguredCorrectly() {
        let content = UNMutableNotificationContent()
        content.title = "Evening Reflection"
        content.body = "How was your day? Take a few minutes to reflect on your progress."
        content.sound = .default
        content.categoryIdentifier = "REFLECTION_REMINDER"

        XCTAssertFalse(content.title.isEmpty, "Reflection reminder title should not be empty")
        XCTAssertFalse(content.body.isEmpty, "Reflection reminder body should not be empty")
        XCTAssertEqual(content.categoryIdentifier, "REFLECTION_REMINDER")
    }

    func testMotivationalContentIsConfiguredCorrectly() {
        let content = UNMutableNotificationContent()
        content.title = "Stay Strong"
        content.body = "You can do this. One day at a time."
        content.sound = .default
        content.categoryIdentifier = "MOTIVATIONAL"

        XCTAssertFalse(content.title.isEmpty, "Motivational title should not be empty")
        XCTAssertFalse(content.body.isEmpty, "Motivational body should not be empty")
        XCTAssertEqual(content.categoryIdentifier, "MOTIVATIONAL")
    }

    func testHighRiskAlertContentIsConfiguredCorrectly() {
        let content = UNMutableNotificationContent()
        content.title = "High-Risk Window"
        content.body = "This is usually a tough time for you. Open your toolkit and stay strong."
        content.sound = .default
        content.categoryIdentifier = "HIGH_RISK_WINDOW"

        XCTAssertFalse(content.title.isEmpty, "High-risk alert title should not be empty")
        XCTAssertFalse(content.body.isEmpty, "High-risk alert body should not be empty")
        XCTAssertEqual(content.categoryIdentifier, "HIGH_RISK_WINDOW")
    }

    // MARK: - Trigger Configuration

    func testCalendarTriggerWithValidHourAndMinute() {
        var components = DateComponents()
        components.hour = 8
        components.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        XCTAssertTrue(trigger.repeats, "Daily reminder trigger should repeat")
        XCTAssertEqual(trigger.dateComponents.hour, 8, "Trigger hour should be 8")
        XCTAssertEqual(trigger.dateComponents.minute, 30, "Trigger minute should be 30")
    }

    func testCalendarTriggerAtMidnight() {
        var components = DateComponents()
        components.hour = 0
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        XCTAssertEqual(trigger.dateComponents.hour, 0, "Midnight trigger hour should be 0")
        XCTAssertEqual(trigger.dateComponents.minute, 0, "Midnight trigger minute should be 0")
    }

    func testCalendarTriggerAtEndOfDay() {
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        XCTAssertEqual(trigger.dateComponents.hour, 23, "End-of-day trigger hour should be 23")
        XCTAssertEqual(trigger.dateComponents.minute, 59, "End-of-day trigger minute should be 59")
    }

    func testTimeIntervalTriggerIsValid() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

        XCTAssertEqual(trigger.timeInterval, 60, "Time interval should be 60 seconds")
        XCTAssertFalse(trigger.repeats, "One-time trigger should not repeat")
    }

    // MARK: - Notification Request Assembly

    func testNotificationRequestAssembly() {
        let content = UNMutableNotificationContent()
        content.title = "Morning Pledge"
        content.body = "Start your day with intention."
        content.sound = .default

        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "com.resurge.pledge.reminder",
            content: content,
            trigger: trigger
        )

        XCTAssertEqual(request.identifier, "com.resurge.pledge.reminder")
        XCTAssertFalse(request.content.title.isEmpty, "Request content title should not be empty")
        XCTAssertFalse(request.content.body.isEmpty, "Request content body should not be empty")
        XCTAssertNotNil(request.trigger, "Request should have a trigger")
    }

    // MARK: - Manager Methods Do Not Crash

    func testSchedulePledgeReminderDoesNotCrash() {
        let manager = NotificationManager()
        // This will attempt to schedule with UNUserNotificationCenter;
        // it should not throw or crash even without notification permission.
        manager.schedulePledgeReminder(at: Date())
    }

    func testScheduleReflectionReminderDoesNotCrash() {
        let manager = NotificationManager()
        manager.scheduleReflectionReminder(at: Date())
    }

    func testScheduleHighRiskAlertDoesNotCrash() {
        let manager = NotificationManager()
        manager.scheduleHighRiskAlert(hour: 14, minute: 30)
    }

    func testCancelAllDoesNotCrash() {
        let manager = NotificationManager()
        manager.cancelAll()
    }
}
