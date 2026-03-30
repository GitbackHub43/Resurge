import SwiftUI
import CoreData

// MARK: - VaultItem Model

struct VaultItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let cost: Int
    let category: String
}

// MARK: - Vault Shop Data

private enum VaultShopData {
    static let celebrationPacks: [VaultItem] = [
        VaultItem(id: "celebration_rainbow_burst", name: "Rainbow Burst", description: "Rainbow explosion plays every time you complete all 3 daily loop tasks", icon: "party.popper.fill", cost: 50, category: "Celebration Packs"),
        VaultItem(id: "celebration_golden_shower", name: "Golden Shower", description: "Gold rain pours down the screen when you hit a new streak milestone", icon: "sparkles", cost: 100, category: "Celebration Packs"),
        VaultItem(id: "celebration_neon_rain", name: "Neon Rain", description: "Neon streaks fall across the screen every time you resist a craving", icon: "cloud.rain.fill", cost: 150, category: "Celebration Packs"),
        VaultItem(id: "celebration_cosmic_sparkle", name: "Cosmic Sparkle", description: "Stars explode across the screen when you unlock a new badge", icon: "star.fill", cost: 200, category: "Celebration Packs")
    ]

    static let watchSkins: [VaultItem] = [
        VaultItem(id: "watch_classic", name: "Classic", description: "", icon: "clock.fill", cost: 100, category: "Watch Skins"),
        VaultItem(id: "watch_digital", name: "Digital", description: "", icon: "timer.square", cost: 150, category: "Watch Skins"),
        VaultItem(id: "watch_luxury", name: "Luxury", description: "", icon: "clock.badge.checkmark.fill", cost: 250, category: "Watch Skins"),
        VaultItem(id: "watch_holographic", name: "Holographic", description: "", icon: "sparkles", cost: 400, category: "Watch Skins")
    ]

    static let appThemes: [VaultItem] = [
        VaultItem(id: "default", name: "Default", description: "Classic deep navy with rainbow accents", icon: "paintbrush.fill", cost: 0, category: "App Themes"),
        VaultItem(id: "theme_midnight", name: "Midnight", description: "Deep blue-black gradient", icon: "moon.stars.fill", cost: 200, category: "App Themes"),
        VaultItem(id: "theme_aurora", name: "Neon Jungle", description: "Glowing emerald greens and electric teals", icon: "leaf.fill", cost: 300, category: "App Themes"),
        VaultItem(id: "theme_sunset", name: "Ultraviolet", description: "Deep vivid purples and hot electric pinks", icon: "bolt.fill", cost: 300, category: "App Themes"),
        VaultItem(id: "theme_ocean", name: "Ocean", description: "Deep sea blue gradient", icon: "water.waves", cost: 400, category: "App Themes")
    ]

    static let companionPets: [VaultItem] = [
        VaultItem(id: "pet_dog", name: "Pup", description: "A loyal puppy that wags its tail", icon: "pawprint.fill", cost: 500, category: "Your Companion"),
        VaultItem(id: "pet_cat", name: "Kitten", description: "A curious kitten with green eyes and a swaying tail", icon: "pawprint.fill", cost: 500, category: "Your Companion"),
        VaultItem(id: "pet_hamster", name: "Nibbles", description: "A chubby baby hamster with puffy cheeks", icon: "pawprint.fill", cost: 600, category: "Your Companion"),
        VaultItem(id: "pet_owl", name: "Owlet", description: "A mystical white owl with galaxy eyes that tilts its head", icon: "pawprint.fill", cost: 800, category: "Your Companion")
    ]

    static let companionAccessories: [VaultItem] = [
        VaultItem(id: "companion_hat", name: "Tiny Hat", description: "A cute top hat for your companion", icon: "hat.widebrim.fill", cost: 150, category: "Accessories"),
        VaultItem(id: "companion_glasses", name: "Cool Glasses", description: "Stylish sunglasses for your companion", icon: "eyeglasses", cost: 200, category: "Accessories"),
        VaultItem(id: "companion_bowtie", name: "Bowtie", description: "A dapper little bowtie for your companion", icon: "personalhotspot", cost: 250, category: "Accessories"),
        VaultItem(id: "companion_crown", name: "Royal Crown", description: "A golden crown fit for a recovery champion", icon: "crown.fill", cost: 300, category: "Accessories")
    ]
}

