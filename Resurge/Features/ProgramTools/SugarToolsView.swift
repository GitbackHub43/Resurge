import SwiftUI
import Combine

// MARK: - Sugar Tools View

struct SugarToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Substitutes").tag(0)
                    Text("Delay Timer").tag(1)
                    Text("Energy Log").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: SubstitutionListCard()
                case 1: CravingDelayTimerCard()
                default: EnergyCrashLogCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Sugar Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Substitution List

private enum CravingCategory: String, CaseIterable, Identifiable {
    case sweet = "Sweet"
    case crunchy = "Crunchy"
    case creamy = "Creamy"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sweet:   return "leaf.fill"
        case .crunchy: return "waveform"
        case .creamy:  return "drop.fill"
        }
    }

    var color: Color {
        switch self {
        case .sweet:   return Color.neonMagenta
        case .crunchy: return Color.neonBlue
        case .creamy:  return Color.neonGold
        }
    }

    var alternatives: [(name: String, detail: String)] {
        switch self {
        case .sweet:
            return [
                ("Fresh berries", "Naturally sweet, full of antioxidants"),
                ("Frozen grapes", "Feels like candy, takes time to eat"),
                ("Dates with almond butter", "Rich sweetness with healthy fats"),
                ("Dark chocolate (85%+)", "Small square satisfies without the spike"),
                ("Cinnamon herbal tea", "Warm, sweet flavor without sugar"),
                ("Apple slices with cinnamon", "Crunchy and naturally sweet"),
            ]
        case .crunchy:
            return [
                ("Raw almonds", "Satisfying crunch with protein"),
                ("Carrot and celery sticks", "Low calorie, high crunch"),
                ("Rice cakes with hummus", "Light crunch with savory flavor"),
                ("Roasted chickpeas", "Protein-packed crunchy snack"),
                ("Cucumber slices with salt", "Refreshing and crunchy"),
                ("Air-popped popcorn", "Whole grain, satisfying volume"),
            ]
        case .creamy:
            return [
                ("Greek yogurt (plain)", "High protein, satisfying texture"),
                ("Avocado on toast", "Healthy fats, creamy satisfaction"),
                ("Banana ice cream", "Blend frozen bananas - naturally creamy"),
                ("Cottage cheese with berries", "Protein-rich and creamy"),
                ("Chia pudding", "Make ahead, creamy and filling"),
                ("Nut butter on celery", "Classic combo, healthy fats"),
            ]
        }
    }
}

