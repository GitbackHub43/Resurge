import SwiftUI
import CoreData

struct CorrelationInsightsView: View {
    @ObservedObject var habit: CDHabit

    @State private var correlations: [CorrelationEngine.CorrelationResult] = []
    @State private var hasLoaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack {
                Image(systemName: "chart.dots.scatter")
                    .foregroundColor(.neonCyan)
                Text("Correlation Insights")
                    .font(Typography.headline)
                    .foregroundColor(.appText)
            }

            Text("How your daily check-in metrics relate to each other (last 30 days).")
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            if correlations.isEmpty {
                if hasLoaded {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .font(.title)
                            .foregroundColor(.subtleText.opacity(0.5))
                        Text("Not enough data yet")
                            .font(Typography.callout)
                            .foregroundColor(.subtleText)
                        Text("Complete at least 5 daily check-ins to see correlations.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppStyle.largeSpacing)
                }
            } else {
                ForEach(correlations, id: \.id) { result in
                    correlationRow(result)
                }
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        .onAppear {
            if !hasLoaded {
                correlations = CorrelationEngine.computeCorrelations(for: habit)
                hasLoaded = true
            }
        }
    }

    @ViewBuilder
    private func correlationRow(_ result: CorrelationEngine.CorrelationResult) -> some View {
        HStack(spacing: AppStyle.spacing) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(displayName(for: result.field1)) & \(displayName(for: result.field2))")
                    .font(Typography.callout)
                    .foregroundColor(.appText)

                Text(result.interpretation)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f", result.coefficient))
                    .font(Typography.callout)
                    .foregroundColor(result.coefficient > 0 ? .neonCyan : .neonMagenta)

                Text(result.strength.capitalized)
                    .font(Typography.caption)
                    .foregroundColor(strengthColor(result.strength))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(strengthColor(result.strength).opacity(0.15))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }

    private func displayName(for field: String) -> String {
        switch field {
        case "mood": return "Mood"
        case "stress": return "Stress"
        case "energy": return "Energy"
        case "sleepQuality": return "Sleep"
        case "loneliness": return "Loneliness"
        case "cravingToday": return "Craving"
        default: return field.capitalized
        }
    }

    private func strengthColor(_ strength: String) -> Color {
        switch strength {
        case "strong": return .neonOrange
        case "moderate": return .neonPurple
        default: return .subtleText
        }
    }
}

// MARK: - CorrelationEngine.CorrelationResult Extension

extension CorrelationEngine.CorrelationResult {
    var id: String { "\(field1)-\(field2)" }

    var interpretation: String {
        let dir = coefficient > 0 ? "increases" : "decreases"
        return "When \(field1) goes up, \(field2) tends to \(dir == "increases" ? "go up" : "go down")."
    }
}

struct CorrelationInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Test",
            programType: "smoking"
        )

        CorrelationInsightsView(habit: habit)
            .environment(\.managedObjectContext, context)
            .padding()
            .background(Color.appBackground)
    }
}
