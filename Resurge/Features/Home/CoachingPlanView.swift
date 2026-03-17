import SwiftUI
import CoreData

struct CoachingPlanView: View {

    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext

    let habit: CDHabit

    @FetchRequest private var plans: FetchedResults<CDCoachingPlan>

    @State private var isGenerating = false
    @AppStorage("coachingTaskCompletedDate") private var coachingTaskCompletedDate: String = ""
    @AppStorage("coachingStreakCount") private var coachingStreakCount: Int = 0
    @AppStorage("coachingStreakLastDate") private var coachingStreakLastDate: String = ""

    // MARK: - All Tasks (cycle infinitely)

    private static let allTasks: [(String, String, String)] = [
        // Day 1 — mindset
        ("Set Your Intention", "Write down your primary reason for quitting. Be specific about what you want to change and why it matters to you.", "mindset"),
        // Day 2 — awareness
        ("Identify Your Triggers", "List at least 5 situations, emotions, or environments that trigger your urges. Awareness is the first step.", "awareness"),
        // Day 3 — social
        ("Build Your Support Network", "Tell at least one trusted person about your goal. Having accountability partners significantly improves success rates.", "social"),
        // Day 4 — coping
        ("Learn a Breathing Technique", "Practice the 4-7-8 breathing technique: inhale for 4 seconds, hold for 7, exhale for 8. Do 4 cycles.", "coping"),
        // Day 5 — strategy
        ("Plan Your Replacements", "For each trigger you identified, write down a healthy alternative activity you will do instead.", "strategy"),
        // Day 6 — health
        ("Physical Activity", "Complete at least 20 minutes of physical activity. Exercise releases endorphins that reduce cravings.", "health"),
        // Day 7 — reflection
        ("Journal Your Progress", "Write about what you have learned so far. Note any patterns in your triggers and how you feel about the journey ahead.", "reflection"),
        // Day 8 — mindset
        ("Visualize Success", "Spend 5 minutes visualizing yourself successfully navigating a trigger situation. Imagine the details vividly.", "mindset"),
        // Day 9 — strategy
        ("Create a Crisis Plan", "Write down exactly what you will do when the strongest urges hit. Include who to call, where to go, and what to do.", "strategy"),
        // Day 10 — coping
        ("Practice Urge Surfing", "When you feel an urge today, observe it without acting. Notice where you feel it in your body. Urges peak and pass within 15-20 minutes.", "coping"),
        // Day 11 — awareness
        ("Track Your Patterns", "Notice what time of day your urges are strongest. Write down every craving and what preceded it.", "awareness"),
        // Day 12 — social
        ("Reach Out Today", "Contact someone who supports your recovery. Share a win, a struggle, or simply connect. Isolation fuels relapse.", "social"),
        // Day 13 — health
        ("Hydration and Nutrition Check", "Drink at least 8 glasses of water today and eat balanced meals. Physical wellbeing directly impacts cravings.", "health"),
        // Day 14 — reflection
        ("Celebrate Your Progress", "Write about what has changed since you started. Even small wins matter. Acknowledge your effort.", "reflection"),
        // Day 15 — mindset
        ("Challenge Negative Thoughts", "When a self-defeating thought arises, write it down and replace it with a realistic, compassionate alternative.", "mindset"),
        // Day 16 — coping
        ("Grounding Exercise", "Practice the 5-4-3-2-1 technique: name 5 things you see, 4 you hear, 3 you feel, 2 you smell, and 1 you taste.", "coping"),
        // Day 17 — strategy
        ("Schedule Your Risk Times", "Identify your highest-risk hours today and pre-plan an activity for each one. Idle time is dangerous.", "strategy"),
        // Day 18 — awareness
        ("Emotional Inventory", "Check in with yourself: are you hungry, angry, lonely, or tired (HALT)? Address the root cause before it triggers a craving.", "awareness"),
        // Day 19 — social
        ("Gratitude Message", "Send a thank-you message to someone who has supported your journey. Gratitude strengthens bonds and boosts mood.", "social"),
        // Day 20 — health
        ("Sleep Quality Focus", "Aim for 7-9 hours of sleep tonight. Set a wind-down alarm 30 minutes before bed. No screens in the last hour.", "health"),
        // Day 21 — reflection
        ("Three-Week Reflection", "You have been at this for three weeks. Write about the hardest moment and how you overcame it.", "reflection"),
        // Day 22 — mindset
        ("Affirmation Writing", "Write 5 personal affirmations that reinforce your commitment. Read them aloud each morning this week.", "mindset"),
        // Day 23 — coping
        ("Progressive Muscle Relaxation", "Tense each muscle group for 5 seconds, then release. Work from toes to head. This reduces tension that triggers cravings.", "coping"),
        // Day 24 — strategy
        ("Reward Planning", "Create a reward system for upcoming milestones. Plan small rewards for 1 week, 2 weeks, and 1 month.", "strategy"),
        // Day 25 — awareness
        ("Social Trigger Audit", "Identify people, places, and situations that make recovery harder. Plan how to handle or avoid each one.", "awareness"),
        // Day 26 — social
        ("Practice Saying No", "Rehearse turning down offers or situations that threaten your progress. Say it out loud. Confidence comes from practice.", "social"),
        // Day 27 — health
        ("Mindful Movement", "Do 15 minutes of yoga, stretching, or tai chi. Slow, intentional movement calms the nervous system.", "health"),
        // Day 28 — reflection
        ("Letter to Your Future Self", "Write a letter to yourself one year from now. Describe the life you are building and why it is worth the effort.", "reflection"),
        // Day 29 — mindset
        ("Reframe Your Story", "Instead of 'I am giving something up,' tell yourself 'I am gaining freedom.' Reframing changes everything.", "mindset"),
        // Day 30 — coping
        ("Cold Water Reset", "When a craving hits, splash cold water on your face or hold ice cubes. The physical shock interrupts the craving circuit.", "coping"),
        // Day 31 — strategy
        ("Review and Update Plans", "Revisit your if-then plans, replacement activities, and crisis plan. Update anything that no longer fits.", "strategy"),
    ]