// MARK: - VaultShopView

struct VaultShopView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("shardBalance") private var shardBalance: Int = 0
    @AppStorage("selectedTheme") private var selectedTheme: String = "default"
    @AppStorage("isPremium") private var isPremium: Bool = false
    @State private var showPurchaseConfirm = false
    @State private var selectedItem: VaultItem?
    @State private var purchasedItems: Set<String> = []

    // Items locked behind premium — users must buy premium first, then spend Surges
    private let premiumOnlyIds: Set<String> = [
        "celebration_golden_shower", "celebration_neon_rain", "celebration_cosmic_sparkle",
        "theme_aurora", "theme_sunset", "theme_ocean",
        "pet_cat", "pet_hamster", "pet_owl",
        "companion_glasses", "companion_crown", "companion_bowtie",
        "watch_digital", "watch_luxury", "watch_holographic"
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    // MARK: - Surge Balance Header
                    shardBalanceHeader

                    // MARK: - Shop Sections
                    shopSection(
                        icon: "party.popper.fill",
                        title: "Celebration Packs",
                        color: .neonMagenta,
                        items: VaultShopData.celebrationPacks
                    )

                    shopSection(
                        icon: "clock.fill",
                        title: "Watch Skins",
                        color: .neonPurple,
                        items: VaultShopData.watchSkins,
                        subtitle: "Replaces the clock on your home screen next to your recovery timer"
                    )

                    shopSection(
                        icon: "paintpalette.fill",
                        title: "App Themes",
                        color: .neonCyan,
                        items: VaultShopData.appThemes
                    )

                    shopSection(
                        icon: "pawprint.fill",
                        title: "Your Companion",
                        color: .neonGreen,
                        items: VaultShopData.companionPets,
                        subtitle: "Sits on every tab to keep you company"
                    )

                    shopSection(
                        icon: "sparkles",
                        title: "Companion Accessories",
                        color: .neonGold,
                        items: VaultShopData.companionAccessories
                    )

                    Spacer(minLength: AppStyle.largeSpacing)
                }
                .padding(.top, AppStyle.spacing)
            }
        }
        .navigationTitle("Vault Shop")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadPurchasedItems() }
        .alert("Confirm Purchase", isPresented: $showPurchaseConfirm) {
            Button("Buy", role: .none) {
                if let item = selectedItem {
                    purchaseItem(item)
                }
            }
            Button("Cancel", role: .cancel) {
                selectedItem = nil
            }
        } message: {
            if let item = selectedItem {
                Text("Spend \(item.cost) surges on \(item.name)?")
            }
        }
    }

    // MARK: - Surge Balance Header

    private var shardBalanceHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 28))
                .foregroundColor(.neonGold)
                .shadow(color: Color.neonGold.opacity(0.5), radius: 8, x: 0, y: 0)

            Text("\(shardBalance)")
                .font(Typography.counterLarge)
                .foregroundColor(.neonGold)

            Text("Surges")
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            Spacer()
        }
        .rainbowCard()
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Shop Section

    private func shopSection(icon: String, title: String, color: Color, items: [VaultItem], subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                    Text(title)
                        .font(Typography.headline)
                        .foregroundColor(.appText)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                        .padding(.leading, 26)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)

            LazyVStack(spacing: AppStyle.spacing) {
                ForEach(items) { item in
                    let isLocked = premiumOnlyIds.contains(item.id) && !isPremium
                    VaultItemCard(
                        item: item,
                        isPurchased: purchasedItems.contains(item.id),
                        canAfford: shardBalance >= item.cost,
                        isPremiumLocked: isLocked,
                        onBuy: {
                            selectedItem = item
                            showPurchaseConfirm = true
                        }
                    )
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    // MARK: - Purchase Logic

    private func purchaseItem(_ item: VaultItem) {
        guard shardBalance >= item.cost else { return }
        shardBalance -= item.cost

        let wallet = CDRewardWallet.fetchOrCreate(in: viewContext)
        wallet.shardsBalance -= Int64(item.cost)

        CDCosmeticUnlock.create(in: viewContext, cosmeticId: item.id)

        do {
            try viewContext.save()
        } catch {
            print("Failed to save vault purchase: \(error.localizedDescription)")
        }

        purchasedItems.insert(item.id)

        // If it's a theme, activate it immediately
        if item.id.hasPrefix("theme_") {
            selectedTheme = item.id
            ThemeColors.shared.refresh()
        }

        // If it's a celebration pack, mark as owned for the trigger system
        if item.id.hasPrefix("celebration_"), let type = CelebrationType(rawValue: item.id) {
            CelebrationManager.markOwned(type)
        }

        // If it's a pet, set as active companion
        if item.id.hasPrefix("pet_") {
            UserDefaults.standard.set(item.id, forKey: "activePet")
        }

        // If it's a watch skin, equip it immediately
        if item.id.hasPrefix("watch_") {
            UserDefaults.standard.set(item.id, forKey: "equippedWatchSkin")
        }

        selectedItem = nil
    }

    // MARK: - Load Purchased Items

    private func loadPurchasedItems() {
        let request: NSFetchRequest<CDCosmeticUnlock> = NSFetchRequest(entityName: "CDCosmeticUnlock")
        do {
            let unlocks = try viewContext.fetch(request)
            purchasedItems = Set(unlocks.map { $0.cosmeticId })
            // Default theme is always owned (free)
            purchasedItems.insert("default")
            // Sync celebration ownership for trigger system
            for id in purchasedItems {
                if id.hasPrefix("celebration_"), let type = CelebrationType(rawValue: id) {
                    CelebrationManager.markOwned(type)
                }
            }
        } catch {
            print("Failed to load cosmetic unlocks: \(error.localizedDescription)")
        }

        // Sync balance from Core Data to AppStorage
        let wallet = CDRewardWallet.fetchOrCreate(in: viewContext)
        // DEBUG: Give 4000 surges for testing - REMOVE BEFORE RELEASE
        if wallet.shardsBalance < 4000 {
            wallet.shardsBalance = 4000
            try? viewContext.save()
        }
        shardBalance = Int(wallet.shardsBalance)
    }
}

// MARK: - Vault Item Card

private struct VaultItemCard: View {
    let item: VaultItem
    let isPurchased: Bool
    let canAfford: Bool
    var isPremiumLocked: Bool = false
    let onBuy: () -> Void
    @AppStorage("selectedTheme") private var selectedTheme: String = "default"
    @AppStorage("activePet") private var activePet: String = ""
    @AppStorage("showPetOnScreens") private var showPetOnScreens: Bool = true
    @AppStorage("showWatchSkin") private var showWatchSkin: Bool = true
    @AppStorage("equippedAccessories") private var equippedAccessories: String = ""
    @AppStorage("equippedWatchSkin") private var equippedWatchSkin: String = ""

    var body: some View {
        HStack(spacing: 12) {
            itemPreview(for: item)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(Typography.headline)
                    .foregroundColor(.appText)

                Text(item.description)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if isPremiumLocked {
                VStack(spacing: 2) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGold)
                    Text("Premium")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.premiumGold)
                }
            } else if isPurchased {
                if item.category == "App Themes" {
                    let isActive = selectedTheme == item.id
                    Button {
                        selectedTheme = item.id
                        ThemeColors.shared.refresh()
                    } label: {
                        Text(isActive ? "Active" : "Apply")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(isActive ? .neonGreen : .neonCyan)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isActive ? Color.neonGreen.opacity(0.15) : Color.neonCyan.opacity(0.15))
                            .cornerRadius(12)
                    }
                } else if item.id.hasPrefix("pet_") {
                    let isActive = activePet == item.id
                    Button {
                        if isActive {
                            activePet = ""
                            showPetOnScreens = false
                        } else {
                            activePet = item.id
                            showPetOnScreens = true
                        }
                    } label: {
                        Text(isActive ? "Deactivate" : "Activate")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(isActive ? .neonOrange : .neonCyan)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isActive ? Color.neonOrange.opacity(0.15) : Color.neonCyan.opacity(0.15))
                            .cornerRadius(12)
                    }
                } else if item.id.hasPrefix("companion_") {
                    let isEquipped = equippedAccessories.contains(item.id)
                    Button {
                        var accessories = Set(equippedAccessories.components(separatedBy: ",").filter { !$0.isEmpty })
                        if isEquipped {
                            accessories.remove(item.id)
                        } else {
                            accessories.insert(item.id)
                        }
                        equippedAccessories = accessories.sorted().joined(separator: ",")
                    } label: {
                        Text(isEquipped ? "Remove" : "Equip")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(isEquipped ? .neonOrange : .neonGold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isEquipped ? Color.neonOrange.opacity(0.15) : Color.neonGold.opacity(0.15))
                            .cornerRadius(12)
                    }
                } else if item.id.hasPrefix("watch_") {
                    let isEquipped = equippedWatchSkin == item.id
                    Button {
                        if isEquipped {
                            equippedWatchSkin = ""
                            showWatchSkin = false
                        } else {
                            equippedWatchSkin = item.id
                            showWatchSkin = true
                        }
                    } label: {
                        Text(isEquipped ? "Remove" : "Equip")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(isEquipped ? .neonOrange : .neonPurple)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isEquipped ? Color.neonOrange.opacity(0.15) : Color.neonPurple.opacity(0.15))
                            .cornerRadius(12)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.neonGreen)
                        Text("Owned")
                            .font(Typography.caption)
                            .foregroundColor(.neonGreen)
                    }
                }
            } else if canAfford {
                Button(action: onBuy) {
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 10))
                        Text("\(item.cost)")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppStyle.smallCornerRadius)
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 10))
                        Text("\(item.cost)")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundColor(.gray)

                    Text("Need \(item.cost - (UserDefaults.standard.integer(forKey: "shardBalance"))) more")
                        .font(.system(size: 9))
                        .foregroundColor(.subtleText)
                }
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    isPurchased
                        ? LinearGradient(colors: [.neonGreen.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ),
                    lineWidth: 1
                )
                .opacity(isPurchased ? 0.6 : 0.3)
        )
        .shadow(color: Color.neonPurple.opacity(0.08), radius: 8)
    }

    @ViewBuilder
    private func itemPreview(for item: VaultItem) -> some View {
        switch item.id {
        case "celebration_rainbow_burst": RainbowBurstPreview()
        case "celebration_golden_shower": GoldenShowerPreview()
        case "celebration_neon_rain": NeonRainPreview()
        case "celebration_cosmic_sparkle": CosmicSparklePreview()
        case "watch_classic": WatchSkinPreview(style: .classic)
        case "watch_digital": WatchSkinPreview(style: .digital)
        case "watch_luxury": WatchSkinPreview(style: .luxury)
        case "watch_holographic": WatchSkinPreview(style: .holographic)
        case "powerup_streak_shield": PowerUpPreview(icon: "shield.checkered", color: .neonGreen)
        case "powerup_journal_prompts": PowerUpPreview(icon: "text.book.closed.fill", color: .neonBlue)
        case "powerup_weekly_insights": PowerUpPreview(icon: "chart.line.uptrend.xyaxis", color: .neonPurple)
        case "powerup_custom_milestones": PowerUpPreview(icon: "text.bubble.fill", color: .neonGold)
        case "default": ThemePreview(colors: [Color(hex: "05051A"), Color(hex: "10102A"), Color(hex: "1E1E42"), .neonPurple])
        case "theme_midnight": ThemePreview(colors: [.black, Color(hex: "0A0A0A"), Color(hex: "1A1A1A")])
        case "theme_aurora": ThemePreview(colors: [Color(hex: "021A0A"), Color(hex: "00E676"), Color(hex: "00BFA5"), Color(hex: "39FF14")])
        case "theme_sunset": ThemePreview(colors: [Color(hex: "0E0520"), Color(hex: "E040FB"), Color(hex: "AA00FF"), Color(hex: "FF4081")])
        case "theme_ocean": ThemePreview(colors: [Color(hex: "001428"), Color(hex: "0A3050"), Color(hex: "1A4570"), Color(hex: "2196F3")])
        case "pet_dog": DogPetView(size: 50).frame(width: 65, height: 65).clipped()
        case "pet_cat": CatPetView(size: 50).frame(width: 65, height: 65).clipped()
        case "pet_hamster": HamsterPetView(size: 50).frame(width: 65, height: 65).clipped()
        case "pet_owl": OwlPetView(size: 50).frame(width: 65, height: 65).clipped()
        case "companion_hat": CompanionPreview(emoji: "🎩", color: .neonGold)
        case "companion_glasses": CompanionPreview(emoji: "🕶️", color: .neonCyan)
        case "companion_crown": CompanionPreview(emoji: "👑", color: .neonGold)
        case "companion_bowtie": CompanionPreview(emoji: "🎀", color: .neonMagenta)
        default:
            ZStack {
                Circle().fill(Color(hex: "1A1A2E")).frame(width: 60, height: 60)
                Image(systemName: item.icon).font(.system(size: 28)).foregroundColor(.neonGold)
            }
        }
    }

    private var cardColor: Color {
        switch item.category {
        case "Celebration Packs": return .neonMagenta
        case "Power-Ups": return .neonPurple
        case "App Themes": return .neonCyan
        case "Your Companion": return .neonGreen
        case "Accessories": return .neonGold
        default: return .neonGold
        }
    }
}

