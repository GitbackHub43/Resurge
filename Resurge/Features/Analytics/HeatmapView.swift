import SwiftUI
import CoreData

struct HeatmapView: View {
    @ObservedObject var habit: CDHabit
    @Environment(\.managedObjectContext) private var viewContext

    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let timeSlots = ["Morning", "Afternoon", "Evening", "Night"]
    private let timeRanges: [(Int, Int)] = [(6, 12), (12, 17), (17, 21), (21, 6)]

    @State private var heatData: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 7)
    @State private var maxCount: Int = 1

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text("Activity Heatmap")
                .font(Typography.headline)
                .foregroundColor(.appText)

            Text("When cravings and events occur most frequently.")
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            // Column headers
            HStack(spacing: 4) {
                Text("")
                    .frame(width: 50)
                ForEach(timeSlots, id: \.self) { slot in
                    Text(slot)
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                        .frame(maxWidth: .infinity)
                }
            }

            // Heatmap grid
            ForEach(0..<7, id: \.self) { dayIndex in
                HStack(spacing: 4) {
                    Text(weekdays[dayIndex])
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                        .frame(width: 50, alignment: .leading)

                    ForEach(0..<4, id: \.self) { slotIndex in
                        let count = heatData[dayIndex][slotIndex]
                        RoundedRectangle(cornerRadius: 4)
                            .fill(heatColor(for: count))
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .overlay(
                                Text(count > 0 ? "\(count)" : "")
                                    .font(Typography.caption)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }

            // Legend
            HStack(spacing: 8) {
                Spacer()
                Text("Less")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.neonPurple.opacity(max(0.08, intensity)))
                        .frame(width: 16, height: 16)
                }
                Text("More")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
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
        .onAppear { loadData() }
    }

    private func heatColor(for count: Int) -> Color {
        guard maxCount > 0 else { return Color.neonPurple.opacity(0.08) }
        let intensity = Double(count) / Double(maxCount)
        if intensity == 0 {
            return Color.neonPurple.opacity(0.08)
        }
        return Color.neonPurple.opacity(0.2 + intensity * 0.8)
    }

    private func loadData() {
        guard let entries = habit.cravingEntries as? Set<CDCravingEntry> else { return }

        var grid = Array(repeating: Array(repeating: 0, count: 4), count: 7)
        let calendar = Calendar.current

        for entry in entries {
            let weekday = calendar.component(.weekday, from: entry.timestamp)
            // Convert Sunday=1..Saturday=7 to Monday=0..Sunday=6
            let dayIndex = (weekday + 5) % 7
            let hour = calendar.component(.hour, from: entry.timestamp)

            let slotIndex: Int
            if hour >= 6 && hour < 12 {
                slotIndex = 0
            } else if hour >= 12 && hour < 17 {
                slotIndex = 1
            } else if hour >= 17 && hour < 21 {
                slotIndex = 2
            } else {
                slotIndex = 3
            }

            grid[dayIndex][slotIndex] += 1
        }

        heatData = grid
        maxCount = max(grid.flatMap { $0 }.max() ?? 1, 1)
    }
}

struct HeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Test",
            programType: "smoking",
            startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        )

        HeatmapView(habit: habit)
            .environment(\.managedObjectContext, context)
            .padding()
            .background(Color.appBackground)
    }
}
