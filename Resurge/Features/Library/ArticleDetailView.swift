import SwiftUI
import CoreData

struct ArticleDetailView: View {
    @EnvironmentObject var environment: AppEnvironment

    let item: LibraryItem

    @State private var isBookmarked = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDLibraryBookmark.createdAt, ascending: false)]
    ) private var bookmarks: FetchedResults<CDLibraryBookmark>

    private var relatedItems: [LibraryItem] {
        // In a real app this would be data-driven
        []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Category Badge
                HStack {
                    Text(item.contentType.displayName)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(8)

                    if item.isPremium {
                        HStack(spacing: 3) {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                            Text("Premium")
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundColor(.premiumGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.premiumGold.opacity(0.12))
                        .cornerRadius(8)
                    }

                    Spacer()
                }

                // MARK: - Title
                Text(item.title)
                    .font(.title.weight(.bold))
                    .foregroundColor(.appText)

                Text(item.summary)
                    .font(.subheadline)
                    .foregroundColor(.subtleText)

                Divider()

                // MARK: - Body
                Text(item.body)
                    .font(.body)
                    .foregroundColor(.appText)
                    .lineSpacing(6)

                Divider()

                // MARK: - Related Articles
                if !relatedItems.isEmpty {
                    Text("Related")
                        .font(.headline)
                        .foregroundColor(.appText)

                    ForEach(relatedItems) { related in
                        NavigationLink {
                            ArticleDetailView(item: related)
                                .environmentObject(environment)
                        } label: {
                            HStack {
                                Image(systemName: related.contentType.iconName)
                                    .foregroundColor(.neonCyan)
                                Text(related.title)
                                    .font(.subheadline)
                                    .foregroundColor(.appText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.subtleText)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 1
                                    )
                                    .opacity(0.4)
                            )
                            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    toggleBookmark()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .neonGold : .neonCyan)
                }

                Button {
                    let av = UIActivityViewController(activityItems: [item.title], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(av, animated: true)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.neonCyan)
                }
            }
        }
        .onAppear {
            isBookmarked = bookmarks.contains(where: { $0.articleKey == item.id })
        }
    }

    private func toggleBookmark() {
        let context = environment.viewContext
        if let existing = bookmarks.first(where: { $0.articleKey == item.id }) {
            context.delete(existing)
        } else {
            CDLibraryBookmark.create(in: context, articleKey: item.id)
        }
        environment.coreDataStack.save()
        isBookmarked.toggle()
    }
}

// MARK: - Preview

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            ArticleDetailView(item: LibraryItem(
                id: "preview",
                title: "Understanding Triggers",
                summary: "Learn to identify and manage your triggers.",
                category: "Articles",
                contentType: .article,
                body: "Triggers are cues that make you want to engage in a habit. They can be emotional, environmental, or social. Understanding your triggers is the first step to managing them effectively.\n\nCommon triggers include stress, boredom, social situations, and specific times of day. By identifying your personal triggers, you can develop strategies to cope with them.\n\nOne effective strategy is the 'urge surfing' technique, where you observe the craving without acting on it, knowing it will pass."
            ))
            .environmentObject(env)
            .environment(\.managedObjectContext, env.viewContext)
        }
    }
}
