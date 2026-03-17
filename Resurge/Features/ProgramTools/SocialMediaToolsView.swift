import SwiftUI
import Combine

// MARK: - Social Media Tools View

struct SocialMediaToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Post & Leave").tag(0)
                    Text("Cooldown").tag(1)
                    Text("Budget").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: PostAndLeaveCard()
                case 1: CheckCooldownCard()
                default: WeeklyBudgetCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Social Media Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Post and Leave Ritual

private struct RitualStep: Identifiable {
    let id = UUID()
    let order: Int
    let label: String
    let icon: String
    var completed: Bool = false
}

private struct PostAndLeaveCard: View {
    @State private var steps: [RitualStep] = [
        RitualStep(order: 1, label: "Compose your post or reply", icon: "square.and.pencil"),
        RitualStep(order: 2, label: "Review it once (no scrolling)", icon: "eye"),
        RitualStep(order: 3, label: "Post it", icon: "paperplane.fill"),
        RitualStep(order: 4, label: "Close the app immediately", icon: "xmark.circle.fill"),
        RitualStep(order: 5, label: "Put your phone down", icon: "iphone.slash"),
    ]
    @State private var ritualComplete = false

    private var completedCount: Int {
        steps.filter(\.completed).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Post-and-Leave Ritual", systemImage: "list.bullet.rectangle.portrait.fill")
                    .font(.headline)
                    .foregroundColor(Color.neonCyan)
                Spacer()
                Text("\(completedCount)/\(steps.count)")
                    .font(Font.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.neonCyan.opacity(0.15))
                    .foregroundColor(Color.neonCyan)
                    .cornerRadius(8)
            }

            Text("Social media is a tool, not a destination. Post with purpose and leave.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            if ritualComplete {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.neonCyan)
                    Text("Ritual complete. You stayed in control.")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.neonCyan)
                    Button("Start New Ritual") {
                        withAnimation {
                            for i in steps.indices { steps[i].completed = false }
                            ritualComplete = false
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    let canTap = index == 0 || steps[index - 1].completed

                    Button {
                        guard canTap else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            steps[index].completed.toggle()
                            if completedCount == steps.count {
                                ritualComplete = true
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(step.completed ? Color.neonCyan : (canTap ? Color.neonOrange.opacity(0.2) : Color.gray.opacity(0.1)))
                                    .frame(width: 32, height: 32)

                                if step.completed {
                                    Image(systemName: "checkmark")
                                        .font(Font.caption.weight(.bold))
                                        .foregroundColor(.white)
                                } else {
                                    Text("\(step.order)")
                                        .font(Font.caption.weight(.bold))
                                        .foregroundColor(canTap ? Color.neonOrange : Color.subtleText)
                                }
                            }

                            Image(systemName: step.icon)
                                .foregroundColor(step.completed ? Color.neonCyan : Color.subtleText)
                                .frame(width: 24)

                            Text(step.label)
                                .font(.subheadline)
                                .foregroundColor(step.completed ? Color.subtleText : Color.appText)
                                .strikethrough(step.completed)
                        }
                        .padding(.vertical, 6)
                        .opacity(canTap || step.completed ? 1 : 0.5)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canTap && !step.completed)
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

// MARK: - Check Cooldown Timer

private struct CheckCooldownCard: View {
    @State private var cooldownMinutes: Int = 60
    @State private var remainingSeconds: Int = 0
    @State private var isActive = false
    @State private var timerCancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 16) {
            Label("Check Cooldown Timer", systemImage: "hourglass")
                .font(.headline)
                .foregroundColor(Color.neonMagenta)

            if isActive {
                Text("Next check allowed in")
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 180, height: 180)

                    Circle()
                        .trim(from: 0, to: CGFloat(remainingSeconds) / CGFloat(cooldownMinutes * 60))
                        .stroke(Color.neonOrange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: remainingSeconds)

                    VStack(spacing: 4) {
                        Text(formatTime(remainingSeconds))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color.neonOrange)
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    }
                }

