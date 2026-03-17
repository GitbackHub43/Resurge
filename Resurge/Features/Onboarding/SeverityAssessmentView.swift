import SwiftUI

struct SeverityAssessmentView: View {
    @Binding var severityScore: Int  // 0-20, written by this view
    let programType: ProgramType
    let onNext: () -> Void

    @State private var currentQuestion = 0
    @State private var answers: [Int] = [0, 0, 0, 0, 0]  // 0-4 per question
    @State private var showResult = false
    @State private var ringProgress: CGFloat = 0

    private let questions: [(text: String, options: [(label: String, score: Int)])] = [
        (
            text: "How long have you been dealing with this?",
            options: [
                ("Less than a year", 1),
                ("1\u{2013}3 years", 2),
                ("3\u{2013}5 years", 3),
                ("5+ years", 4)
            ]
        ),
        (
            text: "How often do you engage in this habit?",
            options: [
                ("Occasionally", 1),
                ("Weekly", 2),
                ("Several times a week", 3),
                ("Daily or more", 4)
            ]
        ),
        (
            text: "Have you tried to quit before?",
            options: [
                ("Never tried", 1),
                ("Once or twice", 2),
                ("Several times", 3),
                ("Many times", 4)
            ]
        ),
        (
            text: "How much does it affect your daily life?",
            options: [
                ("Not much", 1),
                ("Somewhat", 2),
                ("Significantly", 3),
                ("Severely", 4)
            ]
        ),
        (
            text: "How confident are you that you can change?",
            options: [
                ("Very confident", 1),
                ("Fairly confident", 2),
                ("Somewhat", 3),
                ("Not at all", 4)
            ]
        )
    ]

    private var totalScore: Int {
        answers.reduce(0, +)
    }

    private var severityLevel: SeverityLevel {
        SeverityLevel.from(score: totalScore)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if showResult {
                resultView
            } else {
                questionView
            }
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer().frame(height: AppStyle.largeSpacing)

            // Progress indicator
            progressBar

            Spacer().frame(height: AppStyle.spacing)

            // Question text
            Text(questions[currentQuestion].text)
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Spacer().frame(height: AppStyle.spacing)

            // Options
            VStack(spacing: AppStyle.spacing) {
                ForEach(Array(questions[currentQuestion].options.enumerated()), id: \.offset) { index, option in
                    optionCard(label: option.label, score: option.score, index: index)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            // Next button (only enabled when an answer is selected)
            if answers[currentQuestion] > 0 {
                Button {
                    advanceQuestion()
                } label: {
                    Text(currentQuestion < 4 ? "Next" : "See My Plan")
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal, AppStyle.screenPadding)
                .transition(.opacity)
            }

            Spacer().frame(height: AppStyle.largeSpacing)
        }
        .animation(.easeInOut(duration: 0.3), value: currentQuestion)
        .animation(.easeInOut(duration: 0.25), value: answers[currentQuestion])
    }

    // MARK: - Option Card

    private func optionCard(label: String, score: Int, index: Int) -> some View {
        Button {
            answers[currentQuestion] = score
        } label: {
            HStack {
                Text(label)
                    .font(Typography.body)
                    .foregroundColor(answers[currentQuestion] == score ? .white : .textPrimary)
                Spacer()
                if answers[currentQuestion] == score {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(AppStyle.cardPadding)
            .background(answers[currentQuestion] == score ? Color.neonCyan.opacity(0.8) : Color.cardBackground)
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(
                        answers[currentQuestion] == score ? Color.neonCyan : Color.cardBorder,
                        lineWidth: answers[currentQuestion] == score ? 2 : 1
                    )
            )
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 6) {
            Text("Question \(currentQuestion + 1) of 5")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cardBackground)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(currentQuestion + 1) / 5.0, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentQuestion)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            Text("Your Recovery Plan")
                .font(Typography.largeTitle)
                .rainbowText()

            // Animated severity ring
            ZStack {
                Circle()
                    .stroke(Color.cardBorder, lineWidth: 10)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        severityLevel.color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: severityLevel.color.opacity(0.5), radius: 12, x: 0, y: 0)

                VStack(spacing: 4) {
                    Text(severityLevel.label)
                        .font(Typography.headline)
                        .foregroundColor(severityLevel.color)
                    Text("\(totalScore)/20")
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            // Encouraging message
            Text(severityLevel.message)
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding * 1.5)

            // Program-specific note
            Text("Your \(programType.displayName) recovery plan has been customized based on your assessment.")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            Button {
                severityScore = totalScore
                onNext()
            } label: {
                Text("Continue")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer().frame(height: AppStyle.largeSpacing)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                ringProgress = CGFloat(totalScore) / 20.0
            }
        }
    }

    // MARK: - Helpers

    private func advanceQuestion() {
        if currentQuestion < 4 {
            withAnimation {
                currentQuestion += 1
            }
        } else {
            withAnimation {
                showResult = true
            }
        }
    }
}

// MARK: - Severity Level

private enum SeverityLevel {
    case mild
    case moderate
    case severe

    static func from(score: Int) -> SeverityLevel {
        switch score {
        case 5...8:   return .mild
        case 9...14:  return .moderate
        default:      return .severe  // 15-20
        }
    }

    var label: String {
        switch self {
        case .mild:     return "Mild"
        case .moderate: return "Moderate"
        case .severe:   return "Severe"
        }
    }

    var color: Color {
        switch self {
        case .mild:     return .neonGreen
        case .moderate: return .neonOrange
        case .severe:   return Color(hex: "FF3B30")  // Red
        }
    }

    var message: String {
        switch self {
        case .mild:
            return "You\u{2019}re catching this early. That\u{2019}s a great sign."
        case .moderate:
            return "You\u{2019}ve recognized the challenge. We\u{2019}ll build a strong plan together."
        case .severe:
            return "Recovery is absolutely possible. We\u{2019}ll take this one step at a time."
        }
    }
}

// MARK: - Preview

struct SeverityAssessmentView_Previews: PreviewProvider {
    static var previews: some View {
        SeverityAssessmentView(
            severityScore: .constant(0),
            programType: .smoking,
            onNext: {}
        )
    }
}
