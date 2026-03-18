import SwiftUI
import CoreData

struct ToolEffectivenessView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    let habit: CDHabit

    private struct ToolStat: Identifiable {
        let id = UUID()
        let toolName: String
        let timesUsed: Int
        let successRate: Double // 0.0–1.0
        let avgCravingIntensity: Double // 1.0–10.0
    }

    private var toolStats: [ToolStat] {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "copingToolUsed != nil AND copingToolUsed != ''"),
            NSPredicate(format: "habit == %@", habit)
        ])
        guard let entries = try? viewContext.fetch(request) else { return [] }

        // Group by tool
        var toolGroups: [String: [CDCravingEntry]] = [:]
        for entry in entries {
            let tool = entry.copingToolUsed ?? "Unknown"
            toolGroups[tool, default: []].append(entry)
        }

        return toolGroups.map { tool, entries in
            let resisted = entries.filter { $0.didResist }.count
            let rate = entries.isEmpty ? 0 : Double(resisted) / Double(entries.count)
            let avgIntensity = entries.isEmpty ? 0 : entries.map { Double($0.intensity) }.reduce(0, +) / Double(entries.count)
            return ToolStat(toolName: tool, timesUsed: entries.count, successRate: rate, avgCravingIntensity: avgIntensity)
        }.sorted { $0.timesUsed > $1.timesUsed }
    }

    private var maxUsed: Int {
        toolStats.map(\.timesUsed).max() ?? 1
    }

    private static let knownTools: [CravingToolKind] = [
        .breathing, .puzzle, .quotes, .journaling, .bodyOverride,
        .urgeDefusion, .copingSimulator,
        .futureThinking, .focusShift, .valuesCompass
    ]

    private func toolKind(for name: String) -> CravingToolKind? {
        Self.knownTools.first { $0.id == name }
    }

    private func toolDisplayName(_ name: String) -> String {
        toolKind(for: name)?.displayName ?? name.capitalized
    }

    private func toolIcon(_ name: String) -> String {
        toolKind(for: name)?.iconName ?? "wrench.fill"
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    VStack(spacing: 6) {
                        Text("Tool Effectiveness")
                            .font(.title2.weight(.bold))
                            .rainbowText()
                        Text("See which coping tools help you the most.")
                            .font(.subheadline)
                            .foregroundColor(.subtleText)
                    }

                    // MARK: - Tool Cards
                    ForEach(toolStats) { stat in
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: toolIcon(stat.toolName))
                                    .font(.title3)
                                    .foregroundColor(.neonCyan)
                                Text(toolDisplayName(stat.toolName))
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                Spacer()
                                Text("\(Int(stat.successRate * 100))% success")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(successColor(stat.successRate))
                            }

                            // Success Rate Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(successColor(stat.successRate))
                                        .frame(width: geo.size.width * CGFloat(stat.successRate), height: 12)
                                }
                            }
                            .frame(height: 12)

                            HStack {
                                Text("Used \(stat.timesUsed) times")
                                    .font(.caption)
                                    .foregroundColor(.subtleText)
                                Spacer()
                                Text("\(Int(stat.successRate * Double(stat.timesUsed)))/\(stat.timesUsed) resisted")
                                    .font(.caption)
                                    .foregroundColor(.subtleText)
                            }

                            // Average craving intensity
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.caption)
                                    .foregroundColor(intensityColor(stat.avgCravingIntensity))
                                Text("Avg craving intensity when used:")
                                    .font(.caption)
                                    .foregroundColor(.subtleText)
                                Text(String(format: "%.1f/10", stat.avgCravingIntensity))
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(intensityColor(stat.avgCravingIntensity))
                                Spacer()
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
                    }
                    .padding(.horizontal)

                    // MARK: - Usage Bar Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Usage Frequency")
                            .font(.headline)
                            .foregroundColor(.appText)

                        ForEach(toolStats) { stat in
                            HStack(spacing: 10) {
                                Image(systemName: toolIcon(stat.toolName))
                                    .font(.caption)
                                    .foregroundColor(.neonBlue)
                                    .frame(width: 20)

                                Text(toolDisplayName(stat.toolName))
                                    .font(.caption)
                                    .foregroundColor(.appText)
                                    .frame(width: 80, alignment: .leading)

                                GeometryReader { geo in
                                    let barWidth = (CGFloat(stat.timesUsed) / CGFloat(maxUsed)) * geo.size.width
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.neonBlue.opacity(0.6))
                                        .frame(width: max(barWidth, 4), height: 18)
                                }
                                .frame(height: 18)

                                Text("\(stat.timesUsed)")
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

                    // MARK: - Intensity Comparison
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Craving Intensity by Tool")
                            .font(.headline)
                            .foregroundColor(.appText)

                        Text("Shows the average craving intensity when each tool was reached for. Higher intensity with high success rate means the tool works well under pressure.")
                            .font(.caption)
                            .foregroundColor(.subtleText)

                        ForEach(toolStats) { stat in
                            HStack(spacing: 10) {
                                Image(systemName: toolIcon(stat.toolName))
                                    .font(.caption)
                                    .foregroundColor(intensityColor(stat.avgCravingIntensity))
                                    .frame(width: 20)

                                Text(toolDisplayName(stat.toolName))
                                    .font(.caption)
                                    .foregroundColor(.appText)
                                    .frame(width: 80, alignment: .leading)

                                GeometryReader { geo in
                                    let barWidth = (CGFloat(stat.avgCravingIntensity) / 10.0) * geo.size.width
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(intensityColor(stat.avgCravingIntensity).opacity(0.6))
                                        .frame(width: max(barWidth, 4), height: 18)
                                }
                                .frame(height: 18)

                                Text(String(format: "%.1f", stat.avgCravingIntensity))
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

                    // MARK: - Recommendations
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.neonGold)
                            Text("Recommendations")
                                .font(.headline)
                                .foregroundColor(.appText)
                        }

                        if let best = toolStats.max(by: { $0.successRate < $1.successRate }) {
                            recommendationRow(
                                icon: "star.fill",
                                text: "\(toolDisplayName(best.toolName)) is your most effective tool at \(Int(best.successRate * 100))% success rate. Keep using it!",
                                color: .neonGreen
                            )
                        }

                        if let highIntensityWinner = toolStats.filter({ $0.avgCravingIntensity >= 6.0 }).max(by: { $0.successRate < $1.successRate }) {
                            recommendationRow(
                                icon: "flame.fill",
                                text: "\(toolDisplayName(highIntensityWinner.toolName)) works best during intense cravings (avg \(String(format: "%.1f", highIntensityWinner.avgCravingIntensity))/10) with \(Int(highIntensityWinner.successRate * 100))% success. Use it when things get tough.",
                                color: .neonOrange
                            )
                        }

                        if let worst = toolStats.min(by: { $0.successRate < $1.successRate }), worst.successRate < 0.7 {
                            recommendationRow(
                                icon: "arrow.up.right",
                                text: "Consider trying \(toolDisplayName(worst.toolName)) less and switching to higher-success tools when cravings are intense.",
                                color: .neonMagenta
                            )
                        }

                        recommendationRow(
                            icon: "plus.circle",
                            text: "Try combining breathing exercises with journaling for tough moments.",
                            color: .neonCyan
                        )
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
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Tool Effectiveness")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func successColor(_ rate: Double) -> Color {
        if rate >= 0.8 { return .green }
        if rate >= 0.6 { return .orange }
        return .red
    }

    private func intensityColor(_ intensity: Double) -> Color {
        if intensity >= 7.0 { return .neonMagenta }
        if intensity >= 5.0 { return .neonOrange }
        return .neonGold
    }

    @ViewBuilder
    private func recommendationRow(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .padding(.top, 2)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.appText)
        }
    }
}

// MARK: - Preview

struct ToolEffectivenessView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        let habit = CDHabit.create(in: env.viewContext, name: "Quit Smoking", programType: "smoking")
        NavigationView {
            ToolEffectivenessView(habit: habit)
                .environmentObject(env)
                .environment(\.managedObjectContext, env.viewContext)
        }
    }
}
