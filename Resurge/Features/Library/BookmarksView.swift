import SwiftUI
import CoreData

struct BookmarksView: View {
    @EnvironmentObject var environment: AppEnvironment

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDLibraryBookmark.createdAt, ascending: false)],
        animation: .default
    ) private var bookmarks: FetchedResults<CDLibraryBookmark>

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if bookmarks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 48))
                        .foregroundColor(Color.neonPurple.opacity(0.4))
                    Text("No bookmarks yet")
                        .font(.headline)
                        .foregroundColor(.appText)
                    Text("Bookmark articles, videos, and meditations to find them easily later.")
                        .font(.subheadline)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                List {
                    ForEach(bookmarks, id: \.id) { bookmark in
                        HStack(spacing: 14) {
                            Image(systemName: "bookmark.fill")
                                .font(.title3)
                                .foregroundColor(.neonGold)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(bookmark.articleKey)
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                Text("Saved \(Self.dateFormatter.string(from: bookmark.createdAt))")
                                    .font(.caption)
                                    .foregroundColor(.subtleText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.subtleText)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.cardBackground)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                environment.viewContext.delete(bookmark)
                                environment.coreDataStack.save()
                            } label: {
                                Label("Remove", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Bookmarks")
    }
}

// MARK: - Preview

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            BookmarksView()
                .environmentObject(env)
                .environment(\.managedObjectContext, env.viewContext)
        }
    }
}