// MARK: - Animated Previews

// Rainbow Burst — colorful explosion bursting outward
struct RainbowBurstPreview: View {
    @State private var phase: CGFloat = 0
    private let colors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { i in
                let angle = Double(i) * 20
                let r: CGFloat = 8 + phase * 28
                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: 5 - phase * 2, height: 5 - phase * 2)
                    .offset(x: r * CGFloat(Foundation.cos(angle * .pi / 180)),
                            y: r * CGFloat(Foundation.sin(angle * .pi / 180)))
                    .opacity(Double(1 - phase * 0.7))
            }
        }
        .frame(width: 80, height: 80)
        .onAppear { withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) { phase = 1 } }
    }
}

// Golden Shower — individual gold drops falling from shower head at different speeds
struct GoldenShowerPreview: View {
    var body: some View {
        ZStack {
            // Shower head circle at top
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "DAA520")], startPoint: .top, endPoint: .bottom))
                .frame(width: 22, height: 22)
                .offset(y: -28)
                .shadow(color: Color(hex: "FFD700").opacity(0.6), radius: 6)

            // Individual drops — each with its own animation
            GoldRainDrop(x: -10, delay: 0.0, duration: 0.6, size: 3)
            GoldRainDrop(x: -5, delay: 0.15, duration: 0.7, size: 2)
            GoldRainDrop(x: 0, delay: 0.3, duration: 0.55, size: 3)
            GoldRainDrop(x: 5, delay: 0.1, duration: 0.65, size: 2)
            GoldRainDrop(x: 10, delay: 0.25, duration: 0.5, size: 3)
            GoldRainDrop(x: -7, delay: 0.4, duration: 0.6, size: 2)
            GoldRainDrop(x: 3, delay: 0.35, duration: 0.7, size: 2)
            GoldRainDrop(x: 7, delay: 0.05, duration: 0.55, size: 2)
            GoldRainDrop(x: -3, delay: 0.2, duration: 0.65, size: 3)
        }
        .frame(width: 80, height: 80)
        .clipped()
    }
}