                if remainingSeconds == 0 {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color.neonCyan)
                        Text("You may check social media now. Be intentional.")
                            .font(.subheadline)
                            .foregroundColor(Color.neonCyan)
                            .multilineTextAlignment(.center)

                        Button("Start Another Cooldown") {
                            startCooldown()
                        }
                        .font(.subheadline)
                        .foregroundColor(Color.neonOrange)
                    }
                } else {
                    Button("Cancel Cooldown") {
                        cancelCooldown()
                    }
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                }
            } else {
                Text("Set a cooldown between social media checks. Train yourself to check less often.")
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Text("Cooldown Duration")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)

                    HStack(spacing: 12) {
                        ForEach([30, 60, 90, 120], id: \.self) { minutes in
                            Button {
                                cooldownMinutes = minutes
                            } label: {
                                Text("\(minutes)m")
                                    .font(Font.subheadline.weight(cooldownMinutes == minutes ? .bold : .regular))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(cooldownMinutes == minutes ? Color.neonOrange.opacity(0.15) : Color.appBackground)
                                    .foregroundColor(cooldownMinutes == minutes ? Color.neonOrange : Color.subtleText)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(cooldownMinutes == minutes ? Color.neonOrange : Color.clear, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    startCooldown()
                } label: {
                    HStack {
                        Image(systemName: "timer")
                        Text("Start Cooldown")
                            .font(Font.body.weight(.semibold))
                    }
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

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    private func startCooldown() {
        remainingSeconds = cooldownMinutes * 60
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

    private func cancelCooldown() {
        isActive = false
        timerCancellable?.cancel()
        remainingSeconds = 0
    }
}

// MARK: - Weekly Budget Tracker

private struct WeeklyBudgetCard: View {
    @State private var weeklyBudget: Int = 7
    @State private var checksUsed: Int = 3
    @State private var showEditor = false

    private var remaining: Int {
        max(weeklyBudget - checksUsed, 0)
    }

    private var usagePercent: CGFloat {
        guard weeklyBudget > 0 else { return 0 }
        return CGFloat(checksUsed) / CGFloat(weeklyBudget)
    }

    var body: some View {
        VStack(spacing: 16) {
            Label("Weekly Check-in Budget", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            Text("Limit how many times you check social media per week.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)

            // Visual budget
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(0..<weeklyBudget, id: \.self) { index in
                        Circle()
                            .fill(index < checksUsed ? Color.neonOrange : Color.neonCyan.opacity(0.3))
                            .frame(width: 20, height: 20)
                            .overlay(
                                index < checksUsed ?
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                    : nil
                            )
                    }
                }

                Text("\(remaining) checks remaining this week")
                    .font(Font.subheadline.weight(.medium))
                    .foregroundColor(remaining > 0 ? Color.neonCyan : Color.neonOrange)
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(usagePercent > 0.8 ? Color.neonOrange : Color.neonCyan)
                            .frame(width: geo.size.width * min(usagePercent, 1.0), height: 12)
                            .animation(.easeInOut(duration: 0.3), value: checksUsed)
                    }
                }
                .frame(height: 12)

                HStack {
                    Text("\(checksUsed) used")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                    Spacer()
                    Text("\(weeklyBudget) budget")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
            }

            HStack(spacing: 12) {
                Button {
                    if checksUsed < weeklyBudget {
                        withAnimation { checksUsed += 1 }
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Check")
                    }
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(remaining > 0 ? Color.neonCyan : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(remaining == 0)

                Button {
                    withAnimation { checksUsed = 0 }
                } label: {
                    Text("Reset")
                        .font(Font.body.weight(.semibold))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(Color.appBackground)
                        .foregroundColor(Color.subtleText)
                        .cornerRadius(12)
                }
            }

            Button {
                showEditor.toggle()
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Adjust Weekly Budget")
                        .font(.subheadline)
                }
                .foregroundColor(Color.neonCyan)
            }

            if showEditor {
                Stepper("Budget: \(weeklyBudget) checks/week", value: $weeklyBudget, in: 1...21, step: 1)
                    .font(.subheadline)
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

struct SocialMediaToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SocialMediaToolsView()
        }
    }
}
