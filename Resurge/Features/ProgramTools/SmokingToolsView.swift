import SwiftUI
import CoreData
import Combine

// MARK: - Smoking Tools View

struct SmokingToolsView: View {
    let habit: CDHabit

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                NRTTrackerCard(habit: habit)
                CravingTimerCard()
                HealthProgressCard(habit: habit)
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Smoking Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - NRT Tracker

private enum NRTType: String, CaseIterable, Identifiable {
    case patch = "Patch"
    case gum = "Gum"
    case lozenge = "Lozenge"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .patch:   return "bandage.fill"
        case .gum:     return "mouth.fill"
        case .lozenge: return "pills.fill"
        }
    }
}

private struct NRTLogEntry: Identifiable {
    let id = UUID()
    let type: NRTType
    let timestamp: Date
}

private struct NRTTrackerCard: View {
    let habit: CDHabit
    @State private var selectedType: NRTType = .patch
    @State private var usageLog: [NRTLogEntry] = []
    @State private var todayCount: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Nicotine Replacement Tracker", systemImage: "pills.fill")
                .font(.headline)
                .foregroundColor(Color.neonCyan)

            Text("Select your NRT type and log each use.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            HStack(spacing: 12) {
                ForEach(NRTType.allCases) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.title2)
                            Text(type.rawValue)
                                .font(Font.caption.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedType == type ? Color.neonCyan.opacity(0.15) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedType == type ? Color.neonCyan : Color.gray.opacity(0.3), lineWidth: selectedType == type ? 2 : 1)
                        )
                        .foregroundColor(selectedType == type ? Color.neonCyan : Color.subtleText)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                let entry = NRTLogEntry(type: selectedType, timestamp: Date())
                withAnimation {
                    usageLog.insert(entry, at: 0)
                    todayCount += 1
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log \(selectedType.rawValue) Use")
                        .font(Font.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.neonCyan)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            if !usageLog.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today: \(todayCount) uses")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.neonOrange)

                    ForEach(usageLog.prefix(5)) { entry in
                        HStack {
                            Image(systemName: entry.type.icon)
                                .foregroundColor(Color.neonCyan)
                                .frame(width: 24)
                            Text(entry.type.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text(entry.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(Color.subtleText)
                        }
                        .padding(.vertical, 4)
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

// MARK: - Craving Timer

private struct CravingTimerCard: View {
    @State private var isRunning = false
    @State private var remainingSeconds: Int = 180
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
    @State private var timerCancellable: AnyCancellable?

    private let totalSeconds = 180

    var body: some View {
        VStack(spacing: 16) {
            Label("Craving Timer", systemImage: "timer")
                .font(.headline)
                .foregroundColor(Color.neonMagenta)

            Text("Most cravings pass within 3 minutes. Ride the wave.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: CGFloat(remainingSeconds) / CGFloat(totalSeconds))
                    .stroke(
                        remainingSeconds > 60 ? Color.neonOrange : Color.neonCyan,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: remainingSeconds)

                VStack(spacing: 4) {
                    if remainingSeconds > 0 {
                        Text(timeString(remainingSeconds))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Color.appText)
                        Text("Craving will pass")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color.neonCyan)
                        Text("You made it!")
                            .font(Font.subheadline.weight(.semibold))
                            .foregroundColor(Color.neonCyan)
                    }
                }
            }

            if isRunning {
                Button("Cancel") {
                    stopTimer()
                }
                .foregroundColor(Color.subtleText)
            } else {
                Button {
                    startTimer()
                } label: {
                    Text(remainingSeconds < totalSeconds && remainingSeconds > 0 ? "Resume" : (remainingSeconds == 0 ? "Start Again" : "Start Timer"))
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
        if remainingSeconds == 0 {
            remainingSeconds = totalSeconds
        }
        isRunning = true
        let pub = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timerCancellable = pub.sink { _ in
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
        timerCancellable = nil
    }
}

// MARK: - Health Progress Counter

private struct HealthProgressCard: View {
    let habit: CDHabit
    @State private var displayedDays: Int = 0
    @State private var animationTimer: AnyCancellable?

    private var targetDays: Int {
        habit.daysSoberCount
    }

    var body: some View {
        VStack(spacing: 16) {
            Label("Health Progress", systemImage: "heart.fill")
                .font(.headline)
                .foregroundColor(Color.neonGreen)

            Text("\(displayedDays)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(Color.neonGreen)
                .onAppear {
                    animateCounter()
                }

            Text("days smoke-free since \(habit.startDate, style: .date)")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            HStack(spacing: 20) {
                VStack {
                    Text("\(habit.currentStreak)")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Color.neonCyan)
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }

                Divider()
                    .frame(height: 40)

                VStack {
                    let hours = Int(habit.timeSavedMinutes / 60)
                    Text("\(hours)h")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Color.neonCyan)
                    Text("Life Reclaimed")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
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

    private func animateCounter() {
        let steps = min(40, targetDays)
        guard steps > 0 else { displayedDays = targetDays; return }
        var step = 0
        animationTimer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                step += 1
                if step >= steps {
                    displayedDays = targetDays
                    animationTimer?.cancel()
                } else {
                    displayedDays = Int(Double(targetDays) * Double(step) / Double(steps))
                }
            }
    }
}

// MARK: - Preview

struct SmokingToolsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Quit Smoking",
            programType: ProgramType.smoking.rawValue,
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            goalDays: 90,
            baselineCostPerDay: 12.50,
            baselineTimePerDay: 30
        )
        return NavigationView {
            SmokingToolsView(habit: habit)
        }
    }
}