// Individual gold raindrop with its own animation cycle
private struct GoldRainDrop: View {
    let x: CGFloat
    let delay: Double
    let duration: Double
    let size: CGFloat
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        Capsule()
            .fill(Color(hex: "FFD700"))
            .frame(width: size, height: size * 3)
            .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 2)
            .offset(x: x, y: -18 + offset)
            .opacity(opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        offset = 60
                    }
                    withAnimation(.easeIn(duration: duration * 0.3).repeatForever(autoreverses: false)) {
                        opacity = 0.9
                    }
                }
            }
    }
}

// Neon Rain — individual neon drops falling at different times and speeds like real rain
struct NeonRainPreview: View {
    private let colors: [Color] = [.neonCyan, .neonPurple, .neonMagenta, .neonGreen, .neonBlue, .neonOrange, .neonGold]
    var body: some View {
        ZStack {
            NeonRainDrop(x: -28, delay: 0.0, duration: 0.5, color: .neonCyan)
            NeonRainDrop(x: -20, delay: 0.3, duration: 0.7, color: .neonPurple)
            NeonRainDrop(x: -12, delay: 0.1, duration: 0.55, color: .neonMagenta)
            NeonRainDrop(x: -4, delay: 0.45, duration: 0.6, color: .neonGreen)
            NeonRainDrop(x: 4, delay: 0.2, duration: 0.65, color: .neonBlue)
            NeonRainDrop(x: 12, delay: 0.5, duration: 0.5, color: .neonOrange)
            NeonRainDrop(x: 20, delay: 0.15, duration: 0.7, color: .neonGold)
            NeonRainDrop(x: 28, delay: 0.35, duration: 0.55, color: .neonCyan)
            NeonRainDrop(x: -24, delay: 0.6, duration: 0.6, color: .neonGold)
            NeonRainDrop(x: -16, delay: 0.25, duration: 0.5, color: .neonBlue)
            NeonRainDrop(x: -8, delay: 0.55, duration: 0.65, color: .neonPurple)
            NeonRainDrop(x: 8, delay: 0.4, duration: 0.55, color: .neonMagenta)
            NeonRainDrop(x: 16, delay: 0.05, duration: 0.6, color: .neonGreen)
            NeonRainDrop(x: 24, delay: 0.7, duration: 0.5, color: .neonOrange)
        }
        .frame(width: 80, height: 80)
        .clipped()
    }
}