private struct SubstitutionListCard: View {
    @State private var selectedCategory: CravingCategory = .sweet

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Healthy Substitutions", systemImage: "arrow.triangle.swap")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            Text("What kind of craving are you having?")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Category selector
            HStack(spacing: 10) {
                ForEach(CravingCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.title3)
                            Text(category.rawValue)
                                .font(Font.caption.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCategory == category ? category.color.opacity(0.15) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedCategory == category ? category.color : Color.gray.opacity(0.3), lineWidth: selectedCategory == category ? 2 : 1)
                        )
                        .foregroundColor(selectedCategory == category ? category.color : Color.subtleText)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Alternatives list
            ForEach(Array(selectedCategory.alternatives.enumerated()), id: \.offset) { index, alt in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(selectedCategory.color.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text("\(index + 1)")
                            .font(Font.caption.weight(.bold))
                            .foregroundColor(selectedCategory.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(alt.name)
                            .font(Font.subheadline.weight(.medium))
                        Text(alt.detail)
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    }
                }
                .padding(.vertical, 4)
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

// MARK: - Craving Delay Timer

private struct CravingDelayTimerCard: View {
    @State private var remainingSeconds: Int = 900
    @State private var isRunning = false
    @State private var timerCancellable: AnyCancellable?

    private let totalSeconds = 900 // 15 minutes

    private var delayTips: [String] {
        [
            "Drink a full glass of water",
            "Go for a short walk",
            "Brush your teeth",
            "Chew sugar-free gum",
            "Do 10 deep breaths",
        ]
    }

    var body: some View {
        VStack(spacing: 16) {
            Label("15-Minute Craving Delay", systemImage: "timer")
                .font(.headline)
                .foregroundColor(Color.neonOrange)

            Text("Most sugar cravings fade within 15 minutes. Delay, do not deny.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 10)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: CGFloat(remainingSeconds) / CGFloat(totalSeconds))
                    .stroke(
                        remainingSeconds > 300 ? Color.neonOrange : Color.neonCyan,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: remainingSeconds)

                VStack(spacing: 4) {
                    if remainingSeconds > 0 {
                        Text(timeString(remainingSeconds))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(remainingSeconds > 300 ? Color.neonOrange : Color.neonCyan)
                        Text("Stay strong")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color.neonCyan)
                        Text("Craving passed!")
                            .font(Font.subheadline.weight(.semibold))
                            .foregroundColor(Color.neonCyan)
                    }
                }
            }

            if isRunning {
                // Show tips while waiting
                VStack(alignment: .leading, spacing: 8) {
                    Text("While you wait:")
                        .font(Font.caption.weight(.semibold))
                        .foregroundColor(Color.neonCyan)

                    ForEach(delayTips, id: \.self) { tip in
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle")
                                .font(.caption)
                                .foregroundColor(Color.neonCyan)
                            Text(tip)
                                .font(.caption)
                                .foregroundColor(Color.subtleText)
                        }
                    }
                }
                .padding()
                .background(Color.neonCyan.opacity(0.05))
                .cornerRadius(12)

                Button("Cancel Timer") {
                    stopTimer()
                }
                .font(.caption)
                .foregroundColor(Color.subtleText)
            } else {
                Button {
                    startTimer()
                } label: {
                    Text(remainingSeconds == 0 ? "Start Again" : "Start 15-Min Delay")
                        .font(Font.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonOrange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
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
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        if remainingSeconds == 0 { remainingSeconds = totalSeconds }
        isRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    stopTimer()
                }
            }
    }

    private func stopTimer() {
        isRunning = false
        timerCancellable?.cancel()
    }
}

// MARK: - Energy Crash Log

private struct EnergyEntry: Identifiable {
    let id = UUID()
    let time: Date
    var level: Int // 1-5
    var note: String
}

private struct EnergyCrashLogCard: View {
    @State private var entries: [EnergyEntry] = [
        EnergyEntry(time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(), level: 4, note: "Good morning energy"),
        EnergyEntry(time: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date()) ?? Date(), level: 3, note: "Slight dip after coffee wore off"),
        EnergyEntry(time: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date(), level: 2, note: "Post-lunch crash"),
    ]
    @State private var newLevel: Int = 3
    @State private var newNote = ""

    private let levelLabels = ["Very Low", "Low", "Moderate", "Good", "Great"]
    private let levelColors: [Color] = [.red, Color.neonOrange, Color.neonGold, Color.neonCyan, .green]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Energy Crash Log", systemImage: "bolt.heart.fill")
                .font(.headline)
                .foregroundColor(Color.neonPurple)

            Text("Track your energy to spot sugar crash patterns.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Energy level selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Energy Level")
                    .font(Font.caption.weight(.medium))
                    .foregroundColor(Color.subtleText)

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { level in
                        Button {
                            newLevel = level
                        } label: {
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(level <= newLevel ? levelColors[newLevel - 1] : Color.gray.opacity(0.15))
                                    .frame(height: CGFloat(level) * 10 + 10)
                                Text("\(level)")
                                    .font(.caption2)
                                    .foregroundColor(Color.subtleText)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 70, alignment: .bottom)

                Text(levelLabels[newLevel - 1])
                    .font(Font.caption.weight(.medium))
                    .foregroundColor(levelColors[newLevel - 1])
                    .frame(maxWidth: .infinity)
            }

            HStack {
                TextField("Note (optional)", text: $newNote)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)
            }

            Button {
                let entry = EnergyEntry(time: Date(), level: newLevel, note: newNote.isEmpty ? levelLabels[newLevel - 1] : newNote)
                withAnimation {
                    entries.append(entry)
                    newNote = ""
                    newLevel = 3
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log Energy Level")
                        .font(Font.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.neonCyan)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Timeline
            if !entries.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Energy Timeline")
                        .font(Font.subheadline.weight(.semibold))

                    // Simple bar chart
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(entries) { entry in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(levelColors[entry.level - 1])
                                    .frame(width: 24, height: CGFloat(entry.level) * 16)

                                Text(entry.time, style: .time)
                                    .font(.system(size: 7))
                                    .foregroundColor(Color.subtleText)
                            }
                        }
                        Spacer()
                    }
                    .frame(height: 100, alignment: .bottom)
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(12)

                    // Entries list
                    ForEach(entries.reversed()) { entry in
                        HStack {
                            Circle()
                                .fill(levelColors[entry.level - 1])
                                .frame(width: 10, height: 10)
                            Text(entry.time, style: .time)
                                .font(.caption)
                                .foregroundColor(Color.subtleText)
                                .frame(width: 60, alignment: .leading)
                            Text(entry.note)
                                .font(.caption)
                                .foregroundColor(Color.appText)
                            Spacer()
                            Text("Lv.\(entry.level)")
                                .font(Font.caption.weight(.bold))
                                .foregroundColor(levelColors[entry.level - 1])
                        }
                        .padding(.vertical, 2)
                    }
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
    }
}

// MARK: - Preview

struct SugarToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SugarToolsView()
        }
    }
}
