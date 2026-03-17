import SwiftUI

struct EmergencyModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showResisted = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Emergency Mode")
                        .font(Typography.title)
                        .foregroundColor(.textPrimary)
                        .rainbowText()
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.top, 16)

                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        EmergencyTab(title: "Breathe", icon: "wind", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        EmergencyTab(title: "Timer", icon: "timer", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        EmergencyTab(title: "Tools", icon: "square.grid.2x2.fill", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                        EmergencyTab(title: "Quotes", icon: "quote.opening", isSelected: selectedTab == 3) {
                            selectedTab = 3
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                }
                .padding(.vertical, 16)

                // Content
                TabView(selection: $selectedTab) {
                    BreathingExerciseSection()
                        .tag(0)
                    RideTheWaveSection()
                        .tag(1)
                    QuickToolsSection()
                        .tag(2)
                    MotivationalQuoteSection()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // "I Resisted!" Button
                Button {
                    HapticManager.resisted()
                    showResisted = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                        Text("I Resisted!")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, 32)
            }

            // Success Overlay
            if showResisted {
                resistedOverlay
            }
        }
    }

    private var resistedOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.neonGreen)
                    .shadow(color: .neonGreen.opacity(0.6), radius: 20)
                Text("You did it!")
                    .font(Typography.title)
                    .foregroundColor(.textPrimary)
                Text("Every craving you resist makes you stronger.")
                    .font(Typography.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Emergency Tab Button

private struct EmergencyTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(Typography.caption)
            }
            .foregroundColor(isSelected ? .neonCyan : .textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.neonCyan.opacity(0.15) : Color.cardBackground)
            .cornerRadius(AppStyle.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                    .stroke(isSelected ? Color.neonCyan.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Breathing Exercise

private struct BreathingExerciseSection: View {
    @State private var isExpanded = false
    @State private var breathText = "Breathe in..."

    private let expandDuration: Double = 4.0
    private let contractDuration: Double = 4.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(breathText)
                .font(Typography.headline)
                .foregroundColor(.neonCyan)

            ZStack {
                Circle()
                    .fill(Color.neonCyan.opacity(0.08))
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(Color.neonCyan.opacity(0.15))
                    .frame(width: isExpanded ? 180 : 80, height: isExpanded ? 180 : 80)
                    .shadow(color: .neonCyan.opacity(0.4), radius: isExpanded ? 30 : 10)

                Circle()
                    .stroke(Color.neonCyan.opacity(0.3), lineWidth: 2)
                    .frame(width: isExpanded ? 200 : 100, height: isExpanded ? 200 : 100)
            }
            .animation(.easeInOut(duration: expandDuration), value: isExpanded)

            Text("Follow the circle. Inhale as it expands, exhale as it contracts.")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .onAppear {
            startBreathingCycle()
        }
    }

    private func startBreathingCycle() {
        breathText = "Breathe in..."
        isExpanded = true
        DispatchQueue.main.asyncAfter(deadline: .now() + expandDuration) {
            breathText = "Breathe out..."
            isExpanded = false
            DispatchQueue.main.asyncAfter(deadline: .now() + contractDuration) {
                startBreathingCycle()
            }
        }
    }
}

// MARK: - Ride the Wave Timer

private struct RideTheWaveSection: View {
    @State private var timeRemaining: Int = 300 // 5 minutes
    @State private var timerActive = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Ride the Wave")
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text("Most cravings pass in 3-5 minutes.")
                .font(Typography.body)
                .foregroundColor(.textSecondary)

            Text(timeString)
                .font(Typography.timer)
                .foregroundColor(.neonCyan)
                .shadow(color: .neonCyan.opacity(0.4), radius: 10)

            HStack(spacing: 20) {
                Button {
                    if timerActive {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                } label: {
                    HStack {
                        Image(systemName: timerActive ? "pause.fill" : "play.fill")
                        Text(timerActive ? "Pause" : "Start")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(color: .neonCyan))

                Button {
                    resetTimer()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonCyan))
            }
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()
        }
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startTimer() {
        timerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                pauseTimer()
                HapticManager.achievement()
            }
        }
    }

    private func pauseTimer() {
        timerActive = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        pauseTimer()
        timeRemaining = 300
    }
}

// MARK: - Quick Tools Grid

private struct QuickToolsSection: View {
    private let tools: [(String, String, Color)] = [
        ("Breathing", "wind", .neonCyan),
        ("Distraction", "puzzlepiece.fill", .neonMagenta),
        ("Journal", "book.fill", .neonPurple),
        ("Call Someone", "phone.fill", .neonGreen)
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Quick Tools")
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .padding(.top, 16)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(0..<tools.count, id: \.self) { index in
                    let tool = tools[index]
                    QuickToolCard(title: tool.0, icon: tool.1, color: tool.2)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()
        }
    }
}

private struct QuickToolCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.4), radius: 8)

            Text(title)
                .font(Typography.headline)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .neonCard(glow: color)
    }
}

// MARK: - Motivational Quote

private struct MotivationalQuoteSection: View {
    @State private var currentQuote: Quote

    init() {
        _currentQuote = State(initialValue: QuoteBank.randomQuote())
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "quote.opening")
                .font(.system(size: 40))
                .foregroundColor(.neonGold.opacity(0.6))

            VStack(spacing: 12) {
                Text(currentQuote.text)
                    .font(Typography.title)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("— \(currentQuote.author)")
                    .font(Typography.callout)
                    .foregroundColor(.textSecondary)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    var newQuote = QuoteBank.randomQuote()
                    while newQuote.id == currentQuote.id {
                        newQuote = QuoteBank.randomQuote()
                    }
                    currentQuote = newQuote
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("New Quote")
                }
            }
            .buttonStyle(SecondaryButtonStyle(color: .neonGold))
            .padding(.horizontal, 60)

            Spacer()
        }
    }
}

// MARK: - Preview

struct EmergencyModeView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyModeView()
            .preferredColorScheme(.dark)
    }
}