// Individual neon raindrop with its own staggered animation
private struct NeonRainDrop: View {
    let x: CGFloat
    let delay: Double
    let duration: Double
    let color: Color
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: 2, height: 10)
            .shadow(color: color.opacity(0.7), radius: 3)
            .offset(x: x, y: -38 + offset)
            .opacity(opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        offset = 76
                    }
                    withAnimation(.easeIn(duration: duration * 0.2).repeatForever(autoreverses: false)) {
                        opacity = 0.85
                    }
                }
            }
    }
}

// Cosmic Sparkle — deep space with twinkling stars
struct CosmicSparklePreview: View {
    @State private var twinkle = false
    var body: some View {
        ZStack {
            // Dark space background
            Circle().fill(Color(hex: "0A0A2E")).frame(width: 70, height: 70)
            // Stars twinkling at various positions
            Image(systemName: "star.fill").font(.system(size: 4)).foregroundColor(.white).offset(x: -20, y: -15).opacity(twinkle ? 0.3 : 1)
            Image(systemName: "star.fill").font(.system(size: 6)).foregroundColor(.neonGold).offset(x: 15, y: -20).opacity(twinkle ? 1 : 0.3)
            Image(systemName: "star.fill").font(.system(size: 3)).foregroundColor(.neonCyan).offset(x: -10, y: 18).opacity(twinkle ? 0.4 : 0.9)
            Image(systemName: "star.fill").font(.system(size: 5)).foregroundColor(.white).offset(x: 22, y: 10).opacity(twinkle ? 0.8 : 0.2)
            Image(systemName: "star.fill").font(.system(size: 7)).foregroundColor(.neonMagenta).offset(x: -5, y: -5).opacity(twinkle ? 0.2 : 1)
            Image(systemName: "star.fill").font(.system(size: 4)).foregroundColor(.neonGold).offset(x: 8, y: 22).opacity(twinkle ? 1 : 0.4)
            Image(systemName: "sparkle").font(.system(size: 10)).foregroundColor(.white).offset(x: 0, y: 0).opacity(twinkle ? 0.5 : 1).scaleEffect(twinkle ? 0.8 : 1.2)
        }
        .frame(width: 80, height: 80)
        .onAppear { withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { twinkle = true } }
    }
}

