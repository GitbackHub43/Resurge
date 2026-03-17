import SwiftUI

struct ArticleReaderView: View {
    @EnvironmentObject var environment: AppEnvironment

    let article: RecoveryArticle

    @AppStorage private var isBookmarked: Bool
    @State private var showShareSheet = false

    init(article: RecoveryArticle) {
        self.article = article
        self._isBookmarked = AppStorage(wrappedValue: false, "bookmark_\(article.id)")
    }

    private var isPremiumUser: Bool {
        environment.entitlementManager.isPremium
    }

    private var isLocked: Bool {
        article.isPremium && !isPremiumUser
    }

    private var paragraphs: [String] {
        article.body.components(separatedBy: "\n\n").filter { !$0.isEmpty }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppStyle.largeSpacing) {
                    // MARK: - Header
                    headerSection

                    // MARK: - Title
                    Text(article.title)
                        .font(Typography.largeTitle)
                        .foregroundColor(.textPrimary)

                    // MARK: - Body
                    bodySection

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.top, AppStyle.spacing)
            }

            // MARK: - Bottom Actions Bar
            VStack {
                Spacer()
                actionsBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["\(article.title)\n\n\(article.summary)"])
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 10) {
            // Framework badge
            HStack(spacing: 5) {
                Image(systemName: article.framework.iconName)
                    .font(.system(size: 11))
                Text(article.framework.rawValue)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(article.framework.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(article.framework.color.opacity(0.15))
            .cornerRadius(8)

            // Read time
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                Text(article.readTimeLabel)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.textSecondary)

            Spacer()
        }
    }

    // MARK: - Body

    @ViewBuilder
    private var bodySection: some View {
        if isLocked {
            lockedBody
        } else {
            fullBody
        }
    }

    private var fullBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(6)
            }

            // Inline disclaimer
            VStack(alignment: .leading, spacing: 8) {
                RainbowDivider()
                    .padding(.vertical, 8)

                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.neonOrange)
                    Text("Disclaimer")
                        .font(.system(size: 12).weight(.bold))
                        .foregroundColor(.neonOrange)
                }

                Text("This content is for educational and informational purposes only. It does not constitute medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional before making changes to your health routine. If you are in crisis, call 988 (Suicide & Crisis Lifeline) or SAMHSA at 1-800-662-4357.")
                    .font(.system(size: 11))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            .padding(AppStyle.cardPadding)
            .background(Color.neonOrange.opacity(0.05))
            .cornerRadius(AppStyle.smallCornerRadius)
        }
    }

    private var lockedBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Show first paragraph
            if let first = paragraphs.first {
                Text(first)
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(6)
            }

            // Blurred preview of next paragraph
            if paragraphs.count > 1 {
                Text(paragraphs[1])
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(6)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .white.opacity(0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(.top, 16)
            }

            // Premium unlock prompt
            VStack(spacing: AppStyle.spacing) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.neonGold)

                Text("Unlock Premium to read more")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)

                Text("Get access to all recovery articles, tools, and programs.")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    // Premium upgrade handled by EntitlementManager
                } label: {
                    Text("Upgrade to Premium")
                }
                .buttonStyle(RainbowButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppStyle.largeSpacing)
        }
    }

    // MARK: - Actions Bar

    private var actionsBar: some View {
        HStack(spacing: AppStyle.largeSpacing) {
            // Bookmark toggle
            Button {
                isBookmarked.toggle()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(isBookmarked ? .neonCyan : .textSecondary)
                    Text(isBookmarked ? "Saved" : "Save")
                        .font(Typography.footnote)
                        .foregroundColor(isBookmarked ? .neonCyan : .textSecondary)
                }
            }

            // Sources (only if article has citations)
            if !article.citations.isEmpty {
                NavigationLink(destination: SourcesView(citations: article.citations)) {
                    VStack(spacing: 4) {
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.textSecondary)
                        Text("Sources")
                            .font(Typography.footnote)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            // Share
            Button {
                showShareSheet = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondary)
                    Text("Share")
                        .font(Typography.footnote)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            Color.cardBackground
                .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
        )
    }
}

// MARK: - Share Sheet (UIKit Bridge)

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct ArticleReaderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArticleReaderView(
                article: RecoveryLibrary.allArticles[0]
            )
            .environmentObject(AppEnvironment.preview)
        }
    }
}
