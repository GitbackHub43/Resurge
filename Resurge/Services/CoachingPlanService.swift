import Foundation
import CoreData

// MARK: - CoachingPlanServiceProtocol

protocol CoachingPlanServiceProtocol {
    func generatePlan(for programType: ProgramType) -> [CoachingTask]
    func todaysTasks(for plan: CDCoachingPlan) -> [CoachingTask]
    func markCompleted(task: CoachingTask, plan: CDCoachingPlan)
}

// MARK: - CoachingPlanService

final class CoachingPlanService: CoachingPlanServiceProtocol {

    // MARK: - Generate Plan

    func generatePlan(for programType: ProgramType) -> [CoachingTask] {
        var tasks: [CoachingTask] = []

        // 9-day preparation program universal tasks
        let preparationTasks: [(Int, String, String, String)] = [
            (1, "Set Your Intention", "Write down your primary reason for quitting. Be specific about what you want to change and why it matters to you.", "mindset"),
            (1, "Identify Your Triggers", "List at least 5 situations, emotions, or environments that trigger your urges. Awareness is the first step.", "awareness"),
            (2, "Build Your Support Network", "Tell at least one trusted person about your goal. Having accountability partners significantly improves success rates.", "social"),
            (2, "Remove Access Points", "Identify and remove easy access to your habit. Reorganize your environment to add friction.", "environment"),
            (3, "Learn a Breathing Technique", "Practice the 4-7-8 breathing technique: inhale for 4 seconds, hold for 7, exhale for 8. Do 4 cycles.", "coping"),
            (3, "Plan Your Replacements", "For each trigger you identified, write down a healthy alternative activity you will do instead.", "strategy"),
            (4, "Practice Urge Surfing", "When you feel an urge today, observe it without acting. Notice where you feel it in your body. Urges peak and pass within 15-20 minutes.", "coping"),
            (4, "Set Up Your Environment", "Prepare your physical space for success. Stock healthy snacks, set up an exercise area, or organize calming activities.", "environment"),
            (5, "Visualize Success", "Spend 5 minutes visualizing yourself successfully navigating a trigger situation. Imagine the details vividly.", "mindset"),
            (5, "Create a Crisis Plan", "Write down exactly what you will do when the strongest urges hit. Include who to call, where to go, and what to do.", "strategy"),
            (6, "Physical Activity", "Complete at least 20 minutes of physical activity. Exercise releases endorphins that reduce cravings.", "health"),
            (6, "Journal Your Progress", "Write about what you have learned so far. Note any patterns in your triggers and how you feel about the journey ahead.", "reflection"),
            (7, "Practice Mindfulness", "Do a 10-minute mindfulness meditation. Focus on the present moment without judgment.", "coping"),
            (7, "Reward Planning", "Create a reward system for milestones. Plan small rewards for 1 day, 3 days, 1 week, and 1 month of success.", "motivation"),
            (8, "Stress Test Your Plan", "Intentionally put yourself in a mild trigger situation and practice your coping strategies. Build confidence in your tools.", "practice"),
            (8, "Affirmation Writing", "Write 5 personal affirmations that reinforce your commitment. Read them aloud each morning.", "mindset"),
            (9, "Final Preparation Check", "Review your full plan: triggers, coping strategies, support network, and rewards. Make sure everything is in place.", "review"),
            (9, "Commitment Ceremony", "Write your formal pledge. Sign it, date it, and share it with your accountability partner. Tomorrow is Day 1.", "commitment"),
        ]

        for (day, title, description, category) in preparationTasks {
            tasks.append(CoachingTask(
                dayNumber: day,
                title: title,
                description: description,
                category: category
            ))
        }

        // Add program-specific tasks
        let specificTasks = programSpecificTasks(for: programType)
        tasks.append(contentsOf: specificTasks)

        return tasks
    }

    // MARK: - Today's Tasks

    func todaysTasks(for plan: CDCoachingPlan) -> [CoachingTask] {
        let allTasks = decodeTasks(from: plan.tasksJSON)
        let currentDay = Int(plan.currentDay)
        return allTasks.filter { $0.dayNumber == currentDay }
    }

    // MARK: - Mark Completed

    func markCompleted(task: CoachingTask, plan: CDCoachingPlan) {
        var allTasks = decodeTasks(from: plan.tasksJSON)
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[index].isCompleted = true
        }
        plan.tasksJSON = encodeTasks(allTasks)