// Power-Up Preview — glowing icon with pulse
// Watch Skin Preview
struct WatchSkinPreview: View {
    enum Style { case classic, digital, luxury, holographic }
    let style: Style
    @State private var pulse: CGFloat = 1.0
    @State private var rainbowPhase: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "0A0A1A"))
                .frame(width: 60, height: 60)

            switch style {
            case .classic:
                Circle().stroke(Color.neonCyan, lineWidth: 2).frame(width: 50, height: 50)
                Rectangle().fill(Color.neonCyan).frame(width: 2, height: 16).offset(y: -6)
                Rectangle().fill(Color.neonCyan).frame(width: 12, height: 2).offset(x: 4)
                Circle().fill(Color.neonCyan).frame(width: 4, height: 4)

            case .digital:
                RoundedRectangle(cornerRadius: 4).stroke(Color.neonGreen, lineWidth: 2).frame(width: 46, height: 36)
                Text("12:00").font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(.neonGreen)

            case .luxury:
                // Gold diamond bezel
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "B8860B")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                Circle()
                    .fill(Color(hex: "1A1A2E"))
                    .frame(width: 44, height: 44)
                // Diamond markers at 12, 3, 6, 9
                ForEach(0..<4, id: \.self) { i in
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 5))
                        .foregroundColor(.white)
                        .offset(y: -18)
                        .rotationEffect(.degrees(Double(i) * 90))
                }
                // Elegant clock hands
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.neonGold)
                    .frame(width: 1.5, height: 12)
                    .offset(y: -4)
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white)
                    .frame(width: 1, height: 8)
                    .offset(y: -2)
                    .rotationEffect(.degrees(60))
                Circle().fill(Color.neonGold).frame(width: 3, height: 3)

            case .holographic:
                Circle()
                    .stroke(
                        AngularGradient(colors: [.neonCyan, .neonPurple, .neonMagenta, .neonGold, .neonCyan], center: .center, startAngle: .degrees(rainbowPhase), endAngle: .degrees(rainbowPhase + 360)),
                        lineWidth: 3
                    )
                    .frame(width: 50, height: 50)
                Image(systemName: "clock.fill").font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(colors: [.neonCyan, .neonPurple, .neonMagenta, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
        }
        .frame(width: 65, height: 65)
        .scaleEffect(pulse)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { pulse = 1.05 }
            if style == .holographic {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) { rainbowPhase = 360 }
            }
        }
    }
}