    // MARK: - Init

    init(habit: CDHabit) {
        self.habit = habit
        _plans = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \CDCoachingPlan.createdAt, ascending: false)],
            predicate: NSPredicate(format: "habitID == %@ AND isActive == YES", habit.id as CVarArg),
            animation: .default
        )
    }

    // MARK: - Computed

    private var activePlan: CDCoachingPlan? {
        plans.first
    }

    private var currentDayIndex: Int {
        let daysSober = habit.daysSoberCount
        return daysSober % Self.allTasks.count
    }

    private var todayTask: (title: String, description: String, category: String) {
        let task = Self.allTasks[currentDayIndex]
        return (title: task.0, description: task.1, category: task.2)
    }

    private var isCompletedToday: Bool {
        let todayString = formattedDate(Date())
        return coachingTaskCompletedDate == todayString
    }

    private var recoveryDay: Int {
        return habit.daysSoberCount + 1
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                if activePlan != nil {
                    headerSection
                    streakSection
                    todayTaskSection
                } else {
                    emptyState
                }
            }
            .padding(.vertical, AppStyle.spacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Daily Coaching")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Daily Coaching")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("Recovery Day \(recoveryDay)")
                .font(Typography.callout)
                .foregroundColor(.neonCyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.neonCyan.opacity(0.15))
                .cornerRadius(AppStyle.smallCornerRadius)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(coachingStreakCount)")
                    .font(Typography.statValue)
                    .foregroundColor(.neonGold)
                Text("Day Streak")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            VStack(spacing: 4) {
                Image(systemName: isCompletedToday ? "checkmark.seal.fill" : "seal")
                    .font(.system(size: 36))
                    .foregroundColor(isCompletedToday ? .neonGreen : .textSecondary)
                Text(isCompletedToday ? "Done Today" : "Pending")
                    .font(Typography.caption)
                    .foregroundColor(isCompletedToday ? .neonGreen : .textSecondary)
            }
        }
        .neonCard(glow: .neonGold)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Today's Task

    private var todayTaskSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack {
                Text("Today's Task")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                categoryBadge(todayTask.category)
            }

            Text(todayTask.title)
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text(todayTask.description)
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if isCompletedToday {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.neonGreen)
                    Text("Completed")
                        .font(Typography.headline)
                        .foregroundColor(.neonGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.neonGreen.opacity(0.1))
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
                )
            } else {
                Button {
                    completeTask()
                } label: {
                    Text("Mark Complete")
                }
                .buttonStyle(RainbowButtonStyle())
            }
        }
        .neonCard(glow: colorForCategory(todayTask.category))
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Category Badge

    private func categoryBadge(_ category: String) -> some View {
        let color = colorForCategory(category)
        return Text(category.capitalized)
            .font(Typography.caption)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .cornerRadius(AppStyle.smallCornerRadius)
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "mindset":     return .neonPurple
        case "awareness":   return .neonCyan
        case "coping":      return .neonGreen
        case "environment": return .neonOrange
        case "social":      return .neonMagenta
        case "strategy":    return .neonGold
        case "health":      return .neonGreen
        case "reflection":  return .neonCyan
        case "motivation":  return .neonOrange
        case "practice":    return .neonMagenta
        case "review":      return .neonPurple
        case "commitment":  return .neonGold
        case "education":   return .neonCyan
        default:            return .textSecondary
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            Image(systemName: "map.fill")
                .font(.system(size: 56))
                .foregroundColor(.neonCyan.opacity(0.5))

            Text("Start Daily Coaching")
                .font(Typography.title)
                .rainbowText()

            Text("Get a new recovery task every day, tailored to build awareness, coping skills, and lasting change. Tasks cycle through mindset, awareness, coping, social, strategy, health, and reflection.")
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Button {
                generatePlan()
            } label: {
                HStack(spacing: 8) {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("Start Daily Coaching")
                }
            }
            .buttonStyle(RainbowButtonStyle())
            .disabled(isGenerating)
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()
        }
    }

    // MARK: - Actions

    private func generatePlan() {
        isGenerating = true
        let programType = ProgramType(rawValue: habit.programType) ?? .smoking
        let tasks = environment.coachingService.generatePlan(for: programType)

        if let data = try? JSONEncoder().encode(tasks),
           let json = String(data: data, encoding: .utf8) {
            CDCoachingPlan.create(
                in: viewContext,
                habitID: habit.id,
                planType: programType.rawValue,
                tasksJSON: json
            )
            try? viewContext.save()
        }
        isGenerating = false
    }

    private func completeTask() {
        let todayString = formattedDate(Date())
        let yesterdayString = formattedDate(Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())

        // Update streak
        if coachingStreakLastDate == yesterdayString {
            coachingStreakCount += 1
        } else if coachingStreakLastDate != todayString {
            coachingStreakCount = 1
        }

        coachingTaskCompletedDate = todayString
        coachingStreakLastDate = todayString
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

struct CoachingPlanView_Previews: PreviewProvider {
    static var previews: some View {
        let stack = CoreDataStack.preview
        let habit = CDHabit.create(in: stack.viewContext, name: "Quit Smoking", programType: "smoking")
        return NavigationView {
            CoachingPlanView(habit: habit)
        }
        .environmentObject(AppEnvironment.preview)
        .environment(\.managedObjectContext, stack.viewContext)
    }
}
