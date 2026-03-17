import SwiftUI
import Combine

// MARK: - Phone Tools View

struct PhoneToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Scroll Interrupt").tag(0)
                    Text("Sessions").tag(1)
                    Text("Pickups").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: ScrollInterruptCard()
                case 1: SessionTrackerCard()
                default: PickupCounterCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Phone Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Scroll Interrupt

private struct ScrollInterruptCard: View {
    @State private var phase: InterruptPhase = .ready
    @State private var remainingSeconds: Int = 60
    @State private var timerCancellable: AnyCancellable?

    private enum InterruptPhase {
        case ready, counting, asking, decided
    }

    var body: some View {
        VStack(spacing: 20) {
            switch phase {
            case .ready:
                readyView
            case .counting:
                countingView
            case .asking:
                askingView
            case .decided:
                decidedView
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

    private var readyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.neonOrange)

            Text("Scroll Interrupt")
                .font(Font.title2.weight(.bold))
                .foregroundColor(Color.appText)

            Text("About to pick up your phone mindlessly? Pause for 60 seconds first.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)

            Button {
                withAnimation { phase = .counting }
                startTimer()
            } label: {
                Text("Start 60-Second Pause")
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.neonOrange)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
        }
    }

    private var countingView: some View {
        VStack(spacing: 20) {
            Text("Wait")
                .font(Font.title3.weight(.medium))
                .foregroundColor(Color.subtleText)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: CGFloat(remainingSeconds) / 60.0)
                    .stroke(Color.neonOrange, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: remainingSeconds)

                Text("\(remainingSeconds)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(Color.neonOrange)
            }

            Text("Take a breath. Is this really what you want to do right now?")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)
        }
    }

    private var askingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.neonCyan)

            Text("Do you still want to pick up your phone?")
                .font(Font.title3.weight(.semibold))
                .foregroundColor(Color.appText)
                .multilineTextAlignment(.center)

            Text("You waited 60 seconds. Be honest with yourself.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button {
                    withAnimation { phase = .decided }
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("No, I will do something else")
                    }
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Button {
                    withAnimation { phase = .ready }
                    remainingSeconds = 60
                } label: {
                    Text("Yes, I have a purpose")
                        .font(.subheadline)
                        .foregroundColor(Color.subtleText)
                        .padding(.vertical, 8)
                }
            }
        }
    }

    private var decidedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(Color.neonGold)

            Text("Great choice!")
                .font(Font.title2.weight(.bold))
                .foregroundColor(Color.neonCyan)

            Text("You just broke the autopilot loop. That takes real strength.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)

            Button {
                withAnimation {
                    phase = .ready
                    remainingSeconds = 60
                }
            } label: {
                Text("Done")
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }

    private func startTimer() {
        remainingSeconds = 60
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    timerCancellable?.cancel()
                    withAnimation { phase = .asking }
                }
            }
    }
}

// MARK: - Session Tracker

private struct PhoneFreeSession: Identifiable {
    let id = UUID()
    let startTime: Date
    var duration: Int // minutes
}

private struct SessionTrackerCard: View {
    @State private var sessions: [PhoneFreeSession] = [
        PhoneFreeSession(startTime: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(), duration: 45),
        PhoneFreeSession(startTime: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(), duration: 120),
    ]
    @State private var isTracking = false
    @State private var elapsedMinutes = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var sessionStart: Date = Date()

    private var totalMinutesToday: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Phone-Free Sessions", systemImage: "iphone.slash")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            // Today summary
            HStack {
                VStack {
                    Text("\(sessions.count)")
                        .font(Font.title.weight(.bold))
                        .foregroundColor(Color.neonCyan)
                    Text("Sessions")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 40)

                VStack {
                    Text(formatDuration(totalMinutesToday))
                        .font(Font.title.weight(.bold))
                        .foregroundColor(Color.neonGold)
                    Text("Total Free")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)

            // Active session
            if isTracking {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current Session")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                        Text("\(elapsedMinutes) min")
                            .font(Font.title2.weight(.bold))
                            .foregroundColor(Color.neonCyan)
                    }
                    Spacer()
                    Button {
                        stopSession()
                    } label: {
                        Text("End Session")
                            .font(Font.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.neonOrange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.neonCyan.opacity(0.1))
                .cornerRadius(12)
            } else {
                Button {
                    startSession()
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Start Phone-Free Session")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }

            // Session log
            if !sessions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Sessions")
                        .font(Font.subheadline.weight(.semibold))

                    ForEach(sessions.prefix(5)) { session in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.neonCyan)
                            Text(session.startTime, style: .time)
                                .font(.subheadline)
                            Spacer()
                            Text("\(session.duration) min")
                                .font(.subheadline)
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

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes)m"
    }

    private func startSession() {
        isTracking = true
        elapsedMinutes = 0
        sessionStart = Date()
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                elapsedMinutes += 1
            }
    }

    private func stopSession() {
        isTracking = false
        timerCancellable?.cancel()
        let session = PhoneFreeSession(startTime: sessionStart, duration: max(elapsedMinutes, 1))
        withAnimation {
            sessions.insert(session, at: 0)
        }
    }
}

// MARK: - Pickup Counter

private struct PickupCounterCard: View {
    @State private var pickupCount: Int = 0
    @State private var dailyGoal: Int = 30
    @State private var showGoalEditor = false

    var body: some View {
        VStack(spacing: 16) {
            Label("Daily Pickup Counter", systemImage: "hand.tap.fill")
                .font(.headline)
                .foregroundColor(Color.neonMagenta)

            Text("Tap each time you pick up your phone. Awareness is the first step.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)
                .multilineTextAlignment(.center)

            // Counter display
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: min(CGFloat(pickupCount) / CGFloat(dailyGoal), 1.0))
                    .stroke(
                        pickupCount <= dailyGoal ? Color.neonCyan : Color.neonOrange,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: pickupCount)

                VStack(spacing: 4) {
                    Text("\(pickupCount)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(pickupCount <= dailyGoal ? Color.neonCyan : Color.neonOrange)
                    Text("of \(dailyGoal) goal")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
            }

            HStack(spacing: 16) {
                Button {
                    withAnimation(.spring(response: 0.2)) {
                        pickupCount += 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Pickup")
                    }
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonOrange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Button {
                    if pickupCount > 0 {
                        withAnimation { pickupCount -= 1 }
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(Font.body.weight(.semibold))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(Color.appBackground)
                        .foregroundColor(Color.subtleText)
                        .cornerRadius(12)
                }
            }

            // Goal setter
            VStack(spacing: 8) {
                Button {
                    showGoalEditor.toggle()
                } label: {
                    HStack {
                        Image(systemName: "target")
                        Text("Set Daily Goal")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color.neonCyan)
                }

                if showGoalEditor {
                    Stepper("Goal: \(dailyGoal) pickups", value: $dailyGoal, in: 5...100, step: 5)
                        .font(.subheadline)
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(10)
                }
            }

            Button {
                withAnimation { pickupCount = 0 }
            } label: {
                Text("Reset Counter")
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
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

struct PhoneToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhoneToolsView()
        }
    }
}
