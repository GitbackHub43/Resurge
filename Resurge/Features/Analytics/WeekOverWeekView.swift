import SwiftUI
import CoreData

struct WeekOverWeekView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext

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

        // Cravings resisted
        let cravingRequest = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        cravingRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "timestamp >= %@ AND timestamp < %@", weekStart as NSDate, weekEnd as NSDate),
            NSPredicate(format: "didResist == YES")
        ])
        let resisted = (try? viewContext.count(for: cravingRequest)) ?? 0

        // Days with check-in
        let logRequest = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        logRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", weekStart as NSDate, weekEnd as NSDate)
        let logs = (try? viewContext.count(for: logRequest)) ?? 0

        return WeekData(cravingsResisted: resisted, daysClean: min(logs, 7), moodAverage: 0)
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
                if diff > 0 {
                    Label(String(format: "+%.1f", diff), systemImage: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.green)
                } else if diff < 0 {
                    Label(String(format: "%.1f", diff), systemImage: "arrow.down.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.red)
                }
            }

            HStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text(String(format: "%.1f", lastWeek.moodAverage))
                        .font(.title.weight(.bold))
                        .foregroundColor(.subtleText)
                    Text("Last Week")
                        .font(.caption)
                        .foregroundColor(.subtleText)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 6) {
                    Text(String(format: "%.1f", thisWeek.moodAverage))
                        .font(.title.weight(.bold))
                        .foregroundColor(.appText)
                    Text("This Week")
                        .font(.caption)
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
}

// MARK: - Preview

struct WeekOverWeekView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            WeekOverWeekView()
                .environmentObject(env)
        }
    }
}
