import SwiftUI
import CoreData

struct WeekOverWeekView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    let habit: CDHabit

    private struct WeekData {
        let cravingsResisted: Int
        let daysClean: Int
        let moodAverage: Double
    }

    private var thisWeek: WeekData {
        computeWeekData(weeksAgo: 0)
    }
    private var lastWeek: WeekData {
        computeWeekData(weeksAgo: 1)
    }

    private func computeWeekData(weeksAgo: Int) -> WeekData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday - calendar.firstWeekday + 7) % 7
        let thisWeekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: thisWeekStart)!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

        // Cravings resisted — filtered by habit
        let cravingRequest = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        cravingRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "timestamp >= %@ AND timestamp < %@", weekStart as NSDate, weekEnd as NSDate),
            NSPredicate(format: "didResist == YES")
        ])
        let resisted = (try? viewContext.count(for: cravingRequest)) ?? 0

        // Days clean — use the habit's actual days sober, capped to this week
        let habitStart = calendar.startOfDay(for: habit.startDate)
        let effectiveStart = max(weekStart, habitStart) // Don't count before habit existed
        let effectiveEnd = weeksAgo == 0 ? calendar.date(byAdding: .day, value: 1, to: today)! : weekEnd

        let daysInRange: Int
        if effectiveStart >= effectiveEnd {
            daysInRange = 0
        } else {
            daysInRange = max(0, calendar.dateComponents([.day], from: effectiveStart, to: effectiveEnd).day ?? 0)
        }

        // Count lapse entries in this range
        let logRequest = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        logRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "createdAt >= %@ AND createdAt < %@", effectiveStart as NSDate, effectiveEnd as NSDate),
            NSPredicate(format: "lapsedToday == YES")
        ])
        let lapseDays = (try? viewContext.count(for: logRequest)) ?? 0
        let daysClean = max(0, daysInRange - lapseDays)

        // Average mood from all log entries and journal entries this week
        let moodLogRequest = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        moodLogRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "createdAt >= %@ AND createdAt < %@", weekStart as NSDate, weekEnd as NSDate),
            NSPredicate(format: "mood > 0")
        ])
        let moodLogs = (try? viewContext.fetch(moodLogRequest)) ?? []

        let journalMoodRequest = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        journalMoodRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "createdAt >= %@ AND createdAt < %@", weekStart as NSDate, weekEnd as NSDate),
            NSPredicate(format: "mood > 0")
        ])
        let journalMoods = (try? viewContext.fetch(journalMoodRequest)) ?? []

        var allMoods: [Double] = moodLogs.map { Double($0.mood) } + journalMoods.map { Double($0.mood) }
        let avgMood = allMoods.isEmpty ? 0 : allMoods.reduce(0, +) / Double(allMoods.count)

        return WeekData(cravingsResisted: resisted, daysClean: daysClean, moodAverage: avgMood)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    Text("Compare your progress week over week")
                        .font(.subheadline)
                        .foregroundColor(.subtleText)
                        .padding(.horizontal)

                    // MARK: - Cravings Resisted
                    comparisonCard(
                        title: "Cravings Resisted",
                        icon: "hand.raised.fill",
                        thisWeekValue: thisWeek.cravingsResisted,
                        lastWeekValue: lastWeek.cravingsResisted,
                        color: .neonCyan
                    )

                    // MARK: - Days Clean
                    comparisonCard(
                        title: "Days Clean",
                        icon: "calendar.badge.checkmark",
                        thisWeekValue: thisWeek.daysClean,
                        lastWeekValue: lastWeek.daysClean,
                        color: .neonPurple
                    )

                    // MARK: - Mood Average
                    moodComparisonCard()
                }
                .padding()
            }
        }
        .navigationTitle("Week Over Week")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func comparisonCard(title: String, icon: String, thisWeekValue: Int, lastWeekValue: Int, color: Color) -> some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appText)
                Spacer()
                let diff = thisWeekValue - lastWeekValue
                if diff > 0 {
                    Label("+\(diff)", systemImage: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.green)
                } else if diff < 0 {
                    Label("\(diff)", systemImage: "arrow.down.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.red)
                } else {
                    Text("Same")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.subtleText)
                }
            }

            HStack(spacing: 16) {
                // Last Week Bar
                VStack(spacing: 6) {
                    barView(value: lastWeekValue, maxValue: max(thisWeekValue, lastWeekValue), color: color.opacity(0.3))
                    Text("Last Week")
                        .font(.caption2)
                        .foregroundColor(.subtleText)
                    Text("\(lastWeekValue)")
                        .font(.headline)
                        .foregroundColor(.subtleText)
                }
                .frame(maxWidth: .infinity)

                // This Week Bar
                VStack(spacing: 6) {
                    barView(value: thisWeekValue, maxValue: max(thisWeekValue, lastWeekValue), color: color)
                    Text("This Week")
                        .font(.caption2)
                        .foregroundColor(.appText)
                    Text("\(thisWeekValue)")
                        .font(.headline)
                        .foregroundColor(.appText)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    @ViewBuilder
    private func barView(value: Int, maxValue: Int, color: Color) -> some View {
        let height: CGFloat = maxValue > 0 ? CGFloat(value) / CGFloat(maxValue) * 100 : 0
        VStack {
            Spacer()
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(width: 40, height: max(height, 4))
        }
        .frame(height: 100)
    }

    @ViewBuilder
    private func moodComparisonCard() -> some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "face.smiling")
                    .foregroundColor(.neonGold)
                Text("Average Mood")
                    .font(.headline)
                    .foregroundColor(.appText)
                Spacer()
                let diff = thisWeek.moodAverage - lastWeek.moodAverage
                if diff > 0.3 {
                    Label("Better", systemImage: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.green)
                } else if diff < -0.3 {
                    Label("Lower", systemImage: "arrow.down.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.red)
                } else if thisWeek.moodAverage > 0 {
                    Text("Stable")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.subtleText)
                }
            }

            // Mood health bars
            VStack(spacing: 12) {
                moodHealthBar(label: "This Week", avg: thisWeek.moodAverage, isPrimary: true)
                moodHealthBar(label: "Last Week", avg: lastWeek.moodAverage, isPrimary: false)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    // MARK: - Mood Health Bar

    @ViewBuilder
    private func moodHealthBar(label: String, avg: Double, isPrimary: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isPrimary ? .appText : .subtleText)
                Spacer()
                if avg > 0 {
                    Text(moodEmoji(avg))
                        .font(.system(size: 20))
                    Text(moodLabel(avg))
                        .font(.caption2.weight(.medium))
                        .foregroundColor(isPrimary ? .appText : .subtleText)
                } else {
                    Text("No data")
                        .font(.caption2)
                        .foregroundColor(.subtleText)
                }
            }

            // Health bar with all 5 emoji faces
            GeometryReader { geo in
                let segmentWidth = geo.size.width / 5
                ZStack(alignment: .leading) {
                    // Background segments
                    HStack(spacing: 0) {
                        ForEach(MoodState.allCases) { mood in
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: segmentWidth, height: 24)
                                .overlay(
                                    Text(mood.emoji)
                                        .font(.system(size: 12))
                                        .opacity(0.4)
                                )
                        }
                    }

                    // Green fill up to the average
                    if avg > 0 {
                        let fillFraction = CGFloat((avg - 1) / 4) // 1-5 mapped to 0-1
                        let fillWidth = fillFraction * geo.size.width
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.neonGreen.opacity(0.6), .neonGreen.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, min(fillWidth, geo.size.width)), height: 24)

                        // Marker line at the exact average position
                        Rectangle()
                            .fill(Color.neonGreen)
                            .frame(width: 3, height: 24)
                            .offset(x: max(0, min(fillWidth - 1.5, geo.size.width - 3)))
                    }

                    // Emoji labels on top
                    HStack(spacing: 0) {
                        ForEach(MoodState.allCases) { mood in
                            Text(mood.emoji)
                                .font(.system(size: 12))
                                .frame(width: segmentWidth, height: 24)
                        }
                    }
                }
                .cornerRadius(6)
                .clipped()
            }
            .frame(height: 24)
        }
    }

    // MARK: - Mood Helpers

    private func moodEmoji(_ avg: Double) -> String {
        if avg <= 0 { return "➖" }
        let rounded = Int(avg.rounded())
        return (MoodState(rawValue: max(1, min(5, rounded))) ?? .neutral).emoji
    }

    private func moodLabel(_ avg: Double) -> String {
        if avg <= 0 { return "No data" }
        let rounded = Int(avg.rounded())
        return (MoodState(rawValue: max(1, min(5, rounded))) ?? .neutral).displayName
    }
}

// MARK: - Preview

struct WeekOverWeekView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        let habit = CDHabit.create(in: env.viewContext, name: "Quit Smoking", programType: "smoking")
        NavigationView {
            WeekOverWeekView(habit: habit)
                .environmentObject(env)
                .environment(\.managedObjectContext, env.viewContext)
        }
    }
}
