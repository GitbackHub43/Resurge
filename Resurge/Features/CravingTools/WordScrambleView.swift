import SwiftUI

struct LetterItem: Identifiable {
    let id: Int
    let letter: Character
}

struct WordScrambleView: View {
    @State private var words: [String] = [
        "STRENGTH", "COURAGE", "FREEDOM", "RECOVERY", "HEALING",
        "MINDFUL", "PROGRESS", "RESOLVE", "BREATHE", "WARRIOR",
        "BALANCE", "CLARITY", "GROWTH", "PATIENCE", "BELIEVE",
        "PERSIST", "SOBER", "STRONG", "FOCUS", "PEACE"
    ]

    @State private var currentWord = ""
    @State private var scrambledLetters: [LetterItem] = []
    @State private var selectedIndices: [Int] = []
    @State private var score = 0
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @State private var showCelebration = false
    @State private var wrongShake = false

    private let rainbowColors: [Color] = [
        .neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Stats Row
                    HStack(spacing: 24) {
                        statBadge(icon: "star.fill", value: "\(score)", label: "Solved", color: .neonGold)
                        statBadge(icon: "clock.fill", value: formattedTime, label: "Time", color: .neonCyan)
                    }
                    .padding(.horizontal)

                    // MARK: - Current Attempt
                    VStack(spacing: 12) {
                        Text("Spell the word!")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.subtleText)

                        Text(currentAttempt)
                            .font(.title.weight(.bold))
                            .foregroundColor(.appText)
                            .frame(minHeight: 44)
                            .scaleEffect(showCelebration ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: showCelebration)
                            .overlay(
                                showCelebration ?
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.neonGreen.opacity(0.2))
                                        .blur(radius: 12)
                                    : nil
                            )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
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
                                lineWidth: showCelebration ? 2 : 1
                            )
                            .opacity(showCelebration ? 1.0 : 0.4)
                    )
                    .padding(.horizontal)

                    // MARK: - Letter Pills
                    LetterGridView(
                        scrambledLetters: scrambledLetters,
                        selectedIndices: selectedIndices,
                        rainbowColors: rainbowColors,
                        showCelebration: showCelebration,
                        onTap: { index in
                            tapLetter(at: index)
                        }
                    )
                    .padding(.horizontal)
                    .offset(x: wrongShake ? -8 : 0)
                    .animation(
                        wrongShake ?
                            Animation.default.repeatCount(3, autoreverses: true).speed(6)
                            : .default,
                        value: wrongShake
                    )

                    // MARK: - Action Buttons
                    HStack(spacing: 16) {
                        Button {
                            clearAttempt()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Clear")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.neonCyan)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.neonCyan.opacity(0.12))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                            )
                        }

                        Button {
                            skipWord()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "forward.fill")
                                Text("Skip")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.neonOrange)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.neonOrange.opacity(0.12))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.neonOrange.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Word Scramble")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startNewWord()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Computed

    private var currentAttempt: String {
        let chars = selectedIndices.compactMap { idx -> Character? in
            guard let item = scrambledLetters.first(where: { $0.id == idx }) else { return nil }
            return item.letter
        }
        return chars.isEmpty ? " " : String(chars)
    }

    private var formattedTime: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Game Logic

    private func startNewWord() {
        showCelebration = false
        let word = words.randomElement() ?? "RECOVERY"
        currentWord = word
        selectedIndices = []

        var letters = Array(word)
        // Ensure scrambled version differs from original
        for _ in 0..<10 {
            letters.shuffle()
            if String(letters) != word { break }
        }

        scrambledLetters = letters.enumerated().map { (index, char) in
            LetterItem(id: index, letter: char)
        }
    }

    private func tapLetter(at id: Int) {
        guard !showCelebration else { return }
        guard !selectedIndices.contains(id) else { return }

        selectedIndices.append(id)

        // Check if word is complete
        if selectedIndices.count == currentWord.count {
            let attempt = currentAttempt.trimmingCharacters(in: .whitespaces)
            if attempt == currentWord {
                // Correct
                score += 1
                showCelebration = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    startNewWord()
                }
            } else {
                // Wrong
                wrongShake = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    wrongShake = false
                    clearAttempt()
                }
            }
        }
    }

    private func clearAttempt() {
        selectedIndices = []
    }

    private func skipWord() {
        startNewWord()
    }

    private func startTimer() {
        timer?.invalidate()
        elapsedSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    // MARK: - Subviews

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.appText)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.subtleText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Letter Grid View

private struct LetterGridView: View {
    let scrambledLetters: [LetterItem]
    let selectedIndices: [Int]
    let rainbowColors: [Color]
    let showCelebration: Bool
    let onTap: (Int) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 50), spacing: 10)
    ]

    var body: some View {
        let items = scrambledLetters
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(items, id: \.id) { item in
                letterButton(item: item)
            }
        }
    }

    private func letterButton(item: LetterItem) -> some View {
        let isSelected = selectedIndices.contains(item.id)
        let colorIndex = item.id % rainbowColors.count

        return Button {
            onTap(item.id)
        } label: {
            Text(String(item.letter))
                .font(.title2.weight(.bold))
                .foregroundColor(
                    isSelected
                        ? (showCelebration ? .neonGreen : .subtleText)
                        : .appText
                )
                .frame(width: 50, height: 50)
                .background(
                    isSelected
                        ? (showCelebration ? Color.neonGreen.opacity(0.15) : Color.cardBackground.opacity(0.4))
                        : Color.cardBackground
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: isSelected
                                    ? [showCelebration ? Color.neonGreen : Color.subtleText.opacity(0.3)]
                                    : [rainbowColors[colorIndex], rainbowColors[(colorIndex + 1) % rainbowColors.count]],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 1 : 2
                        )
                        .opacity(isSelected ? 0.5 : 0.8)
                        )
                .shadow(
                    color: isSelected
                        ? Color.clear
                        : rainbowColors[colorIndex].opacity(0.3),
                    radius: 6
                )
        }
        .disabled(isSelected)
    }
}

// MARK: - Preview

struct WordScrambleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WordScrambleView()
        }
    }
}
