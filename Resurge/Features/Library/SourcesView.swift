import SwiftUI

struct SourcesView: View {
    let citations: [Citation]

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppStyle.spacing) {
                    Text("Sources & References")
                        .font(Typography.title)
                        .foregroundColor(.textPrimary)
                        .padding(.bottom, 4)

                    if citations.isEmpty {
                        Text("No citations available for this article.")
                            .font(Typography.body)
                            .foregroundColor(.textSecondary)
                    } else {
                        ForEach(citations) { citation in
                            citationRow(citation)
                        }
                    }

                    Spacer().frame(height: AppStyle.largeSpacing)
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.top, AppStyle.spacing)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func citationRow(_ citation: Citation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(citation.sourceName)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.neonCyan)

            Text(citation.documentTitle)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .italic()

            Text("(\(String(citation.year)))")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(AppStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .opacity(0.3)
        )
    }
}

struct SourcesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SourcesView(citations: [
                Citation(sourceName: "NIDA", year: 2020, documentTitle: "Drugs, Brains, and Behavior: The Science of Addiction")
            ])
        }
        .preferredColorScheme(.dark)
    }
}
