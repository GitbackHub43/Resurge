import SwiftUI
import CoreData

struct AchievementsView: View {
    @EnvironmentObject var environment: AppEnvironment
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var activeHabits: FetchedResults<CDHabit>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDAchievementUnlock.unlockedAt, ascending: false)],
        animation: .default
    ) private var unlocks: FetchedResults<CDAchievementUnlock>

    @AppStorage("shardBalance") private var shardBalance: Int = 0

    @State private var selectedHabitIndex: Int = 0
    @State private var selectedBadge: MilestoneBadge?
    @State private var showConfetti = false

    // Section expansion states
    @State private var streaksExpanded = false
    @State private var timeExpanded = false
    @State private var healthExpanded = false
    @State private var journalExpanded = false
    @State private var programExpanded = false
    // otherExpanded removed — "Other Achievements" section deleted
    @State private var tracksExpanded = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Selected Habit

    private var selectedHabit: CDHabit? {
        guard !activeHabits.isEmpty else { return nil }
        return activeHabits[min(selectedHabitIndex, activeHabits.count - 1)]
    }

    private var selectedHabitName: String {
        selectedHabit?.name ?? "All"
    }

    private var unlockedKeys: Set<String> {
        let filtered: [CDAchievementUnlock]
        if let habit = selectedHabit {
            filtered = unlocks.filter { $0.habit == habit }
        } else {
            filtered = Array(unlocks)
        }
        return Set(filtered.map { $0.achievementKey })
    }

    private var allUnlockedKeys: Set<String> {
        Set(unlocks.map { $0.achievementKey })
    }

    // MARK: - Active program types from Core Data

    private var activeProgramTypes: Set<ProgramType> {
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.predicate = NSPredicate(format: "isActive == YES")
        let context = environment.viewContext
        let habits = (try? context.fetch(request)) ?? []
        return Set(habits.compactMap { ProgramType(rawValue: $0.programType) })
    }

    // MARK: - Badge Categories

    private var streakBadges: [MilestoneBadge] {
        MilestoneBadge.streakBadges
    }

    private var timeBadges: [MilestoneBadge] {
        MilestoneBadge.timeBadges
    }

    private var healthBadges: [MilestoneBadge] {
        guard let habit = selectedHabit,
              let pt = ProgramType(rawValue: habit.programType) else {
            return MilestoneBadge.healthBadges(for: .smoking) // fallback
        }
        return MilestoneBadge.healthBadges(for: pt)
    }

    private var journalBadges: [MilestoneBadge] {
        MilestoneBadge.behaviorBadges.filter { badge in
            badge.key.contains("journal")
        }
    }

    private var filteredProgramBadges: [MilestoneBadge] {
        guard let habit = selectedHabit,
              let pt = ProgramType(rawValue: habit.programType) else {
            // No habit selected — show only first habit's program badges
            if let firstHabit = activeHabits.first,
               let pt = ProgramType(rawValue: firstHabit.programType) {
                return MilestoneBadge.programBadges.filter { $0.programType == pt }
            }
            return []
        }
        return MilestoneBadge.programBadges.filter { $0.programType == pt }
    }

    // otherBadges removed
    private var _unusedOtherBadges: [MilestoneBadge] {
        let healthKeys = Set(healthBadges.map { $0.key })
        let journalKeys = Set(journalBadges.map { $0.key })
        return MilestoneBadge.behaviorBadges.filter { badge in
            !healthKeys.contains(badge.key) && !journalKeys.contains(badge.key)
        }
    }

    var body: some View {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - Habit Pill Switcher
                        if activeHabits.count > 1 {
                            achievementsHabitPillSwitcher
                        }

                        // MARK: - Vault Shop (full width button)
                        NavigationLink(destination: VaultShopView()) {
                            HStack(spacing: 14) {
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.neonGold)
                                    .shadow(color: .neonGold.opacity(0.4), radius: 6)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vault Shop")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.appText)
                                    Text("Celebrations, themes, pets & more")
                                        .font(.system(size: 11))
                                        .foregroundColor(.subtleText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.subtleText)
                            }
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color.neonGold.opacity(0.08), Color.neonOrange.opacity(0.08)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.neonGold.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        // MARK: - Badge Vault (underneath)
                        NavigationLink(destination: allBadgesView) {
                            HStack(spacing: 12) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(LinearGradient(colors: [.neonCyan, .neonPurple, .neonMagenta, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("My Collection")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.appText)
                                    Text("\(unlockedKeys.count) / \(allBadgesFlat.count) badges earned")
                                        .font(.system(size: 11))
                                        .foregroundColor(.subtleText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.subtleText)
                            }
                            .padding(14)
                            .background(Color.cardBackground)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.neonPurple.opacity(0.25), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        // MARK: - Recent Badges (horizontal scroll)
                        if !recentUnlockedBadges.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recent Badges")
                                    .font(Typography.headline)
                                    .foregroundColor(.appText)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(recentUnlockedBadges.prefix(8), id: \.key) { badge in
                                            Button { selectedBadge = badge } label: {
                                                VStack(spacing: 3) {
                                                    BadgeEmblemView(badge: badge, isUnlocked: true, size: 44)
                                                    Text(badge.title)
                                                        .font(.system(size: 8))
                                                        .foregroundColor(.subtleText)
                                                        .lineLimit(1)
                                                        .frame(width: 50)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // MARK: - Badge Categories
                        badgeSection(icon: "flame.fill", title: "Streak Badges", color: .neonOrange, badges: streakBadges, isExpanded: $streaksExpanded)
                        badgeSection(icon: "clock.fill", title: "Time Reclaimed", color: .neonGold, badges: timeBadges, isExpanded: $timeExpanded)
                        badgeSection(icon: "heart.fill", title: "Health Badges", color: .neonGreen, badges: healthBadges, isExpanded: $healthExpanded)
                        badgeSection(icon: "book.fill", title: "Journal Badges", color: .neonCyan, badges: journalBadges, isExpanded: $journalExpanded)

                        if !filteredProgramBadges.isEmpty {
                            badgeSection(icon: "star.fill", title: "Program Badges", color: .neonPurple, badges: filteredProgramBadges, isExpanded: $programExpanded)
                        }
                    }
                    .padding(.vertical)
                }

                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Achievements")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.neonGold)
                        Text("\(shardBalance)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.neonGold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.neonGold.opacity(0.12))
                    .cornerRadius(12)
                }
            }
            .sheet(item: $selectedBadge) { badge in
                BadgeDetailSheet(badge: badge, isUnlocked: unlockedKeys.contains(badge.key))
            }
            .onChange(of: activeHabits.count) { _ in
                if selectedHabitIndex >= activeHabits.count {
                    selectedHabitIndex = max(activeHabits.count - 1, 0)
                }
            }
    }

    // MARK: - Habit Pill Switcher

    private var achievementsHabitPillSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedHabitIndex = index
                        }
                    } label: {
                        Text(habit.safeDisplayName)
                            .font(Typography.caption)
                            .foregroundColor(selectedHabitIndex == index ? .white : .subtleText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                selectedHabitIndex == index
                                    ? AnyView(
                                        LinearGradient(
                                            colors: [.neonCyan, .neonPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    : AnyView(Color.cardBackground)
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        selectedHabitIndex == index
                                            ? Color.clear
                                            : Color.cardBorder,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    // MARK: - Surge Balance Card

    private var shardBalanceCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 22))
                .foregroundColor(.neonGold)
                .shadow(color: Color.neonGold.opacity(0.5), radius: 6, x: 0, y: 0)

            Text("\(shardBalance)")
                .font(Typography.title)
                .foregroundColor(.neonGold)

            Text("Surges")
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [.neonGold, .neonOrange], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.5)
        )
        .shadow(color: Color.neonGold.opacity(0.12), radius: 12)
        .padding(.horizontal)
    }

    // MARK: - Achievement Tracks Section

    // MARK: - Badge Vault Preview

    @State private var showAllBadges = false

    private var allBadgesFlat: [MilestoneBadge] {
        // Deduplicate by key to prevent inflated counts
        var seen = Set<String>()
        var result: [MilestoneBadge] = []
        for badge in streakBadges + timeBadges + healthBadges + journalBadges + filteredProgramBadges {
            if seen.insert(badge.key).inserted {
                result.append(badge)
            }
        }
        return result
    }

    private var recentUnlockedBadges: [MilestoneBadge] {
        allBadgesFlat.filter { unlockedKeys.contains($0.key) }
    }

    private var badgeVaultPreview: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack {
                Image(systemName: "shield.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.neonGold)
                Text("Badge Vault")
                    .font(Typography.headline)
                    .foregroundColor(.appText)
                Spacer()
            }
            .padding(.horizontal)

            // Show up to 6 unlocked badges in a horizontal scroll
            if recentUnlockedBadges.isEmpty {
                Text("Complete tasks to earn your first badge!")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentUnlockedBadges.prefix(6), id: \.key) { badge in
                            Button {
                                selectedBadge = badge
                            } label: {
                                VStack(spacing: 4) {
                                    BadgeEmblemView(badge: badge, isUnlocked: true, size: 50)
                                    Text(badge.title)
                                        .font(.system(size: 9))
                                        .foregroundColor(.subtleText)
                                        .lineLimit(1)
                                        .frame(width: 56)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // View All button
            NavigationLink(destination: allBadgesView) {
                HStack {
                    Text("View My Collection")
                        .font(Typography.caption.weight(.semibold))
                        .foregroundColor(.neonCyan)
                    Spacer()
                    Text("\(recentUnlockedBadges.count) earned")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.subtleText)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, AppStyle.spacing)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neonGold.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDCosmeticUnlock.unlockedAt, ascending: false)]
    ) private var cosmeticUnlocks: FetchedResults<CDCosmeticUnlock>

    private func vaultItemName(for id: String) -> String {
        let map: [String: String] = [
            "pet_dog": "Pup", "pet_cat": "Kitten", "pet_hamster": "Nibbles", "pet_owl": "Owlet",
            "celebration_rainbow_burst": "Rainbow Burst", "celebration_golden_shower": "Golden Shower",
            "celebration_neon_rain": "Neon Rain", "celebration_cosmic_sparkle": "Cosmic Sparkle",
            "theme_midnight": "Midnight", "theme_aurora": "Neon Jungle",
            "theme_sunset": "Ultraviolet", "theme_ocean": "Ocean",
            "watch_classic": "Classic Watch", "watch_digital": "Digital Watch",
            "watch_luxury": "Luxury Watch", "watch_holographic": "Holographic Watch",
            "companion_hat": "Tiny Hat", "companion_glasses": "Cool Glasses",
            "companion_crown": "Royal Crown", "companion_bowtie": "Bowtie",
        ]
        return map[id] ?? id
    }

    @ViewBuilder
    private func vaultItemPreview(for id: String) -> some View {
        switch id {
        case "pet_dog": DogPetView(size: 44)
        case "pet_cat": CatPetView(size: 44)
        case "pet_hamster": HamsterPetView(size: 44)
        case "pet_owl": OwlPetView(size: 44)
        case "celebration_rainbow_burst": RainbowBurstPreview().scaleEffect(0.55)
        case "celebration_golden_shower": GoldenShowerPreview().scaleEffect(0.55)
        case "celebration_neon_rain": NeonRainPreview().scaleEffect(0.55)
        case "celebration_cosmic_sparkle": CosmicSparklePreview().scaleEffect(0.55)
        case "theme_midnight": ThemePreview(colors: [.black, Color(hex: "0A0A0A"), Color(hex: "1A1A1A")]).scaleEffect(0.65)
        case "theme_aurora": ThemePreview(colors: [Color(hex: "021A0A"), Color(hex: "00E676"), Color(hex: "00BFA5"), Color(hex: "39FF14")]).scaleEffect(0.65)
        case "theme_sunset": ThemePreview(colors: [Color(hex: "0E0520"), Color(hex: "E040FB"), Color(hex: "AA00FF"), Color(hex: "FF4081")]).scaleEffect(0.65)
        case "theme_ocean": ThemePreview(colors: [Color(hex: "001428"), Color(hex: "0A3050"), Color(hex: "1A4570"), Color(hex: "2196F3")]).scaleEffect(0.65)
        case "default": ThemePreview(colors: [Color(hex: "05051A"), Color(hex: "10102A"), Color(hex: "1E1E42"), .neonPurple]).scaleEffect(0.65)
        case "watch_classic":
            WatchSkinPreview(style: .classic).scaleEffect(0.8)
        case "watch_digital":
            WatchSkinPreview(style: .digital).scaleEffect(0.8)
        case "watch_luxury":
            WatchSkinPreview(style: .luxury).scaleEffect(0.8)
        case "watch_holographic":
            WatchSkinPreview(style: .holographic).scaleEffect(0.8)
        case "companion_hat":
            CompanionPreview(emoji: "🎩", color: .neonGold).scaleEffect(0.7)
        case "companion_glasses":
            CompanionPreview(emoji: "🕶️", color: .neonCyan).scaleEffect(0.7)
        case "companion_crown":
            CompanionPreview(emoji: "👑", color: .neonGold).scaleEffect(0.7)
        case "companion_bowtie":
            CompanionPreview(emoji: "🎀", color: .neonMagenta).scaleEffect(0.7)
        default:
            let config = vaultItemIcon(for: id)
            ZStack {
                Circle().fill(config.color.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: config.icon).font(.system(size: 18)).foregroundColor(config.color)
            }
        }
    }

    private func vaultItemIcon(for id: String) -> (icon: String, color: Color) {
        switch id {
        case "celebration_rainbow_burst": return ("party.popper.fill", .neonMagenta)
        case "celebration_golden_shower": return ("sparkles", .neonGold)
        case "celebration_neon_rain": return ("cloud.rain.fill", .neonCyan)
        case "celebration_cosmic_sparkle": return ("star.fill", .neonPurple)
        case "theme_midnight": return ("moon.stars.fill", .white)
        case "theme_aurora": return ("leaf.fill", .neonGreen)
        case "theme_sunset": return ("bolt.fill", .neonPurple)
        case "theme_ocean": return ("water.waves", .neonBlue)
        case "watch_classic": return ("clock.fill", .neonCyan)
        case "watch_digital": return ("timer.square", .neonGreen)
        case "watch_luxury": return ("clock.badge.checkmark.fill", .neonGold)
        case "watch_holographic": return ("sparkles", .neonPurple)
        case "companion_hat": return ("hat.widebrim.fill", .neonGold)
        case "companion_glasses": return ("eyeglasses", .neonCyan)
        case "companion_crown": return ("crown.fill", .neonGold)
        case "companion_bowtie": return ("personalhotspot", .neonMagenta)
        default: return ("checkmark.seal.fill", .neonGold)
        }
    }

    private var purchasedItemNames: [String] {
        let idToName: [String: String] = [
            "pet_dog": "Pup", "pet_cat": "Kitten", "pet_hamster": "Nibbles", "pet_owl": "Owlet",
            "celebration_rainbow_burst": "Rainbow Burst", "celebration_golden_shower": "Golden Shower",
            "celebration_neon_rain": "Neon Rain", "celebration_cosmic_sparkle": "Cosmic Sparkle",
            "theme_midnight": "Midnight", "theme_aurora": "Neon Jungle",
            "theme_sunset": "Ultraviolet", "theme_ocean": "Ocean",
            "watch_classic": "Classic Watch", "watch_digital": "Digital Watch",
            "watch_luxury": "Luxury Watch", "watch_holographic": "Holographic Watch",
            "companion_hat": "Tiny Hat", "companion_glasses": "Cool Glasses",
            "companion_crown": "Royal Crown", "companion_bowtie": "Bowtie",
        ]
        return cosmeticUnlocks.compactMap { idToName[$0.cosmeticId] }
    }

    private var allBadgesView: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    // Earned badges section
                    if !recentUnlockedBadges.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Earned Badges")
                                .font(Typography.headline)
                                .foregroundColor(.appText)
                                .padding(.horizontal)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 12)], spacing: 16) {
                        ForEach(recentUnlockedBadges, id: \.key) { badge in
                            Button {
                                selectedBadge = badge
                            } label: {
                                VStack(spacing: 4) {
                                    BadgeEmblemView(
                                        badge: badge,
                                        isUnlocked: true,
                                        size: 56
                                    )
                                    Text(badge.title)
                                        .font(.system(size: 9))
                                        .foregroundColor(.subtleText)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 64)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.top, AppStyle.spacing)

                    // Purchased vault items
                    if !purchasedItemNames.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vault Purchases")
                                .font(Typography.headline)
                                .foregroundColor(.appText)
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], spacing: 12) {
                                ForEach(cosmeticUnlocks, id: \.id) { unlock in
                                    VStack(spacing: 4) {
                                        vaultItemPreview(for: unlock.cosmeticId)
                                            .frame(width: 60, height: 60)
                                        Text(vaultItemName(for: unlock.cosmeticId))
                                            .font(.system(size: 9))
                                            .foregroundColor(.subtleText)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(Color.neonGold.opacity(0.04))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, AppStyle.screenPadding)
                        }
                    }

                    if recentUnlockedBadges.isEmpty && purchasedItemNames.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "trophy")
                                .font(.system(size: 48))
                                .foregroundColor(.subtleText.opacity(0.3))
                            Text("Nothing earned yet")
                                .font(Typography.headline)
                                .foregroundColor(.subtleText)
                            Text("Complete your daily loop and hit milestones to fill your collection.")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("My Collection")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var achievementTracksSection: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    tracksExpanded.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.neonCyan)

                    Text("Achievement Tracks")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.appText)

                    Spacer()

                    Image(systemName: tracksExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
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
                        .opacity(0.3)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)

            if tracksExpanded {
                VStack(spacing: 10) {
                    ForEach(MilestoneBadge.allTracks, id: \.name) { track in
                        trackProgressRow(
                            trackName: track.name,
                            badges: track.badges,
                            unlockedKeys: unlockedKeys
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        .padding(.bottom, 8)
    }

    private func trackProgressRow(trackName: String, badges: [MilestoneBadge], unlockedKeys: Set<String>) -> some View {
        let unlockedTiers = badges.filter { unlockedKeys.contains($0.key) }
        let currentTier = unlockedTiers.map { $0.tier ?? 0 }.max() ?? 0
        let nextBadge = badges.first { ($0.tier ?? 0) == currentTier + 1 }
        let currentCount = UserDefaults.standard.integer(forKey: "track_\(trackName.replacingOccurrences(of: " ", with: "_").lowercased())_count")
        let nextTarget = nextBadge?.requiredCount ?? badges.last?.requiredCount ?? 1
        let progress = nextTarget > 0 ? min(Double(currentCount) / Double(nextTarget), 1.0) : 1.0
        let iconName = badges.first?.iconName ?? "star.fill"

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.neonCyan.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(.neonCyan)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trackName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.appText)

                    Spacer()

                    Text(currentTier > 0 ? "Tier \(currentTier)" : "Unstarted")
                        .font(.caption.weight(.medium))
                        .foregroundColor(currentTier > 0 ? .neonCyan : .subtleText)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.neonCyan, .neonPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(progress), height: 6)
                    }
                }
                .frame(height: 6)

                Text("\(currentCount) / \(nextTarget)")
                    .font(.caption2)
                    .foregroundColor(.subtleText)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(Color.neonCyan.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Collapsible Badge Section

    private func badgeSection(
        icon: String,
        title: String,
        color: Color,
        badges: [MilestoneBadge],
        isExpanded: Binding<Bool>
    ) -> some View {
        let unlockedCount = badges.filter { unlockedKeys.contains($0.key) }.count

        return VStack(spacing: 0) {
            // Section Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.wrappedValue.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)

                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.appText)

                    Spacer()

                    Text("\(unlockedCount)/\(badges.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(color)

                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
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
                        .opacity(0.3)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)

            // Badge Grid (collapsible)
            if isExpanded.wrappedValue {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(badges) { badge in
                        let isUnlocked = unlockedKeys.contains(badge.key)
                        BadgeCard(badge: badge, isUnlocked: isUnlocked)
                            .onTapGesture {
                                selectedBadge = badge
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Badge Card

private struct BadgeCard: View {
    let badge: MilestoneBadge
    let isUnlocked: Bool
    @AppStorage("isPremium") private var isPremium: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            BadgeEmblemView(badge: badge, isUnlocked: isUnlocked, size: 60)

            Text(badge.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isUnlocked ? .appText : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if badge.category == .time && badge.requiredDays > 0 {
                Text("\(badge.requiredDays)h reclaimed")
                    .font(.caption)
                    .foregroundColor(.subtleText)
            } else if badge.requiredDays > 0 {
                Text("\(badge.requiredDays) days")
                    .font(.caption)
                    .foregroundColor(.subtleText)
            }

            if badge.isPremium && !isUnlocked && !isPremium {
                HStack(spacing: 3) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                    Text("Premium")
                        .font(.caption2)
                }
                .foregroundColor(.premiumGold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isUnlocked
                        ? LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: isUnlocked ? 1.5 : 0
                )
                .opacity(0.5)
        )
        .shadow(color: isUnlocked ? Color.neonPurple.opacity(0.12) : Color.clear, radius: 12)
    }
}

// MARK: - Badge Detail Sheet

private struct BadgeDetailSheet: View {
    let badge: MilestoneBadge
    let isUnlocked: Bool
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            BadgeEmblemView(badge: badge, isUnlocked: isUnlocked, size: 120)

            Text(badge.title)
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            if let pt = badge.programType {
                Text(pt.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.neonPurple)
            }

            Text(badge.description)
                .font(.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if isUnlocked {
                Label("Unlocked", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundColor(.neonGreen)
            } else if badge.requiredDays > 0 {
                Text("Reach \(badge.requiredDays) days to unlock")
                    .font(.subheadline)
                    .foregroundColor(.subtleText)
            }

            Spacer()

            Button("Done") { presentationMode.wrappedValue.dismiss() }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: Color.neonPurple.opacity(0.4), radius: 12, y: 4)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: - Preview

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        AchievementsView()
            .environment(\.managedObjectContext, env.viewContext)
            .environmentObject(env)
    }
}
