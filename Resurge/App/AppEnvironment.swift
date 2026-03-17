import SwiftUI
import CoreData

final class AppEnvironment: ObservableObject {
    let coreDataStack: CoreDataStack
    let habitRepository: HabitRepositoryProtocol
    let logRepository: LogRepositoryProtocol
    let cravingRepository: CravingRepositoryProtocol
    let journalRepository: JournalRepositoryProtocol
    let achievementRepository: AchievementRepositoryProtocol

    let notificationManager: NotificationManager
    let biometricManager: BiometricLockManager
    let insightsService: InsightsServiceProtocol
    let coachingService: CoachingPlanServiceProtocol
    let companionService: VirtualCompanionService
    let calendarService: CalendarMilestoneServiceProtocol
    let healthKitManager: HealthKitManagerProtocol
    let achievementService: AchievementEvaluationService
    let rewardService: RewardService

    @Published var entitlementManager: EntitlementManager

    var viewContext: NSManagedObjectContext {
        coreDataStack.viewContext
    }

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        let context = coreDataStack.viewContext

        // Repositories
        self.habitRepository = CoreDataHabitRepository(context: context)
        self.logRepository = CoreDataLogRepository(context: context)
        self.cravingRepository = CoreDataCravingRepository(context: context)
        self.journalRepository = CoreDataJournalRepository(context: context)
        self.achievementRepository = CoreDataAchievementRepository(context: context)

        // Services
        self.notificationManager = NotificationManager()
        self.biometricManager = BiometricLockManager()
        self.insightsService = InsightsService(
            cravingRepository: CoreDataCravingRepository(context: context),
            logRepository: CoreDataLogRepository(context: context)
        )
        self.coachingService = CoachingPlanService()
        self.companionService = VirtualCompanionService(context: context)
        self.calendarService = CalendarMilestoneService()
        self.healthKitManager = HealthKitManager()
        self.achievementService = AchievementEvaluationService(context: context, achievementRepository: CoreDataAchievementRepository(context: context))
        self.rewardService = RewardService()

        // IAP (native StoreKit 2 — no external dependencies)
        let iapProvider = StoreKit2Provider()
        self.entitlementManager = EntitlementManager(provider: iapProvider)
    }

    static var preview: AppEnvironment {
        AppEnvironment(coreDataStack: .preview)
    }
}
