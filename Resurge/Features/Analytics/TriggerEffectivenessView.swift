import SwiftUI
import CoreData

struct TriggerEffectivenessView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    let habit: CDHabit

    private struct TriggerStat: Identifiable {
        let id = UUID()
        let triggerName: String
        let count: Int
    }

    private var triggerStats: [TriggerStat] {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "triggerCategory != nil AND triggerCategory != ''")
        ])
        guard let entries = try? viewContext.fetch(request) else { return [] }

        var triggerCounts: [String: Int] = [:]
        for entry in entries {
            let triggers = (entry.triggerCategory ?? "").components(separatedBy: ",")
            for trigger in triggers where !trigger.trimmingCharacters(in: .whitespaces).isEmpty {
                triggerCounts[trigger.trimmingCharacters(in: .whitespaces), default: 0] += 1
            }
        }

        return triggerCounts.map { trigger, count in
            TriggerStat(triggerName: trigger, count: count)
        }.sorted { $0.count > $1.count }
    }

    private var maxCount: Int {
        triggerStats.map(\.count).max() ?? 1
    }

    private func triggerType(for name: String) -> TriggerType? {
        TriggerType.allStandard.first { $0.id == name }
    }

    private func triggerDisplayName(_ name: String) -> String {
        triggerType(for: name)?.displayName ?? name.capitalized
    }

    private func triggerIcon(_ name: String) -> String {
        triggerType(for: name)?.iconName ?? "questionmark.circle"
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    VStack(spacing: 6) {
                        Text("Trigger Analysis")
                            .font(.title2.weight(.bold))
                            .rainbowText()
                        Text("Understanding your triggers helps you prepare for them.")
                            .font(.subheadline)
                            .foregroundColor(.subtleText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    // MARK: - Bar Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trigger Frequency")
                            .font(.headline)
                            .foregroundColor(.appText)

                        ForEach(triggerStats) { stat in
                            HStack(spacing: 10) {
                                Image(systemName: triggerIcon(stat.triggerName))
                                    .font(.caption)
                                    .foregroundColor(.neonCyan)
                                    .frame(width: 20)

                                Text(triggerDisplayName(stat.triggerName))
                                    .font(.caption)
                                    .foregroundColor(.appText)
                                    .frame(width: 90, alignment: .leading)

                                GeometryReader { geo in
                                    let barWidth = (CGFloat(stat.count) / CGFloat(maxCount)) * geo.size.width
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(barColor(for: stat.count))
                                        .frame(width: max(barWidth, 4), height: 20)
                                }
                                .frame(height: 20)

                                Text("\(stat.count)")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.appText)
                                    .frame(width: 30, alignment: .trailing)
                            }
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
                    .padding(.horizontal)

                    // MARK: - Insight
                    if let topTrigger = triggerStats.first {
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.title3)
                                .foregroundColor(.neonGold)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Insight")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.appText)
                                Text("\(triggerDisplayName(topTrigger.triggerName)) is your most frequent trigger with \(topTrigger.count) occurrences. Consider building coping strategies around it.")
                                    .font(.caption)
                                    .foregroundColor(.subtleText)
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                                .opacity(0.4)
                        )
                        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Triggers")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func barColor(for count: Int) -> Color {
        let ratio = Double(count) / Double(maxCount)
        if ratio > 0.7 { return .neonMagenta.opacity(0.7) }
        if ratio > 0.4 { return .neonOrange.opacity(0.7) }
        return Color.neonCyan.opacity(0.7)
    }
}

// MARK: - Preview

struct TriggerEffectivenessView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        let habit = CDHabit.create(in: env.viewContext, name: "Quit Smoking", programType: "smoking")
        NavigationView {
            TriggerEffectivenessView(habit: habit)
                .environmentObject(env)
                .environment(\.managedObjectContext, env.viewContext)
        }
    }
}
