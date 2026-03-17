import CoreData
import Foundation

enum PreviewData {
    static var context: NSManagedObjectContext {
        CoreDataStack.preview.viewContext
    }

    @discardableResult
    static func sampleHabit(context: NSManagedObjectContext? = nil) -> CDHabit {
        let ctx = context ?? self.context
        let habit = CDHabit(context: ctx)
        habit.id = UUID()
        habit.name = "Quit Smoking"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        habit.goalDays = 30
        habit.costPerUnit = 0.50
        habit.timePerUnit = 5
        habit.dailyUnits = 15
        habit.baselineCostPerDay = 7.50
        habit.baselineTimePerDay = 75
        habit.reasonToQuit = "For my kids and my health"
        habit.isActive = true
        habit.sortOrder = 0
        habit.colorHex = "#008080"
        habit.iconName = "lungs.fill"
        habit.createdAt = Date()
        habit.updatedAt = Date()
        return habit
    }

    @discardableResult
    static func sampleAlcoholHabit(context: NSManagedObjectContext? = nil) -> CDHabit {
        let ctx = context ?? self.context
        let habit = CDHabit(context: ctx)
        habit.id = UUID()
        habit.name = "No Alcohol"
        habit.programType = "alcohol"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        habit.goalDays = 90
        habit.costPerUnit = 8.0
        habit.timePerUnit = 30
        habit.dailyUnits = 3
        habit.baselineCostPerDay = 24.0
        habit.baselineTimePerDay = 90
        habit.reasonToQuit = "Better sleep and relationships"
        habit.isActive = true
        habit.sortOrder = 1
        habit.colorHex = "#FF6F3C"
        habit.iconName = "drop.fill"
        habit.createdAt = Date()
        habit.updatedAt = Date()
        return habit
    }

    @discardableResult
    static func sampleLog(for habit: CDHabit, daysAgo: Int = 0, context: NSManagedObjectContext? = nil) -> CDDailyLogEntry {
        let ctx = context ?? self.context
        let log = CDDailyLogEntry(context: ctx)
        log.id = UUID()
        log.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        log.didPledge = true
        log.pledgeText = "I will stay strong today"
        log.didReflect = daysAgo > 0
        log.reflectionText = daysAgo > 0 ? "Made it through another day" : nil
        log.lapsedToday = false
        log.mood = Int16([2, 3, 4, 4, 5].randomElement() ?? 3)
        log.createdAt = Date()
        log.habit = habit
        return log
    }

    @discardableResult
    static func sampleCraving(for habit: CDHabit, context: NSManagedObjectContext? = nil) -> CDCravingEntry {
        let ctx = context ?? self.context
        let craving = CDCravingEntry(context: ctx)
        craving.id = UUID()
        craving.timestamp = Date()
        craving.intensity = Int16.random(in: 3...8)
        craving.triggerCategory = ["stress", "boredom", "social", "emotional"].randomElement()
        craving.copingToolUsed = ["breathing", "walking", "water"].randomElement()
        craving.didResist = true
        craving.durationSeconds = Int32.random(in: 60...600)
        craving.mood = Int16.random(in: 2...4)
        craving.habit = habit
        return craving
    }

    @discardableResult
    static func sampleJournalEntry(for habit: CDHabit? = nil, context: NSManagedObjectContext? = nil) -> CDJournalEntry {
        let ctx = context ?? self.context
        let entry = CDJournalEntry(context: ctx)
        entry.id = UUID()
        entry.date = Date()
        entry.title = "Feeling Stronger"
        entry.body = "Today was challenging but I pushed through. The breathing exercises really helped when I felt the urge."
        entry.mood = 4
        entry.isReflection = false
        entry.createdAt = Date()
        entry.updatedAt = Date()
        entry.habit = habit
        return entry
    }

    @discardableResult
    static func samplePost(context: NSManagedObjectContext? = nil) -> CDCommunityPost {
        let ctx = context ?? self.context
        let post = CDCommunityPost(context: ctx)
        post.id = UUID()
        post.authorName = "RecoveryChamp"
        post.authorID = "user_123"
        post.habitCategory = "smoking"
        post.title = "30 Days Smoke Free!"
        post.body = "I never thought I could make it this far. The craving tools in this app have been a game changer. Keep going everyone!"
        post.likeCount = 24
        post.commentCount = 5
        post.isFlagged = false
        post.markedAsDeleted = false
        post.createdAt = Date()
        post.updatedAt = Date()
        return post
    }

    static func populatePreviewData(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? self.context
        let habit = sampleHabit(context: ctx)
        let alcoholHabit = sampleAlcoholHabit(context: ctx)

        for i in 0..<7 {
            sampleLog(for: habit, daysAgo: i, context: ctx)
            if i < 5 { sampleLog(for: alcoholHabit, daysAgo: i, context: ctx) }
        }

        for _ in 0..<5 {
            sampleCraving(for: habit, context: ctx)
        }

        sampleJournalEntry(for: habit, context: ctx)
        samplePost(context: ctx)

        try? ctx.save()
    }
}
