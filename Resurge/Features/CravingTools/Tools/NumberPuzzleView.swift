import SwiftUI
import CoreData

struct NumberPuzzleView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("numberPuzzleHighScore") private var highScore: Int = 0

    @State private var currentRound = 1
    @State private var score = 0
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @State private var gameOver = false

    // Current problem
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var isAddition = true
    @State private var choices: [Int] = []
    @State private var correctAnswer = 0

    // Feedback
    @State private var selectedIndex: Int? = nil
    @State private var showCorrect = false
    @State private var showWrong = false
    @State private var trophyScale: CGFloat = 0.5
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    private let totalRounds = 10

    private let rainbowColors: [Color] = [
        .neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if gameOver {
                completionView
            } else {
                gameView
            }
        }
        .navigationTitle("Number Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "puzzle", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "puzzle", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onAppear {
            generateProblem()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Clear your mind with numbers")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                    .padding(.top, 8)

                // Stats Row
                HStack(spacing: 24) {
                    statBadge(icon: "number.circle.fill", value: "\(currentRound)/\(totalRounds)", label: "Round", color: .neonCyan)
                    statBadge(icon: "star.fill", value: "\(score)", label: "Score", color: .neonGold)
                    statBadge(icon: "clock.fill", value: formattedTime, label: "Time", color: .neonPurple)
                }

                // Problem Card
                VStack(spacing: 16) {
                    Text("\(num1) \(isAddition ? "+" : "-") \(num2) = ?")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.appText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: rainbowColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .opacity(0.5)
                )
                .padding(.horizontal)

                // Answer Choices
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    ForEach(Array(choices.enumerated()), id: \.offset) { index, choice in
                        Button {
                            answerTapped(index: index, choice: choice)
                        } label: {
                            Text("\(choice)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(answerColor(for: index))
                                .frame(maxWidth: .infinity)
                                .frame(height: 72)
                                .background(answerBackground(for: index))
                                .cornerRadius(AppStyle.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                        .stroke(answerBorderColor(for: index), lineWidth: 2)
                                )
                        }
                        .disabled(selectedIndex != nil)
                    }
                }
                .padding(.horizontal)

                // High Score
                if highScore > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .font(Typography.caption)
                            .foregroundColor(.neonGold)
                        Text("Best: \(highScore)")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        ZStack {
            SparkleParticlesView(count: 30)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Puzzle Complete!")
                    .font(Typography.largeTitle)
                    .rainbowText()

                ZStack {
                    Circle()
                        .fill(Color.neonGold.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.neonGold)
                        .shadow(color: .neonGold.opacity(0.6), radius: 12)
                }
                .scaleEffect(trophyScale)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                        trophyScale = 1.0
                    }
                }

                VStack(spacing: 8) {
                    Text("Score: \(totalScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.neonCyan)

                    Text("\(score)/\(totalRounds) correct in \(formattedTime)")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)

                    if totalScore > highScore || (highScore == 0 && totalScore > 0) {
                        Text("New High Score!")
                            .font(Typography.headline)
                            .foregroundColor(.neonGold)
                            .padding(.top, 4)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        resetGame()
                    } label: {
                        Text("Play Again")
                    }
                    .buttonStyle(RainbowButtonStyle())

                    Button {
                        showResistPopup = true
                    } label: {
                        Text("Done")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private var totalScore: Int {
        let timeBonus = max(0, 120 - elapsedSeconds)
        return (score * 10) + timeBonus
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func generateProblem() {
        isAddition = Bool.random()
        if isAddition {
            num1 = Int.random(in: 5...50)
            num2 = Int.random(in: 5...50)
            correctAnswer = num1 + num2
        } else {
            num1 = Int.random(in: 20...80)
            num2 = Int.random(in: 5...min(num1, 40))
            correctAnswer = num1 - num2
        }

        // Generate 3 wrong answers
        var wrongAnswers: Set<Int> = []
        while wrongAnswers.count < 3 {
            let offset = Int.random(in: 1...10) * (Bool.random() ? 1 : -1)
            let wrong = correctAnswer + offset
            if wrong != correctAnswer && wrong >= 0 {
                wrongAnswers.insert(wrong)
            }
        }

        choices = (Array(wrongAnswers) + [correctAnswer]).shuffled()
        selectedIndex = nil
        showCorrect = false
        showWrong = false
    }

    private func answerTapped(index: Int, choice: Int) {
        selectedIndex = index
        if choice == correctAnswer {
            showCorrect = true
            score += 1
        } else {
            showWrong = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if currentRound >= totalRounds {
                timer?.invalidate()
                let finalScore = totalScore
                if finalScore > highScore {
                    highScore = finalScore
                }
                gameOver = true
            } else {
                currentRound += 1
                generateProblem()
            }
        }
    }

    private func answerColor(for index: Int) -> Color {
        guard let selected = selectedIndex else { return .appText }
        if index == selected {
            return choices[index] == correctAnswer ? .white : .white
        }
        if showCorrect || showWrong {
            if choices[index] == correctAnswer { return .neonGreen }
        }
        return .appText
    }

    private func answerBackground(for index: Int) -> Color {
        guard let selected = selectedIndex else { return Color.cardBackground }
        if index == selected {
            return choices[index] == correctAnswer ? .neonGreen : .neonOrange
        }
        return Color.cardBackground
    }

    private func answerBorderColor(for index: Int) -> Color {
        guard let selected = selectedIndex else {
            return rainbowColors[index % rainbowColors.count].opacity(0.4)
        }
        if index == selected {
            return choices[index] == correctAnswer ? .neonGreen : .neonOrange
        }
        if choices[index] == correctAnswer {
            return .neonGreen.opacity(0.6)
        }
        return Color.cardBorder
    }

    private func resetGame() {
        currentRound = 1
        score = 0
        elapsedSeconds = 0
        gameOver = false
        trophyScale = 0.5
        generateProblem()
        startTimer()
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(Typography.body)
                .foregroundColor(color)
            Text(value)
                .font(Typography.headline)
                .foregroundColor(.appText)
            Text(label)
                .font(Typography.caption)
                .foregroundColor(.subtleText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

struct NumberPuzzleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NumberPuzzleView()
        }
    }
}
