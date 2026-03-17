import SwiftUI
import CoreData

struct VideoDetailView: View {
    @EnvironmentObject var environment: AppEnvironment

    let item: LibraryItem

    @State private var isBookmarked = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDLibraryBookmark.createdAt, ascending: false)]
    ) private var bookmarks: FetchedResults<CDLibraryBookmark>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Video Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.85))
                        .aspectRatio(16/9, contentMode: .fit)

                    VStack(spacing: 12) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.white.opacity(0.9))
                        Text("Tap to play")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                        .opacity(0.5)
                )

                // MARK: - Title
                Text(item.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.appText)

                if item.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                        Text("Premium Content")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.premiumGold)
                }

                // MARK: - Description
                Text(item.body)
                    .font(.body)
                    .foregroundColor(.appText)
                    .lineSpacing(4)

                if let url = item.videoURL {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .font(.caption)
                        Text(url)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.subtleText)
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleBookmark()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .neonGold : .neonCyan)
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

struct VideoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            VideoDetailView(item: LibraryItem(
                id: "video_preview",
                title: "Recovery Success Stories",
                summary: "Inspiring stories from real people.",
                category: "Videos",
                contentType: .video,
                body: "Watch inspiring stories from people who have successfully overcome their habits. These real-life accounts demonstrate that lasting change is possible.",
                videoURL: "https://example.com/video",
                isPremium: true
            ))
            .environmentObject(env)
            .environment(\.managedObjectContext, env.viewContext)
        }
    }
}
