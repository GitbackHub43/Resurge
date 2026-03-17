import SwiftUI
import CoreData

struct CompanionView: View {

    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \CDHabit.createdAt, ascending: false)
        ],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    )
    private var activeHabits: FetchedResults<CDHabit>

    @State private var editingName = false
    @State private var nameText = ""
    @State private var bounceAvatar = false

    // MARK: - Computed

    private var companion: CDVirtualCompanion? {
        environment.companionService.companion
    }

    private var mood: String {
        environment.companionService.computeMoodFromRecovery(
            habits: Array(activeHabits),
            context: viewContext
        )
    }

    private var level: Int {
        let streak = environment.companionService.longestActiveStreak(habits: Array(activeHabits))
        return environment.companionService.levelForStreak(streak)
    }

    private var currentStreak: Int {
        environment.companionService.longestActiveStreak(habits: Array(activeHabits))
    }

    private var companionName: String {
        companion?.name ?? "Guardian"
    }

    private var speechBubbleMessage: String {
        environment.companionService.contextualMessage(
            for: Array(activeHabits),
            context: viewContext
        )
    }

    private var moodEmoji: String {
        switch mood {
        case "sad":      return "\u{1F622}"  // crying
        case "worried":  return "\u{1F61F}"  // worried
        case "neutral":  return "\u{1F610}"  // neutral
        case "happy":    return "\u{1F60A}"  // happy
        case "proud":    return "\u{1F624}"  // proud
        case "ecstatic": return "\u{1F973}"  // partying
        default:         return "\u{1F60A}"
        }
    }

    private var moodGlowColor: Color {
        switch mood {
        case "sad":      return .neonPurple
        case "worried":  return .neonOrange
        case "neutral":  return .neonCyan
        case "happy":    return .neonGreen
        case "proud":    return .neonMagenta
        case "ecstatic": return .neonGold
        default:         return .neonCyan
        }
    }

    private var moodLabel: String {
        mood.capitalized
    }

    private static let rainbowColors: [Color] = [
        .neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold
    ]

    private var rainbowGradient: LinearGradient {
        LinearGradient(
            colors: Self.rainbowColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Level Milestones

    private struct LevelMilestone: Identifiable {
        let id = UUID()
        let level: Int
        let dayThreshold: Int
        let label: String
        let reached: Bool
    }

    private var milestones: [LevelMilestone] {
        let streak = currentStreak
        return [
            LevelMilestone(level: 1, dayThreshold: 0, label: "First Steps", reached: streak >= 0),
            LevelMilestone(level: 2, dayThreshold: 7, label: "One Week", reached: streak >= 7),
            LevelMilestone(level: 3, dayThreshold: 14, label: "Two Weeks", reached: streak >= 14),
            LevelMilestone(level: 4, dayThreshold: 30, label: "One Month", reached: streak >= 30),
            LevelMilestone(level: 5, dayThreshold: 60, label: "Two Months", reached: streak >= 60),
            LevelMilestone(level: 6, dayThreshold: 90, label: "Three Months", reached: streak >= 90)
        ]
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                avatarSection
                speechBubbleSection
                nameSection
                quoteOfTheDayCard
                recoveryStatsCard
                journeySection
            }
            .padding(.vertical, AppStyle.spacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Recovery Guardian")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let _ = environment.companionService.getOrCreate(context: viewContext)
            nameText = companionName
            environment.companionService.updateFromRecoveryState(
                habits: Array(activeHabits),
                context: viewContext
            )
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(moodGlowColor.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .shadow(color: moodGlowColor.opacity(0.3), radius: 24, x: 0, y: 0)

                // Rainbow gradient border ring
                Circle()
                    .stroke(rainbowGradient, lineWidth: 4)
                    .frame(width: 156, height: 156)

                // Inner fill
                Circle()
                    .fill(Color.cardBackground)
                    .frame(width: 148, height: 148)

                // Mood emoji
                Text(moodEmoji)
                    .font(.system(size: 72))
                    .scaleEffect(bounceAvatar ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: bounceAvatar)
            }
            .onTapGesture {
                triggerBounce()
            }

            // Level badge with rainbow gradient
            Text("Level \(level)")
                .font(Typography.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(rainbowGradient)
                .cornerRadius(AppStyle.smallCornerRadius)
        }
    }

    // MARK: - Speech Bubble

    private var speechBubbleSection: some View {
        VStack(spacing: 0) {
            // Triangle pointing up toward avatar
            Triangle()
                .fill(Color.cardBackground)
                .frame(width: 20, height: 10)

            Text(speechBubbleMessage)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(AppStyle.cardPadding)
                .frame(maxWidth: .infinity)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(rainbowGradient, lineWidth: 1.5)
                )
                .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(spacing: 4) {
            if editingName {
                HStack(spacing: 8) {
                    TextField("Name", text: $nameText)
                        .font(Typography.title)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 200)

                    Button {
                        saveName()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.neonGreen)
                    }
                }
            } else {
                Button {
                    nameText = companionName
                    editingName = true
                } label: {
                    HStack(spacing: 6) {
                        Text(companionName)
                            .font(Typography.title)
                            .rainbowText()
                        Image(systemName: "pencil")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Quote of the Day

    private var quoteOfTheDayCard: some View {
        let quote = QuoteBank.quoteOfTheDay()
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(Typography.callout)
                    .foregroundColor(.neonGold)
                Text("Message of the Day")
                    .font(Typography.callout.weight(.bold))
                    .foregroundColor(.textSecondary)
                Spacer()
            }

            Text(quote.text)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("- \(quote.author)")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(rainbowGradient, lineWidth: 1)
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Recovery Stats Summary

    private var recoveryStatsCard: some View {
        HStack(spacing: AppStyle.spacing) {
            statItem(title: "Streak", value: "\(currentStreak)d", icon: "flame.fill", color: .neonOrange)
            statItem(title: "Level", value: "\(level)", icon: "shield.fill", color: .neonCyan)
            statItem(title: "Mood", value: moodLabel, icon: "heart.fill", color: .neonMagenta)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            Text(title)
                .font(Typography.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(rainbowGradient, lineWidth: 1)
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    // MARK: - Journey Section

    private var journeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Journey Together")
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            ForEach(milestones) { milestone in
                HStack(spacing: 12) {
                    // Milestone indicator
                    ZStack {
                        Circle()
                            .fill(milestone.reached ? moodGlowColor.opacity(0.2) : Color.cardBorder.opacity(0.2))
                            .frame(width: 36, height: 36)

                        if milestone.reached {
                            Image(systemName: "checkmark.circle.fill")
                                .font(Typography.body)
                                .foregroundColor(moodGlowColor)
                        } else {
                            Image(systemName: "circle")
                                .font(Typography.body)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Level \(milestone.level) — \(milestone.label)")
                            .font(Typography.callout.weight(.bold))
                            .foregroundColor(milestone.reached ? .textPrimary : .textSecondary)

                        Text("Day \(milestone.dayThreshold)")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    if milestone.reached {
                        Image(systemName: "star.fill")
                            .font(Typography.caption)
                            .foregroundColor(.neonGold)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(rainbowGradient, lineWidth: 1)
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Helpers

    private func triggerBounce() {
        bounceAvatar = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            bounceAvatar = false
        }
    }

    private func saveName() {
        let trimmed = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        companion?.name = trimmed
        try? viewContext.save()
        editingName = false
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

struct CompanionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompanionView()
        }
        .environmentObject(AppEnvironment.preview)
        .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
    }
}
