import SwiftUI

struct CravingToolsView: View {
    @EnvironmentObject var environment: AppEnvironment
    @State private var showCravingMode = false

    private let tools: [CravingToolKind] = [
        .breathing, .puzzle, .quotes, .journaling, .programSpecific("Program-Specific")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Emergency Button
                        Button {
                            showCravingMode = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("I'm having a craving")
                                        .font(.headline.weight(.bold))
                                    Text("Get immediate help now")
                                        .font(.caption)
                                        .opacity(0.9)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.semibold))
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(
                                    colors: [.neonOrange, .neonMagenta, .neonPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.neonMagenta.opacity(0.4), radius: 12, y: 4)
                        }
                        .padding(.horizontal)

                        // MARK: - Tools Grid
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(tools) { tool in
                                NavigationLink {
                                    toolDestination(for: tool)
                                } label: {
                                    ToolCard(tool: tool)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Craving Tools")
            .fullScreenCover(isPresented: $showCravingMode) {
                CravingModeView()
                    .environmentObject(environment)
            }
        }
    }

    @ViewBuilder
    private func toolDestination(for tool: CravingToolKind) -> some View {
        switch tool {
        case .breathing:
            BreathingToolPlaceholder()
        case .puzzle:
            PuzzleGameView()
        case .quotes:
            QuotesToolPlaceholder()
        case .journaling:
            JournalEditorView(entryContext: "craving")
                .environmentObject(environment)
        default:
            ProgramSpecificToolPlaceholder()
        }
    }
}

// MARK: - Tool Card

private struct ToolCard: View {
    let tool: CravingToolKind

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.neonPurple.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: tool.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.neonCyan)
            }

            Text(tool.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(tool.description)
                .font(.caption2)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Placeholder Tool Views

private struct BreathingToolPlaceholder: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "wind")
                    .font(.system(size: 60))
                    .foregroundColor(.neonCyan)
                Text("Breathing Exercise")
                    .font(.title2.weight(.bold))
                Text("Inhale... Hold... Exhale...")
                    .foregroundColor(.subtleText)
            }
        }
        .navigationTitle("Breathing")
    }
}

private struct PuzzleToolPlaceholder: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "puzzlepiece.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.neonMagenta)
                Text("Distraction Puzzle")
                    .font(.title2.weight(.bold))
                Text("Focus your mind on something else.")
                    .foregroundColor(.subtleText)
            }
        }
        .navigationTitle("Puzzle")
    }
}

private struct QuotesToolPlaceholder: View {
    @State private var currentQuote: Quote = QuoteBank.randomQuote()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.neonGold)

                Text(currentQuote.text)
                    .font(.title3)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .foregroundColor(.appText)

                if !currentQuote.author.isEmpty {
                    Text("— \(currentQuote.author)")
                        .font(Typography.callout)
                        .foregroundColor(.subtleText)
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
                    .font(Typography.callout)
                    .foregroundColor(.neonGold)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Quotes")
    }
}

private struct ProgramSpecificToolPlaceholder: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.premiumGold)
                Text("Program-Specific Tools")
                    .font(.title2.weight(.bold))
                Text("Tools tailored to your specific habit.")
                    .foregroundColor(.subtleText)
            }
        }
        .navigationTitle("Program Tools")
    }
}

// MARK: - Preview

struct CravingToolsView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        CravingToolsView()
            .environmentObject(env)
    }
}
