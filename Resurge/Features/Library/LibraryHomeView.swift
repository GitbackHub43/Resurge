import SwiftUI
import CoreData

struct LibraryHomeView: View {
    @EnvironmentObject var environment: AppEnvironment

    enum LibraryCategory: String, CaseIterable {
        case articles = "Articles"
        case videos = "Videos"
        case meditations = "Meditations"
        case bookmarks = "Bookmarks"

        var iconName: String {
            switch self {
            case .articles:    return "doc.text.fill"
            case .videos:      return "play.rectangle.fill"
            case .meditations: return "leaf.fill"
            case .bookmarks:   return "bookmark.fill"
            }
        }
    }

    @State private var selectedCategory: LibraryCategory = .articles
    @State private var searchText: String = ""

    private var libraryItems: [LibraryItem] {
        // Convert RecoveryLibrary articles to LibraryItems
        var items: [LibraryItem] = RecoveryLibrary.allArticles.map { article in
            LibraryItem(
                id: article.id,
                title: article.title,
                summary: article.summary,
                category: "Articles",
                contentType: .article,
                body: article.body,
                isPremium: article.isPremium
            )
        }

        // Add meditation content
        items.append(contentsOf: [
            LibraryItem(id: "med-1", title: "Body Scan for Cravings", summary: "A guided body scan to observe and release craving sensations.", category: "Meditations", contentType: .meditation, body: "Find a comfortable position. Close your eyes. Begin by bringing your attention to the top of your head.\n\nNotice any tension or sensations there. Don't try to change anything — just observe.\n\nSlowly move your attention down to your forehead... your eyes... your jaw. Notice if you're clenching. Let it soften.\n\nBring awareness to your throat and neck. Then your shoulders. These are common places where stress hides.\n\nMove down through your chest. This is where many people feel cravings — a tightness, a pull. If you feel it, name it: 'I notice tightness in my chest.' Don't fight it. Just observe it like a scientist studying data.\n\nContinue through your stomach, your hands, your legs, your feet.\n\nNow take three deep breaths. With each exhale, imagine the craving dissolving like mist.\n\nYou've just observed your craving without acting on it. That is real strength.", isPremium: false),
            LibraryItem(id: "med-2", title: "Morning Intention Setting", summary: "A 5-minute practice to start your day with clarity and purpose.", category: "Meditations", contentType: .meditation, body: "Good morning. Before you reach for your phone, before the day begins — take this moment for yourself.\n\nSit up in bed or in a chair. Feel your feet on the ground.\n\nTake three slow breaths. In through your nose... hold... out through your mouth.\n\nNow ask yourself: What kind of person do I want to be today?\n\nNot what you need to do. Who you want to be.\n\nMaybe it's patient. Maybe it's present. Maybe it's strong.\n\nHold that word in your mind. Let it fill your chest.\n\nNow set one intention: 'Today, I will [your intention].'\n\nThis doesn't have to be perfect. It just has to be honest.\n\nTake one more breath. Open your eyes. You're ready.", isPremium: false),
            LibraryItem(id: "med-3", title: "Urge Surfing Meditation", summary: "Ride the wave of craving without giving in.", category: "Meditations", contentType: .meditation, body: "Find a quiet place. Close your eyes.\n\nImagine you're standing on a beach, watching the ocean. A wave is building in the distance. This wave is your craving.\n\nWatch it approach. It's getting bigger. Notice the feeling in your body — maybe it's your stomach, your chest, your hands.\n\nThe wave is rising now. It feels powerful. Your mind says 'I can't handle this.' But you can. You've survived every wave before this one.\n\nHere it comes — the peak. This is the hardest moment. Breathe. In... and out. In... and out.\n\nNow watch: the wave is passing. It's getting smaller. The intensity is dropping.\n\nEvery craving follows this pattern. Rise, peak, fall. No wave lasts forever.\n\nYou just surfed it. You didn't need to act on it. You watched it come and go.\n\nOpen your eyes. You're still here. You're still strong.", isPremium: true),
            LibraryItem(id: "med-4", title: "Evening Gratitude Practice", summary: "End your day by recognizing what went well.", category: "Meditations", contentType: .meditation, body: "The day is ending. Before sleep takes you, take stock of what happened.\n\nThink of three things that went well today. They don't have to be big.\n\nMaybe you made it through a craving. Maybe you showed up for someone. Maybe you simply got through the day — and that counts.\n\n1. The first thing I'm grateful for is...\n2. The second thing is...\n3. The third thing is...\n\nNow think of one thing you did today that your past self would be proud of.\n\nHold that feeling. You earned it.\n\nTomorrow is another chance. Tonight, rest knowing you showed up.\n\nGoodnight.", isPremium: false),
            LibraryItem(id: "med-5", title: "Self-Compassion After a Slip", summary: "A gentle practice for when you've had a setback.", category: "Meditations", contentType: .meditation, body: "You're here. That takes courage.\n\nA setback happened. Your mind might be saying 'I failed' or 'What's the point?' Those thoughts are loud right now. But they're not facts.\n\nPut your hand on your chest. Feel your heart beating. That heart has been fighting for you every single day.\n\nRepeat after me, silently:\n\n'This is a moment of suffering. Suffering is part of being human. May I be kind to myself in this moment. May I give myself the compassion I need.'\n\nA slip is not a fall. A slip is a data point. What triggered it? What did you need? What will you do differently?\n\nYou didn't lose your progress. Every day you showed up before today still counts. Every craving you resisted still happened. Every tool you used still strengthened you.\n\nTomorrow, you start your plan again. Not from zero — from experience.\n\nYou are not broken. You are healing.", isPremium: false)
        ])

        return items
    }

