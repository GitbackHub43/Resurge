import SwiftUI
import Combine

// MARK: - Gaming Tools View

struct GamingToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Exit Plan").tag(0)
                    Text("Bedtime Lock").tag(1)
                    Text("Session Log").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: SessionExitPlanCard()
                case 1: BedtimeLockCard()
                default: SessionLogCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Gaming Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Session Exit Plan

private struct ExitStep: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    var completed: Bool = false
}

private struct SessionExitPlanCard: View {
    @State private var stopTimeHour: Int = 22
    @State private var stopTimeMinute: Int = 0
    @State private var alarmSet = false
    @State private var ritualSteps: [ExitStep] = [
        ExitStep(label: "Save your game progress", icon: "square.and.arrow.down.fill"),
        ExitStep(label: "Say goodbye to teammates", icon: "mic.fill"),
        ExitStep(label: "Close the game application", icon: "xmark.circle.fill"),
        ExitStep(label: "Turn off the monitor/console", icon: "power"),
        ExitStep(label: "Stand up and stretch for 2 minutes", icon: "figure.walk"),
        ExitStep(label: "Drink a glass of water", icon: "drop.fill"),
    ]
    @State private var planActive = false

    private var completedCount: Int {
        ritualSteps.filter(\.completed).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Session Exit Plan", systemImage: "door.left.hand.open")
                .font(.headline)
                .foregroundColor(Color.neonCyan)

            Text("Pre-commit to a stop time before you start playing. Then follow the exit ritual.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Stop time picker
            VStack(spacing: 12) {
                Text("I will stop playing at:")
                    .font(Font.subheadline.weight(.medium))

                HStack(spacing: 4) {
                    Picker("Hour", selection: $stopTimeHour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d", h)).tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 100)
                    .clipped()

                    Text(":")
                        .font(Font.title2.weight(.bold))

                    Picker("Minute", selection: $stopTimeMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text(String(format: "%02d", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 100)
                    .clipped()
                }

                Toggle(isOn: $alarmSet) {
                    HStack {
                        Image(systemName: "alarm.fill")
                            .foregroundColor(Color.neonOrange)
                        Text("Set alarm reminder")
                            .font(.subheadline)
                    }
                }
                .tint(Color.neonCyan)
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)

            // Activate plan
            Button {
                withAnimation { planActive.toggle() }
            } label: {
                HStack {
                    Image(systemName: planActive ? "checkmark.shield.fill" : "shield.fill")
                    Text(planActive ? "Plan Active" : "Activate Exit Plan")
                        .font(Font.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(planActive ? Color.neonCyan : Color.neonOrange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Exit ritual
            if planActive {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Exit Ritual")
                            .font(Font.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(completedCount)/\(ritualSteps.count)")
                            .font(.caption)
                            .foregroundColor(Color.neonCyan)
                    }

                    ForEach($ritualSteps) { $step in
                        Button {
                            withAnimation { step.completed.toggle() }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: step.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(step.completed ? Color.neonCyan : Color.gray.opacity(0.4))
                                Image(systemName: step.icon)
                                    .foregroundColor(Color.neonCyan)
                                    .frame(width: 24)
                                Text(step.label)
                                    .font(.subheadline)
                                    .foregroundColor(step.completed ? Color.subtleText : Color.appText)
                                    .strikethrough(step.completed)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
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

// MARK: - Bedtime Lock

private struct BedtimeLockCard: View {
    @State private var bedtimeHour: Int = 23
    @State private var bedtimeMinute: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var isActive = false
    @State private var timerCancellable: AnyCancellable?

    private var bedtimeDate: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = bedtimeHour
        components.minute = bedtimeMinute
        var date = calendar.date(from: components) ?? Date()
        if date < Date() {
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return date
    }

    private var urgencyColor: Color {
        if remainingSeconds < 1800 { return .red }
        if remainingSeconds < 3600 { return Color.neonOrange }
        return Color.neonCyan
    }

    private var urgencyMessage: String {
        if remainingSeconds < 900 { return "Time to stop NOW. Save and shut down." }
        if remainingSeconds < 1800 { return "Final warning. Start your exit ritual." }
        if remainingSeconds < 3600 { return "Bedtime is approaching. Wrap up soon." }
        return "You have time, but keep your commitment in mind."
    }

    var body: some View {
        VStack(spacing: 16) {
            Label("Bedtime Lock Reminder", systemImage: "moon.zzz.fill")
                .font(.headline)
                .foregroundColor(Color.neonPurple)

            if isActive {
                VStack(spacing: 12) {
                    Text("Time until bedtime")
                        .font(.subheadline)
                        .foregroundColor(Color.subtleText)

                    Text(formatTime(remainingSeconds))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(urgencyColor)
                        .animation(.easeInOut(duration: 0.5), value: urgencyColor)

                    Text(urgencyMessage)
                        .font(.subheadline)
                        .foregroundColor(urgencyColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(urgencyColor.opacity(0.1))
                        .cornerRadius(12)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.15))
                            RoundedRectangle(cornerRadius: 6)
                                .fill(urgencyColor)
                                .frame(width: geo.size.width * min(1 - CGFloat(remainingSeconds) / CGFloat(max(bedtimeHour * 3600 - 8 * 3600, 3600)), 1.0))
                        }
                    }
                    .frame(height: 8)

                    Button("Deactivate") {
                        isActive = false
                        timerCancellable?.cancel()
                    }
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                }
            } else {
                Text("Set your target bedtime. The countdown will warn you as it approaches.")
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Picker("Hour", selection: $bedtimeHour) {
                        ForEach(20..<28, id: \.self) { h in
                            Text(String(format: "%02d", h % 24)).tag(h % 24)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 100)
                    .clipped()

                    Text(":")
                        .font(Font.title2.weight(.bold))

                    Picker("Minute", selection: $bedtimeMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text(String(format: "%02d", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 100)
                    .clipped()
                }

                Button {
                    startCountdown()
                } label: {
                    HStack {
                        Image(systemName: "moon.fill")
                        Text("Start Bedtime Countdown")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
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

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    private func startCountdown() {
        remainingSeconds = max(Int(bedtimeDate.timeIntervalSince(Date())), 0)
        isActive = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    timerCancellable?.cancel()
                }
            }
    }
}

// MARK: - Session Log

private struct GamingSession: Identifiable {
    let id = UUID()
    let date: Date
    var duration: Int // minutes
    var feeling: Int // 1-5
    var game: String
}

private struct SessionLogCard: View {
    @State private var sessions: [GamingSession] = [
        GamingSession(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), duration: 90, feeling: 3, game: "Valorant"),
        GamingSession(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), duration: 180, feeling: 2, game: "Elden Ring"),
        GamingSession(date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), duration: 60, feeling: 4, game: "Mario Kart"),
    ]
    @State private var newGame = ""
    @State private var newDuration: Int = 60
    @State private var newFeeling: Int = 3
    @State private var showAddForm = false

    private let feelingEmojis = ["1": "Regretful", "2": "Meh", "3": "Okay", "4": "Good", "5": "Great"]

    private var totalHoursThisWeek: Double {
        Double(sessions.reduce(0) { $0 + $1.duration }) / 60.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Session Log", systemImage: "gamecontroller.fill")
                    .font(.headline)
                    .foregroundColor(Color.neonBlue)
                Spacer()
                Text(String(format: "%.1fh this week", totalHoursThisWeek))
                    .font(Font.caption.weight(.bold))
                    .foregroundColor(Color.neonOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.neonOrange.opacity(0.15))
                    .cornerRadius(8)
            }

            Button {
                withAnimation { showAddForm.toggle() }
            } label: {
                HStack {
                    Image(systemName: showAddForm ? "chevron.up" : "plus.circle.fill")
                    Text(showAddForm ? "Hide Form" : "Log a Session")
                        .font(Font.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.neonCyan)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            if showAddForm {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "gamecontroller")
                            .foregroundColor(Color.neonCyan)
                        TextField("Game name", text: $newGame)
                            .font(.subheadline)
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)

                    Stepper("Duration: \(newDuration) min", value: $newDuration, in: 15...480, step: 15)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color.appBackground)
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("How did you feel after?")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                        HStack {
                            ForEach(1...5, id: \.self) { value in
                                Button {
                                    newFeeling = value
                                } label: {
                                    VStack(spacing: 2) {
                                        Image(systemName: value <= newFeeling ? "star.fill" : "star")
                                            .foregroundColor(value <= newFeeling ? Color.neonGold : Color.gray.opacity(0.3))
                                        Text(feelingEmojis["\(value)"] ?? "")
                                            .font(.system(size: 8))
                                            .foregroundColor(Color.subtleText)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)

                    Button {
                        guard !newGame.isEmpty else { return }
                        let session = GamingSession(date: Date(), duration: newDuration, feeling: newFeeling, game: newGame)
                        withAnimation {
                            sessions.insert(session, at: 0)
                            newGame = ""
                            newDuration = 60
                            newFeeling = 3
                            showAddForm = false
                        }
                    } label: {
                        Text("Save Session")
                            .font(Font.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(newGame.isEmpty ? Color.gray.opacity(0.3) : Color.neonOrange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(newGame.isEmpty)
                }
                .padding()
                .background(Color.neonCyan.opacity(0.05))
                .cornerRadius(12)
            }

            // Session list
            ForEach(sessions) { session in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.game)
                            .font(Font.subheadline.weight(.medium))
                        Text(session.date, style: .date)
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(session.duration) min")
                            .font(.subheadline)
                            .foregroundColor(session.duration > 120 ? Color.neonOrange : Color.neonCyan)
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= session.feeling ? "star.fill" : "star")
                                    .font(.system(size: 8))
                                    .foregroundColor(i <= session.feeling ? Color.neonGold : Color.gray.opacity(0.3))
                            }
                        }
                    }
                }
                .padding()
                .background(Color.appBackground)
                .cornerRadius(10)
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

struct GamingToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GamingToolsView()
        }
    }
}