        // Advance day if all tasks for current day are completed
        let currentDay = Int(plan.currentDay)
        let todayTasks = allTasks.filter { $0.dayNumber == currentDay }
        if !todayTasks.isEmpty && todayTasks.allSatisfy({ $0.isCompleted }) {
            plan.currentDay += 1
        }

        if let context = plan.managedObjectContext, context.hasChanges {
            try? context.save()
        }
    }

    // MARK: - Private Helpers

    private func decodeTasks(from json: String?) -> [CoachingTask] {
        guard let json = json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([CoachingTask].self, from: data)) ?? []
    }

    private func encodeTasks(_ tasks: [CoachingTask]) -> String? {
        guard let data = try? JSONEncoder().encode(tasks) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func programSpecificTasks(for programType: ProgramType) -> [CoachingTask] {
        switch programType {
        case .smoking:
            return [
                CoachingTask(dayNumber: 10, title: "Nicotine Replacement Check", description: "If using NRT, ensure you have adequate supply. Consult your pharmacist about proper usage and dosing.", category: "health"),
                CoachingTask(dayNumber: 11, title: "Deep Breathing for Cravings", description: "Practice deep breathing whenever a cigarette craving hits. Most cravings last only 3-5 minutes.", category: "coping"),
                CoachingTask(dayNumber: 12, title: "Oral Fixation Alternatives", description: "Stock up on sugar-free gum, toothpicks, or cinnamon sticks for oral fixation moments.", category: "strategy"),
                CoachingTask(dayNumber: 14, title: "Calculate Savings", description: "Add up how much money you have saved by not buying cigarettes. Plan something rewarding with that money.", category: "motivation"),
            ]

        case .alcohol:
            return [
                CoachingTask(dayNumber: 10, title: "Sober Social Plan", description: "Plan how you will handle social situations where alcohol is present. Practice saying no confidently.", category: "social"),
                CoachingTask(dayNumber: 11, title: "Mocktail Discovery", description: "Find 3 non-alcoholic drinks you genuinely enjoy. Having alternatives makes social settings easier.", category: "strategy"),
                CoachingTask(dayNumber: 12, title: "Stress Without Alcohol", description: "Identify 3 healthy stress-relief methods that replace the role alcohol played in unwinding.", category: "coping"),
                CoachingTask(dayNumber: 14, title: "Sleep Quality Check", description: "Note improvements in your sleep quality. Alcohol disrupts REM sleep — your body is now recovering.", category: "health"),
            ]

        case .porn:
            return [
                CoachingTask(dayNumber: 10, title: "Digital Boundaries", description: "Install content blockers and set up device restrictions. Remove bookmarks and clear browsing history.", category: "environment"),
                CoachingTask(dayNumber: 11, title: "Redirect Energy", description: "Channel energy into physical exercise or a creative pursuit. Plan specific activities for vulnerable times.", category: "strategy"),
                CoachingTask(dayNumber: 12, title: "Understand the Cycle", description: "Learn about the dopamine cycle and how it reinforces compulsive behavior. Knowledge is power.", category: "education"),
                CoachingTask(dayNumber: 14, title: "Connection Inventory", description: "Reflect on how this habit affected your real relationships. Write about the connections you want to build.", category: "reflection"),
            ]

        case .phone:
            return [
                CoachingTask(dayNumber: 10, title: "Screen Time Audit", description: "Review your screen time data. Identify your top 3 time-consuming apps and set daily limits for each.", category: "awareness"),
                CoachingTask(dayNumber: 11, title: "Phone-Free Zones", description: "Designate areas in your home as phone-free: bedroom, dining table, bathroom.", category: "environment"),
                CoachingTask(dayNumber: 12, title: "Notification Detox", description: "Turn off all non-essential notifications. Keep only calls, messages from favorites, and calendar alerts.", category: "strategy"),
                CoachingTask(dayNumber: 14, title: "Analog Alternatives", description: "Replace 3 phone activities with analog alternatives: physical book, paper journal, board game.", category: "strategy"),
            ]

        case .socialMedia:
            return [
                CoachingTask(dayNumber: 10, title: "Unfollow Audit", description: "Unfollow accounts that trigger comparison, envy, or mindless scrolling. Curate a healthier feed.", category: "environment"),
                CoachingTask(dayNumber: 11, title: "Time Blocking", description: "Set specific 15-minute windows for social media use. Use a timer and stop when it rings.", category: "strategy"),
                CoachingTask(dayNumber: 12, title: "Real Connection", description: "Reach out to 3 friends via phone call or in-person meeting instead of online interaction.", category: "social"),
                CoachingTask(dayNumber: 14, title: "Content Creator to Consumer Ratio", description: "If you must use social media, create more than you consume. Post something meaningful.", category: "mindset"),
            ]

        case .gaming:
            return [
                CoachingTask(dayNumber: 10, title: "Gaming Time Audit", description: "Track exact hours spent gaming this week. Calculate what else you could accomplish with that time.", category: "awareness"),
                CoachingTask(dayNumber: 11, title: "Alternative Flow Activities", description: "Find 2 activities that provide flow states similar to gaming: sports, music, coding, art.", category: "strategy"),
                CoachingTask(dayNumber: 12, title: "Social Gaming Boundaries", description: "Communicate your goals to gaming friends. Set up alternative ways to stay connected.", category: "social"),
                CoachingTask(dayNumber: 14, title: "Achievement Transfer", description: "List real-life achievements you want to unlock. Create a quest log for actual life goals.", category: "motivation"),
            ]

        case .sugar:
            return [
                CoachingTask(dayNumber: 10, title: "Label Reading", description: "Check nutrition labels on 5 items you regularly consume. Learn the many names for hidden sugars.", category: "awareness"),
                CoachingTask(dayNumber: 11, title: "Healthy Swaps", description: "Replace 3 sugary snacks with whole-food alternatives: fruit, nuts, dark chocolate (70%+).", category: "strategy"),
                CoachingTask(dayNumber: 12, title: "Blood Sugar Stability", description: "Eat protein with every meal today. Stable blood sugar reduces sugar cravings dramatically.", category: "health"),
                CoachingTask(dayNumber: 14, title: "Taste Bud Reset", description: "Notice how your taste preferences are changing. Foods may start tasting sweeter as your palate adjusts.", category: "reflection"),
            ]

        case .emotionalEating:
            return [
                CoachingTask(dayNumber: 10, title: "Hunger Scale", description: "Before eating, rate your hunger from 1-10. Only eat when you are at 3-4. Learn physical vs. emotional hunger.", category: "awareness"),
                CoachingTask(dayNumber: 11, title: "Emotion Journal", description: "Every time you want to eat outside meals, write down what emotion you are feeling instead of eating.", category: "reflection"),
                CoachingTask(dayNumber: 12, title: "Comfort Alternatives", description: "Create a list of 10 non-food ways to comfort yourself: warm bath, walk, music, calling a friend.", category: "strategy"),
                CoachingTask(dayNumber: 14, title: "Mindful Eating Practice", description: "Eat one meal with zero distractions. Chew slowly, notice flavors and textures. Stop when satisfied.", category: "practice"),
            ]

        case .shopping:
            return [
                CoachingTask(dayNumber: 10, title: "Spending Audit", description: "Review your last 30 days of purchases. Categorize them as needs vs. wants. Calculate total impulse spending.", category: "awareness"),
                CoachingTask(dayNumber: 11, title: "24-Hour Rule", description: "For any non-essential purchase, wait 24 hours before buying. Write it on a wish list and revisit tomorrow.", category: "strategy"),
                CoachingTask(dayNumber: 12, title: "Unsubscribe Sweep", description: "Unsubscribe from all promotional emails and delete shopping apps from your phone.", category: "environment"),
                CoachingTask(dayNumber: 14, title: "Gratitude Inventory", description: "List 20 things you already own that you are grateful for. Appreciate what you have.", category: "mindset"),
            ]

        case .gambling:
            return [
                CoachingTask(dayNumber: 10, title: "Financial Reality Check", description: "Calculate total money lost to gambling. Write down the impact on your finances and relationships.", category: "awareness"),
                CoachingTask(dayNumber: 11, title: "Self-Exclusion", description: "Register for self-exclusion programs at casinos and online gambling platforms you have used.", category: "environment"),
                CoachingTask(dayNumber: 12, title: "Risk Assessment", description: "Identify high-risk situations: payday, sporting events, boredom. Plan specific responses for each.", category: "strategy"),
                CoachingTask(dayNumber: 14, title: "Financial Planning", description: "Set up a simple budget. Redirect money that would have been gambled toward savings or debt repayment.", category: "health"),
            ]

        }
    }
}