    private var filteredItems: [LibraryItem] {
        var items = libraryItems
        switch selectedCategory {
        case .articles:
            items = items.filter { $0.contentType == .article }
        case .videos:
            items = items.filter { $0.contentType == .video }
        case .meditations:
            items = items.filter { $0.contentType == .meditation }
        case .bookmarks:
            return items // Bookmarks handled separately in real app
        }

        if !searchText.isEmpty {
            items = items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.summary.localizedCaseInsensitiveContains(searchText)
            }
        }
        return items
    }

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.subtleText)
                            TextField("Search library...", text: $searchText)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // MARK: - Category Tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(LibraryCategory.allCases, id: \.self) { cat in
                                    Button {
                                        selectedCategory = cat
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.iconName)
                                                .font(.caption)
                                            Text(cat.rawValue)
                                                .font(.subheadline.weight(.medium))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .foregroundColor(selectedCategory == cat ? .white : .appText)
                                        .background(
                                            Group {
                                                if selectedCategory == cat {
                                                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple], startPoint: .leading, endPoint: .trailing)
                                                } else {
                                                    Color.cardBackground
                                                }
                                            }
                                        )
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // MARK: - Featured Section
                        if selectedCategory != .bookmarks, let featured = filteredItems.first {
                            NavigationLink {
                                destinationView(for: featured)
                            } label: {
                                FeaturedCard(item: featured, isPremium: environment.entitlementManager.isPremium)
                            }
                            .padding(.horizontal)
                        }

                        // MARK: - Grid
                        if selectedCategory == .bookmarks {
                            NavigationLink {
                                BookmarksView()
                                    .environmentObject(environment)
                            } label: {
                                HStack {
                                    Image(systemName: "bookmark.fill")
                                        .foregroundColor(.neonGold)
                                    Text("View All Bookmarks")
                                        .font(.headline)
                                        .foregroundColor(.appText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.subtleText)
                                }
                                .padding()
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
                                .padding(.horizontal)
                            }
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(filteredItems) { item in
                                    NavigationLink {
                                        destinationView(for: item)
                                    } label: {
                                        LibraryItemCard(item: item, isPremiumUser: environment.entitlementManager.isPremium)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Library")
        }
    }

    @ViewBuilder
    private func destinationView(for item: LibraryItem) -> some View {
        switch item.contentType {
        case .article, .meditation:
            ArticleDetailView(item: item)
                .environmentObject(environment)
        case .video:
            VideoDetailView(item: item)
                .environmentObject(environment)
        }
    }
}

// MARK: - Featured Card

private struct FeaturedCard: View {
    let item: LibraryItem
    let isPremium: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: item.contentType.iconName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                Text("Featured")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.neonCyan)
                Spacer()
                if item.isPremium && !isPremium {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.premiumGold)
                }
            }
            Text(item.title)
                .font(.headline)
                .foregroundColor(.appText)
                .multilineTextAlignment(.leading)
            Text(item.summary)
                .font(.subheadline)
                .foregroundColor(.subtleText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.5)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Library Item Card

private struct LibraryItemCard: View {
    let item: LibraryItem
    let isPremiumUser: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.neonPurple.opacity(0.1))
                    .frame(height: 80)
                Image(systemName: item.contentType.iconName)
                    .font(.title)
                    .foregroundColor(.neonPurple)

                if item.isPremium && !isPremiumUser {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.premiumGold)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }

            Text(item.title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.appText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(item.summary)
                .font(.caption2)
                .foregroundColor(.subtleText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(10)
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

// MARK: - Preview

struct LibraryHomeView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        LibraryHomeView()
            .environmentObject(env)
    }
}
