import SwiftUI
import CoreData

struct FocusShiftView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("focusShiftBestLevel") private var bestLevel: Int = 0

    @State private var level: Int = 1
    @State private var score: Int = 0
    @State private var round: Int = 0
    @State private var timeRemaining: Double = 10.0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var gameStarted: Bool = false
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    // Grid state
    @State private var gridItems: [FocusGridItem] = []
    @State private var oddOneOutIndex: Int = 0
    @State private var showCorrectAnswer: Bool = false
    @State private var flashCorrect: Bool = false

    private let roundTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private let totalRounds = 20

    private let triggerIcons = ["smoke.fill", "wineglass.fill", "dice.fill", "cart.fill", "gamecontroller.fill", "iphone"]
    private let neutralIcons = ["leaf.fill", "heart.fill", "star.fill", "sun.max.fill", "cloud.fill", "drop.fill", "flame.fill", "bolt.fill"]

    private var gridSize: Int {
        if level <= 3 { return 3 }
        if level <= 6 { return 4 }
        return 5
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else if !gameStarted {
                introView
            } else {
                gameView
            }
        }
        .navigationTitle("Focus Shift")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "focusShift", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "focusShift", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onReceive(roundTimer) { _ in
            guard gameStarted, !isComplete, !showCorrectAnswer, timeRemaining > 0 else { return }
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                handleTimeout()
            }
        }
    }

    // MARK: - Intro View

    private var introView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.neonCyan)
                .shadow(color: .neonCyan.opacity(0.5), radius: 12, x: 0, y: 0)

            Text("Focus Shift")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("Find the odd icon in the grid.\nTrain your brain to spot what's different.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            VStack(alignment: .leading, spacing: 8) {
                ruleRow(icon: "hand.tap.fill", text: "Tap the icon that doesn't match")
                ruleRow(icon: "timer", text: "10 seconds per round")
                ruleRow(icon: "arrow.up.right", text: "Grid grows as you level up")
            }
            .rainbowCard()
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            Button {
                gameStarted = true
                generateGrid()
            } label: {
                Text("Start Game")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    private func ruleRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.neonCyan)
                .frame(width: 24)
            Text(text)
                .font(Typography.body)
                .foregroundColor(.appText)
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: AppStyle.spacing) {
            Spacer().frame(height: 8)

            // Header: round, score, level
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ROUND \(round + 1)/\(totalRounds)")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                    Text("Level \(level)")
                        .font(Typography.headline)
                        .foregroundColor(.neonPurple)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("SCORE")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                    Text("\(score)")
                        .font(Typography.statValue)
                        .foregroundColor(.neonCyan)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)

            // Timer bar
            timerProgressBar

            Text("Find the odd one out!")
                .font(Typography.headline)
                .foregroundColor(.appText)

            Spacer()

            // Grid
            gridView

            Spacer()

            // Grid size indicator
            Text("\(gridSize)x\(gridSize) Grid")
                .font(Typography.caption)
                .foregroundColor(.subtleText.opacity(0.5))

            Spacer().frame(height: AppStyle.largeSpacing)
        }
    }

    // MARK: - Timer Progress Bar

    private var timerProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cardBackground)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: timeRemaining < 3 ? [.neonOrange, .neonMagenta] : [.neonCyan, .neonGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(max(0, timeRemaining) / 10.0), height: 6)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Grid View

    private var gridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize)
        let cellSize: CGFloat = gridSize <= 3 ? 80 : (gridSize <= 4 ? 65 : 52)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(gridItems.indices, id: \.self) { index in
                let item = gridItems[index]
                Button {
                    handleTap(index: index)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .fill(cellColor(for: item, at: index))
                            .frame(width: cellSize, height: cellSize)

                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(cellBorderColor(for: item, at: index), lineWidth: 1)
                            .frame(width: cellSize, height: cellSize)

                        Image(systemName: item.icon)
                            .font(.system(size: cellSize * 0.4))
                            .foregroundColor(item.isOddOne ? .neonGreen : .neonMagenta.opacity(0.7))
                    }
                }
                .disabled(showCorrectAnswer)
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    private func cellColor(for item: FocusGridItem, at index: Int) -> Color {
        if showCorrectAnswer && index == oddOneOutIndex {
            return flashCorrect ? Color.neonGreen.opacity(0.25) : Color.neonMagenta.opacity(0.2)
        }
        return Color.cardBackground
    }

    private func cellBorderColor(for item: FocusGridItem, at index: Int) -> Color {
        if showCorrectAnswer && index == oddOneOutIndex {
            return flashCorrect ? .neonGreen : .neonMagenta
        }
        return Color.cardBorder
    }

    // MARK: - Game Logic

    private func generateGrid() {
        let totalCells = gridSize * gridSize
        let triggerIcon = triggerIcons.randomElement() ?? "smoke.fill"
        let neutralIcon = neutralIcons.randomElement() ?? "leaf.fill"

        oddOneOutIndex = Int.random(in: 0..<totalCells)

        var items: [FocusGridItem] = []
        for i in 0..<totalCells {
            if i == oddOneOutIndex {
                items.append(FocusGridItem(icon: neutralIcon, isOddOne: true))
            } else {
                items.append(FocusGridItem(icon: triggerIcon, isOddOne: false))
            }
        }
        gridItems = items
        timeRemaining = 10.0
        showCorrectAnswer = false
        flashCorrect = false
    }

    private func handleTap(index: Int) {
        guard !showCorrectAnswer else { return }

        if index == oddOneOutIndex {
            // Correct
            score += 10
            flashCorrect = true
            showCorrectAnswer = true
            advanceRound()
        } else {
            // Wrong
            score = max(0, score - 5)
            flashCorrect = false
            showCorrectAnswer = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                advanceRound()
            }
        }
    }

    private func handleTimeout() {
        score = max(0, score - 5)
        flashCorrect = false
        showCorrectAnswer = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advanceRound()
        }
    }

    private func advanceRound() {
        if flashCorrect {
            // Level up every 2 correct rounds
            if (round + 1) % 2 == 0 {
                level += 1
            }
        }

        round += 1
        if round >= totalRounds {
            finishGame()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + (flashCorrect ? 0.5 : 0.0)) {
                generateGrid()
            }
        }
    }

    private func finishGame() {
        if level > bestLevel {
            bestLevel = level
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isComplete = true
            confettiVisible = true
        }
        // Tool completion tracked via resist popup
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

            Text("Game Complete!")
                .font(Typography.largeTitle)
                .rainbowText()

            VStack(spacing: AppStyle.spacing) {
                statRow(label: "Final Score", value: "\(score)", color: .neonCyan)
                statRow(label: "Level Reached", value: "\(level)", color: .neonPurple)
                statRow(label: "Best Level Ever", value: "\(bestLevel)", color: .neonGold)
            }
            .rainbowCard()
            .padding(.horizontal, AppStyle.screenPadding)

            Text("You're training your attention to look past triggers\nand find what truly matters.")
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

    private func statRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(Typography.body)
                .foregroundColor(.subtleText)
            Spacer()
            Text(value)
                .font(Typography.title)
                .foregroundColor(color)
        }
    }
}

// MARK: - Focus Grid Item

private struct FocusGridItem {
    let icon: String
    let isOddOne: Bool
}

struct FocusShiftView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FocusShiftView()
        }
        .preferredColorScheme(.dark)
    }
}
