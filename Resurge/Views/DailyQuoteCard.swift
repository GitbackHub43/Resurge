import SwiftUI

struct DailyQuoteCard: View {
    let programType: ProgramType?

    @State private var currentQuote: Quote

    init(programType: ProgramType? = nil) {
        self.programType = programType
        _currentQuote = State(initialValue: QuoteBank.quoteOfTheDay(for: programType))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            // Header
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.neonMagenta)
                    .font(.caption)
                Text("Daily Quote")
                    .font(Typography.caption)
                    .rainbowText()
                Spacer()
            }

            // Quote text
            Text(currentQuote.text)
                .font(Typography.body)
                .italic()
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Author
            if !currentQuote.author.isEmpty {
                Text("— \(currentQuote.author)")
                    .font(Typography.callout)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .fill(Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                var newQuote = QuoteBank.randomQuote(for: programType)
                while newQuote.id == currentQuote.id && QuoteBank.allQuotes.count > 1 {
                    newQuote = QuoteBank.randomQuote(for: programType)
                }
                currentQuote = newQuote
            }
        }
    }
}

// MARK: - Preview

struct DailyQuoteCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            DailyQuoteCard(programType: nil)
                .padding(AppStyle.screenPadding)
        }
        .preferredColorScheme(.dark)
    }
}