private struct PowerUpPreview: View {
    let icon: String
    let color: Color
    @State private var glow: Double = 0.3

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 60, height: 60)
            Circle()
                .stroke(color.opacity(0.4), lineWidth: 2)
                .frame(width: 56, height: 56)
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(color)
        }
        .frame(width: 80, height: 80)
        .shadow(color: color.opacity(glow), radius: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glow = 0.7
            }
        }
    }
}

// Theme Preview — animated gradient swatch
struct ThemePreview: View {
    let colors: [Color]
    @State private var shift = false
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(LinearGradient(colors: colors, startPoint: shift ? .topLeading : .bottomTrailing, endPoint: shift ? .bottomTrailing : .topLeading))
            .frame(width: 65, height: 65)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
            .shadow(color: colors.first?.opacity(0.4) ?? .clear, radius: 8)
            .onAppear { withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { shift = true } }
    }
}

// Companion Preview — emoji with glow bounce
struct CompanionPreview: View {
    let emoji: String
    let color: Color
    @State private var bounce: CGFloat = 0
    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.15)).frame(width: 60, height: 60)
            Circle().stroke(color.opacity(0.3), lineWidth: 2).frame(width: 56, height: 56)
            Text(emoji).font(.system(size: 32)).offset(y: bounce)
        }
        .frame(width: 80, height: 80)
        .shadow(color: color.opacity(0.4), radius: 6)
        .onAppear { withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { bounce = -5 } }
    }
}

// Cape and Wings previews removed — replaced with Glasses and Bowtie (using emoji previews)

// MARK: - Preview

struct VaultShopView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VaultShopView()
        }
        .preferredColorScheme(.dark)
    }
}
