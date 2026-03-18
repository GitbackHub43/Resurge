import SwiftUI
import CoreData

struct UrgeDefusionView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - State

    @State private var currentRound: Int = 0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var salesmanScale: CGFloat = 1.0
    @State private var showOutcome: Bool = false
    @State private var selectedIndex: Int? = nil
    @State private var flashGreen: Bool = false
    @State private var wobble: Bool = false
    @State private var showHint: Bool = false
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    private let rounds: [DefusionRound] = [
        DefusionRound(
            pitch: "Just this once won\u{2019}t hurt.",
            comebacks: [
                Comeback(text: "Maybe you\u{2019}re right...", isBest: false),
                Comeback(text: "One time IS every time for me.", isBest: true),
                Comeback(text: "I\u{2019}ll think about it.", isBest: false)
            ]
        ),
        DefusionRound(
            pitch: "You deserve it after today.",
            comebacks: [
                Comeback(text: "I do deserve a treat.", isBest: false),
                Comeback(text: "I deserve freedom more.", isBest: true),
                Comeback(text: "That\u{2019}s a good point.", isBest: false)
            ]
        ),
        DefusionRound(
            pitch: "No one will know.",
            comebacks: [
                Comeback(text: "I will know, and that matters.", isBest: true),
                Comeback(text: "You\u{2019}re right, no one\u{2019}s watching.", isBest: false),
                Comeback(text: "I guess it\u{2019}s fine then.", isBest: false)
            ]
        ),
        DefusionRound(
            pitch: "You can start again tomorrow.",
            comebacks: [
                Comeback(text: "Tomorrow sounds reasonable.", isBest: false),
                Comeback(text: "Tomorrow me will thank today me.", isBest: true),
                Comeback(text: "One more day won\u{2019}t matter.", isBest: false)
            ]
        ),
        DefusionRound(
            pitch: "Life is too short.",
            comebacks: [
                Comeback(text: "Life is too short to stay trapped.", isBest: true),
                Comeback(text: "You\u{2019}re right, enjoy it.", isBest: false),
                Comeback(text: "I should live a little.", isBest: false)
            ]
        ),
        DefusionRound(
            pitch: "Everyone else does it.",
            comebacks: [
                Comeback(text: "Maybe I should too.", isBest: false),
                Comeback(text: "If they can, so can I.", isBest: false),
                Comeback(text: "I\u{2019}m not everyone \u{2014} I\u{2019}m stronger.", isBest: true)
            ]
        )
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                roundView
            }
        }
        .navigationTitle("Urge Defusion")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "urgeDefusion", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "urgeDefusion", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
    }

    // MARK: - Round View

    private var roundView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer().frame(height: 8)

            progressBar

            roundDots

            Spacer()

            // Salesman character
            salesmanCharacter

            // Pitch card
            pitchCard

            // Comeback options
            comebackOptions

            Spacer()

            // Next button (shown after selection)
            if showOutcome {
                Button {
                    advanceRound()
                } label: {
                    HStack {
                        Text(currentRound < 5 ? "Next Round" : "Finish")
                        if currentRound < 5 {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .buttonStyle(RainbowButtonStyle())
            }

            Spacer().frame(height: 8)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Salesman Character

    private var salesmanCharacter: some View {
        ZStack {
            Circle()
                .fill(Color.neonMagenta.opacity(0.12))
                .frame(width: 90, height: 90)

            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 44))
                .foregroundColor(.neonMagenta)
                .shadow(color: .neonMagenta.opacity(0.5), radius: 8, x: 0, y: 0)
        }
        .scaleEffect(salesmanScale)
        .rotationEffect(wobble ? .degrees(5) : .degrees(0))
        .overlay(
            Circle()
                .fill(Color.neonGreen.opacity(flashGreen ? 0.4 : 0.0))
                .frame(width: 100, height: 100)
                .scaleEffect(salesmanScale)
                .animation(.easeOut(duration: 0.3), value: flashGreen)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: salesmanScale)
    }

    // MARK: - Pitch Card

    private var pitchCard: some View {
        VStack(spacing: 8) {
            Text("The urge says:")
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            Text("\u{201C}\(rounds[currentRound].pitch)\u{201D}")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonMagenta.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Comeback Options

    private var comebackOptions: some View {
        VStack(spacing: 10) {
            ForEach(Array(rounds[currentRound].comebacks.enumerated()), id: \.offset) { index, comeback in
                Button {
                    guard !showOutcome else { return }
                    selectComeback(index: index, isBest: comeback.isBest)
                } label: {
                    HStack {
                        Text(comeback.text)
                            .font(Typography.body)
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if showOutcome && comeback.isBest {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.neonGreen)
                        } else if showOutcome && selectedIndex == index && !comeback.isBest {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.neonMagenta)
                        }
                    }
                    .padding()
                    .background(comebackBackground(index: index, isBest: comeback.isBest))
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(comebackBorder(index: index, isBest: comeback.isBest), lineWidth: 2)
                    )
                }
                .disabled(showOutcome)
            }

            if showHint {
                Text("Try the green response")
                    .font(Typography.caption)
                    .foregroundColor(.neonGreen)
                    .transition(.opacity)
            }
        }
    }

    private func comebackBackground(index: Int, isBest: Bool) -> Color {
        guard showOutcome else { return Color.cardBackground }
        if isBest { return Color.neonGreen.opacity(0.1) }
        if selectedIndex == index { return Color.neonMagenta.opacity(0.1) }
        return Color.cardBackground
    }

    private func comebackBorder(index: Int, isBest: Bool) -> Color {
        guard showOutcome else { return .clear }
        if isBest { return .neonGreen }
        if selectedIndex == index { return .neonMagenta }
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
                    .frame(width: geo.size.width * CGFloat(currentRound + 1) / 6.0, height: 8)
                    .animation(.easeInOut(duration: 0.4), value: currentRound)
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
                    .fill(index <= currentRound ? colors[index] : Color.cardBackground)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(colors[index].opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: index <= currentRound ? colors[index].opacity(0.4) : .clear, radius: 4, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.3), value: currentRound)
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

            // Tiny salesman
            ZStack {
                Circle()
                    .fill(Color.neonMagenta.opacity(0.08))
                    .frame(width: 40, height: 40)

                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 18))
                    .foregroundColor(.neonMagenta.opacity(0.4))
            }

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.neonGreen)
                .shadow(color: .neonGreen.opacity(0.5), radius: 16, x: 0, y: 0)
                .scaleEffect(confettiVisible ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: confettiVisible)

            Text("Urge Defeated")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You talked back to every pitch and won.\nThe urge has no power over you.")
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

    // MARK: - Actions

    private func selectComeback(index: Int, isBest: Bool) {
        selectedIndex = index
        showOutcome = true

        if isBest {
            // Salesman shrinks
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                salesmanScale -= 0.15
            }
            flashGreen = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                flashGreen = false
            }
            showHint = false
        } else {
            // Wobble animation
            withAnimation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)) {
                wobble = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wobble = false
            }
            withAnimation {
                showHint = true
            }
        }
    }

    private func advanceRound() {
        if currentRound < 5 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentRound += 1
                showOutcome = false
                selectedIndex = nil
                showHint = false
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

private struct DefusionRound {
    let pitch: String
    let comebacks: [Comeback]
}

private struct Comeback {
    let text: String
    let isBest: Bool
}

struct UrgeDefusionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UrgeDefusionView()
        }
        .preferredColorScheme(.dark)
    }
}
