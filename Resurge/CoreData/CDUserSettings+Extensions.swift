import Foundation
import CoreData

@objc(CDUserSettings)
public class CDUserSettings: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var hasCompletedOnboarding: Bool
    @NSManaged public var isPremium: Bool
    @NSManaged public var subscriptionExpiresAt: Date?
    @NSManaged public var biometricLockEnabled: Bool
    @NSManaged public var darkModePreference: Int16
    @NSManaged public var dailyPledgeReminderTime: Date?
    @NSManaged public var eveningReflectionTime: Date?
    @NSManaged public var cravingCheckInEnabled: Bool
    @NSManaged public var supabaseUserID: String?
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var timezone: String
    @NSManaged public var currency: String

    // MARK: - Fetch-or-Create Singleton

    static func fetchOrCreate(in context: NSManagedObjectContext) -> CDUserSettings {
        let request: NSFetchRequest<CDUserSettings> = NSFetchRequest(entityName: "CDUserSettings")
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let settings = CDUserSettings(context: context)
        settings.id = UUID()
        settings.hasCompletedOnboarding = false
        settings.isPremium = false
        settings.subscriptionExpiresAt = nil
        settings.biometricLockEnabled = false
        settings.darkModePreference = 0
        settings.dailyPledgeReminderTime = nil
        settings.eveningReflectionTime = nil
        settings.cravingCheckInEnabled = false
        settings.supabaseUserID = nil
        settings.lastSyncDate = nil
        settings.timezone = TimeZone.current.identifier
        settings.currency = "USD"

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Failed to save new CDUserSettings: \(nsError), \(nsError.userInfo)")
        }

        return settings
    }
}
