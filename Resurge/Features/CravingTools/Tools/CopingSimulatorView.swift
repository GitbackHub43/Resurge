import SwiftUI
import CoreData

struct CopingSimulatorView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - State

    @State private var currentScenario: Int = 0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var selectedChoice: Int? = nil
    @State private var showOutcome: Bool = false
    @State private var totalXP: Int = 0
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    private let scenarios: [Scenario] = [
        Scenario(
            situation: "You\u{2019}re stressed after a bad day at work. The urge hits hard.",
            choices: [
                Choice(text: "Leave the situation and take a walk", isHealthy: true, outcome: "Stepping away breaks the cycle. Fresh air and movement lower cortisol and let the urge pass naturally."),
                Choice(text: "Give in \u{2014} you\u{2019}ve earned it", isHealthy: false, outcome: "Giving in feels good for a moment but reinforces the stress-craving loop. Tomorrow will be harder."),
                Choice(text: "Call a friend and talk it through", isHealthy: true, outcome: "Connection is a powerful antidote. Talking it out reduces the urge intensity by half.")
            ]
        ),
        Scenario(
            situation: "You\u{2019}re at a social event. Everyone around you is indulging.",
            choices: [
                Choice(text: "Politely refuse and change the subject", isHealthy: true, outcome: "A calm, confident refusal earns respect. Most people won\u{2019}t push after a clear \u{201C}no thanks.\u{201D}"),
                Choice(text: "Join in \u{2014} just to fit in", isHealthy: false, outcome: "Social pressure fades in minutes; regret lasts much longer. You don\u{2019}t need approval from this."),
                Choice(text: "Leave early with a quick excuse", isHealthy: true, outcome: "Knowing when to leave is a superpower. Protect your progress over people-pleasing.")
            ]
        ),
        Scenario(
            situation: "You\u{2019}re alone and bored on a Friday night.",
            choices: [
                Choice(text: "Start a hobby or creative project", isHealthy: true, outcome: "Boredom is just unspent energy. Redirecting it into something you enjoy builds a new reward pathway."),
                Choice(text: "Give in \u{2014} nothing else to do", isHealthy: false, outcome: "Boredom is temporary; relapse sets you back. The emptiness after giving in is far worse than the boredom."),
                Choice(text: "Go for a walk or hit the gym", isHealthy: true, outcome: "Physical activity floods your brain with endorphins \u{2014} the same reward, without the cost.")
            ]
        ),
        Scenario(
            situation: "Someone offers it to you directly.",
            choices: [
                Choice(text: "Say no firmly and clearly", isHealthy: true, outcome: "A direct \u{201C}no\u{201D} is your strongest tool. It gets easier every time you use it."),
                Choice(text: "Accept \u{2014} it\u{2019}s rude to refuse", isHealthy: false, outcome: "Politeness isn\u{2019}t worth your recovery. The person offering will forget; you won\u{2019}t."),
                Choice(text: "Change the subject smoothly", isHealthy: true, outcome: "Redirecting the conversation avoids confrontation while keeping your boundary intact.")
            ]
        ),
        Scenario(
            situation: "You just had an argument with someone you love.",
            choices: [
                Choice(text: "Journal about what you\u{2019}re feeling", isHealthy: true, outcome: "Writing processes emotions without numbing them. You\u{2019}ll feel lighter and think more clearly."),
                Choice(text: "Use your habit to cope with the pain", isHealthy: false, outcome: "Numbing the pain doesn\u{2019}t resolve the conflict. It adds guilt on top of hurt."),
                Choice(text: "Call a support person", isHealthy: true, outcome: "Reaching out when you\u{2019}re hurting shows strength. A support person can help you see clearly.")
            ]
        ),
        Scenario(
            situation: "You\u{2019}re celebrating something good. The voice says \u{201C}you earned it.\u{201D}",
            choices: [
                Choice(text: "Celebrate in a different, healthy way", isHealthy: true, outcome: "Buy something nice, cook a great meal, or share the news. Celebrations don\u{2019}t need your old habit."),
                Choice(text: "Give in \u{2014} just this once as a reward", isHealthy: false, outcome: "Using your habit as a reward keeps it wired as \u{201C}good\u{201D} in your brain. Celebrate your win, don\u{2019}t undo it."),
                Choice(text: "Remind yourself of your values and goals", isHealthy: true, outcome: "Your biggest celebration is how far you\u{2019}ve come. Don\u{2019}t trade lasting pride for a fleeting moment.")
            ]
        )
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                scenarioView
            }
        }
        .navigationTitle("Coping Simulator")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "copingSimulator", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "copingSimulator", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
    }

    // MARK: - Scenario View

    private var scenarioView: some View {
        VStack(spacing: 0) {
            VStack(spacing: AppStyle.spacing) {
                progressBar
                    .padding(.horizontal, AppStyle.screenPadding)

                roundDots
            }
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    Spacer().frame(height: 12)

                    // XP counter
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.neonGold)
                            Text("\(totalXP) XP")
                                .font(Typography.headline)
                                .foregroundColor(.neonGold)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.neonGold.opacity(0.12))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, AppStyle.screenPadding)

                    // Situation card
                    VStack(spacing: 12) {
                        Image(systemName: "theatermasks.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.neonPurple)
                            .shadow(color: .neonPurple.opacity(0.4), radius: 8, x: 0, y: 0)

                        Text("Scenario \(currentScenario + 1) of 6")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)

                        Text(scenarios[currentScenario].situation)
                            .font(Typography.title)
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .neonCard(glow: .neonPurple)
                    .padding(.horizontal, AppStyle.screenPadding)

                    // Choices
                    VStack(spacing: 12) {
                        Text("What do you do?")
                            .font(Typography.headline)
                            .foregroundColor(.subtleText)

                        ForEach(Array(scenarios[currentScenario].choices.enumerated()), id: \.offset) { index, choice in
                            Button {
                                guard !showOutcome else { return }
                                selectChoice(index: index, isHealthy: choice.isHealthy)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(choice.text)
                                        .font(Typography.body)
                                        .foregroundColor(.appText)
                                        .multilineTextAlignment(.leading)

                                    if showOutcome && (selectedChoice == index || choice.isHealthy) {
                                        Text(choice.outcome)
                                            .font(Typography.caption)
                                            .foregroundColor(.subtleText)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(choiceBackground(index: index, isHealthy: choice.isHealthy))
                                .cornerRadius(AppStyle.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                        .stroke(choiceBorder(index: index, isHealthy: choice.isHealthy), lineWidth: 2)
                                )
                            }
                            .disabled(showOutcome)
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)

                    // Next button
                    if showOutcome {
                        Button {
                            advanceScenario()
                        } label: {
                            HStack {
                                Text(currentScenario < 5 ? "Next Scenario" : "See Results")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(RainbowButtonStyle())
                        .padding(.horizontal, AppStyle.screenPadding)
                    }

                    Spacer().frame(height: 20)
                }
            }
        }
    }

    private func choiceBackground(index: Int, isHealthy: Bool) -> Color {
        guard showOutcome else { return Color.cardBackground }
        if isHealthy { return Color.neonGreen.opacity(0.08) }
        if selectedChoice == index { return Color.neonMagenta.opacity(0.08) }
        return Color.cardBackground
    }

    private func choiceBorder(index: Int, isHealthy: Bool) -> Color {
        guard showOutcome else { return .clear }
        if isHealthy { return .neonGreen }
        if selectedChoice == index && !isHealthy { return .neonMagenta }
        return .clear
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cardBackground)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(currentScenario + 1) / 6.0, height: 8)
                    .animation(.easeInOut(duration: 0.4), value: currentScenario)
            }
        }
        .frame(height: 8)
    }

    // MARK: - Round Dots

    private var roundDots: some View {
        let colors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]
        return HStack(spacing: 8) {
            ForEach(0..<6) { index in
                Circle()
                    .fill(index <= currentScenario ? colors[index] : Color.cardBackground)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(colors[index].opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: index <= currentScenario ? colors[index].opacity(0.4) : .clear, radius: 4, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.3), value: currentScenario)
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            if confettiVisible {
                SparkleParticlesView(count: 40, colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold])
                    .frame(height: 200)
                    .transition(.opacity)
            }

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.neonGreen)
                .shadow(color: .neonGreen.opacity(0.5), radius: 16, x: 0, y: 0)
                .scaleEffect(confettiVisible ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: confettiVisible)

            Text("Well Done!")
                .font(Typography.largeTitle)
                .rainbowText()

            // Final score
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.neonGold)
                    Text("\(totalXP) / 60 XP")
                        .font(Typography.statValue)
                        .foregroundColor(.neonGold)
                }

                Text(scoreMessage)
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .rainbowCard()

            Text("You practiced real-world scenarios.\nThese skills will be there when you need them.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            Button {
                showResistPopup = true
            } label: {
                Text("Done")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    private var scoreMessage: String {
        if totalXP >= 50 { return "Outstanding judgment! You\u{2019}re ready for anything." }
        if totalXP >= 30 { return "Good instincts! Keep practicing." }
        return "Every practice session makes you stronger."
    }

    // MARK: - Actions

    private func selectChoice(index: Int, isHealthy: Bool) {
        selectedChoice = index
        withAnimation(.easeInOut(duration: 0.3)) {
            showOutcome = true
        }
        if isHealthy {
            totalXP += 10
        }
    }

    private func advanceScenario() {
        if currentScenario < 5 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentScenario += 1
                showOutcome = false
                selectedChoice = nil
            }
        } else {
            withAnimation {
                isComplete = true
                confettiVisible = true
            }
        }
    }
}

// MARK: - Models

private struct Scenario {
    let situation: String
    let choices: [Choice]
}

private struct Choice {
    let text: String
    let isHealthy: Bool
    let outcome: String
}

struct CopingSimulatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CopingSimulatorView()
        }
        .preferredColorScheme(.dark)
    }
}
