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

    static let powerUps: [VaultItem] = [
        VaultItem(id: "powerup_streak_shield", name: "Streak Shield", description: "Protects your streak once if you miss a day. One-time use — buy more as needed", icon: "shield.checkered", cost: 150, category: "Power-Ups"),
        VaultItem(id: "powerup_journal_prompts", name: "Journal Prompts Pack", description: "Unlock 50+ guided reflection prompts for deeper self-discovery", icon: "text.book.closed.fill", cost: 200, category: "Power-Ups"),
        VaultItem(id: "powerup_weekly_insights", name: "Weekly Insight Report", description: "Unlock detailed weekly analytics — mood trends, craving patterns, and progress charts", icon: "chart.line.uptrend.xyaxis", cost: 300, category: "Power-Ups"),
        VaultItem(id: "powerup_custom_milestones", name: "Custom Milestone Messages", description: "Write your own motivational messages that appear when you hit streak milestones", icon: "text.bubble.fill", cost: 250, category: "Power-Ups")
    ]

    static let appThemes: [VaultItem] = [
        VaultItem(id: "theme_midnight", name: "Midnight", description: "Deep blue-black gradient", icon: "moon.stars.fill", cost: 200, category: "App Themes"),
        VaultItem(id: "theme_aurora", name: "Neon Jungle", description: "Glowing emerald greens and electric teals", icon: "leaf.fill", cost: 300, category: "App Themes"),
        VaultItem(id: "theme_sunset", name: "Ultraviolet", description: "Deep vivid purples and hot electric pinks", icon: "bolt.fill", cost: 300, category: "App Themes"),
        VaultItem(id: "theme_ocean", name: "Ocean", description: "Deep sea blue gradient", icon: "water.waves", cost: 400, category: "App Themes")
    ]

    static let companionPets: [VaultItem] = [
        VaultItem(id: "pet_dog", name: "Pup", description: "A loyal puppy that wags its tail and pants happily on your screen", icon: "pawprint.fill", cost: 500, category: "Your Companion"),
        VaultItem(id: "pet_cat", name: "Kitten", description: "A curious kitten with green eyes that licks its paw and purrs", icon: "pawprint.fill", cost: 500, category: "Your Companion"),
        VaultItem(id: "pet_hamster", name: "Nibbles", description: "A chubby baby hamster running on a tiny wheel with puffy cheeks", icon: "pawprint.fill", cost: 600, category: "Your Companion"),
        VaultItem(id: "pet_owl", name: "Owlet", description: "A mystical white baby owl with galaxy-colored eyes that tilts its head", icon: "pawprint.fill", cost: 800, category: "Your Companion")
    ]

    static let companionAccessories: [VaultItem] = [
        VaultItem(id: "companion_hat", name: "Tiny Hat", description: "A cute little hat for your companion", icon: "hat.widebrim.fill", cost: 150, category: "Accessories"),
        VaultItem(id: "companion_cape", name: "Hero Cape", description: "A flowing superhero cape for your companion", icon: "flag.fill", cost: 200, category: "Accessories"),
        VaultItem(id: "companion_crown", name: "Royal Crown", description: "A golden crown fit for a recovery champion", icon: "crown.fill", cost: 300, category: "Accessories"),
        VaultItem(id: "companion_wings", name: "Angel Wings", description: "Beautiful feathered wings for your companion", icon: "bird.fill", cost: 400, category: "Accessories")
    ]
}

// MARK: - VaultShopView

struct VaultShopView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("shardBalance") private var shardBalance: Int = 0
    @AppStorage("selectedTheme") private var selectedTheme: String = "default"
    @State private var showPurchaseConfirm = false
    @State private var selectedItem: VaultItem?
    @State private var purchasedItems: Set<String> = []

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
                        icon: "bolt.shield.fill",
                        title: "Power-Ups",
                        color: .neonPurple,
                        items: VaultShopData.powerUps
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
                        items: VaultShopData.companionPets
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

    private func shopSection(icon: String, title: String, color: Color, items: [VaultItem]) -> some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(.appText)
            }
            .padding(.horizontal, AppStyle.screenPadding)

            LazyVStack(spacing: AppStyle.spacing) {
                ForEach(items) { item in
                    VaultItemCard(
                        item: item,
                        isPurchased: purchasedItems.contains(item.id),
                        canAfford: shardBalance >= item.cost,
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

        selectedItem = nil
    }

    // MARK: - Load Purchased Items

    private func loadPurchasedItems() {
        let request: NSFetchRequest<CDCosmeticUnlock> = NSFetchRequest(entityName: "CDCosmeticUnlock")
        do {
            let unlocks = try viewContext.fetch(request)
            purchasedItems = Set(unlocks.map { $0.cosmeticId })
            // Sync celebration ownership for trigger system
            for id in purchasedItems {
                if id.hasPrefix("celebration_"), let type = CelebrationType(rawValue: id) {
                    CelebrationManager.markOwned(type)
                }
            }
        } catch {
            print("Failed to load cosmetic unlocks: \(error.localizedDescription)")
        }

        // DEBUG: Give 2000 surges for testing — REMOVE before App Store submission
        if shardBalance < 2000 {
            shardBalance = 2000
            let wallet = CDRewardWallet.fetchOrCreate(in: viewContext)
            wallet.shardsBalance = 2000
            wallet.lifetimeEarned = max(wallet.lifetimeEarned, 2000)
            try? viewContext.save()
        }
    }
}

// MARK: - Vault Item Card

private struct VaultItemCard: View {
    let item: VaultItem
    let isPurchased: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    @AppStorage("selectedTheme") private var selectedTheme: String = "default"

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

            if isPurchased {
                if item.id.hasPrefix("theme_") {
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
                    let isActive = UserDefaults.standard.string(forKey: "activePet") == item.id
                    Button {
                        UserDefaults.standard.set(item.id, forKey: "activePet")
                    } label: {
                        Text(isActive ? "Active" : "Select")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(isActive ? .neonGreen : .neonCyan)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isActive ? Color.neonGreen.opacity(0.15) : Color.neonCyan.opacity(0.15))
                            .cornerRadius(12)
                    }
                } else if item.id.hasPrefix("companion_") {
                    let equippedAccessories = UserDefaults.standard.string(forKey: "equippedAccessories") ?? ""
                    let isEquipped = equippedAccessories.contains(item.id)
                    Button {
                        var accessories = Set(equippedAccessories.components(separatedBy: ",").filter { !$0.isEmpty })
                        if isEquipped {
                            accessories.remove(item.id)
                        } else {
                            accessories.insert(item.id)
                        }
                        UserDefaults.standard.set(accessories.sorted().joined(separator: ","), forKey: "equippedAccessories")
                    } label: {
                        Text(isEquipped ? "Remove" : "Equip")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(isEquipped ? .neonOrange : .neonGold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isEquipped ? Color.neonOrange.opacity(0.15) : Color.neonGold.opacity(0.15))
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
        case "powerup_streak_shield": PowerUpPreview(icon: "shield.checkered", color: .neonGreen)
        case "powerup_journal_prompts": PowerUpPreview(icon: "text.book.closed.fill", color: .neonBlue)
        case "powerup_weekly_insights": PowerUpPreview(icon: "chart.line.uptrend.xyaxis", color: .neonPurple)
        case "powerup_custom_milestones": PowerUpPreview(icon: "text.bubble.fill", color: .neonGold)
        case "theme_midnight": ThemePreview(colors: [.black, Color(hex: "0A0A0A"), Color(hex: "1A1A1A")])
        case "theme_aurora": ThemePreview(colors: [Color(hex: "021A0A"), Color(hex: "00E676"), Color(hex: "00BFA5"), Color(hex: "39FF14")])
        case "theme_sunset": ThemePreview(colors: [Color(hex: "0E0520"), Color(hex: "E040FB"), Color(hex: "AA00FF"), Color(hex: "FF4081")])
        case "theme_ocean": ThemePreview(colors: [Color(hex: "001428"), Color(hex: "0A3050"), Color(hex: "1A4570"), Color(hex: "2196F3")])
        case "pet_dog": DogPetView(size: 55).frame(width: 65, height: 65)
        case "pet_cat": CatPetView(size: 55).frame(width: 65, height: 65)
        case "pet_hamster": HamsterPetView(size: 55).frame(width: 65, height: 65)
        case "pet_owl": OwlPetView(size: 55).frame(width: 65, height: 65)
        case "companion_hat": CompanionPreview(emoji: "🎩", color: .neonGold)
        case "companion_cape": CapePreview()
        case "companion_crown": CompanionPreview(emoji: "👑", color: .neonGold)
        case "companion_wings": WingsPreview()
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
private struct RainbowBurstPreview: View {
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
private struct GoldenShowerPreview: View {
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
private struct NeonRainPreview: View {
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
private struct CosmicSparklePreview: View {
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
private struct ThemePreview: View {
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
private struct CompanionPreview: View {
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

// Companion Cape Preview — superhero cape flowing in the wind
private struct CapePreview: View {
    @State private var wave: CGFloat = 0
    var body: some View {
        ZStack {
            Circle().fill(Color.neonMagenta.opacity(0.1)).frame(width: 65, height: 65)
            // Superhero cape — wide shoulders, narrows at bottom, flowing curves
            Path { p in
                // Left shoulder
                p.move(to: CGPoint(x: 15, y: 12))
                // Collar
                p.addLine(to: CGPoint(x: 35, y: 8))
                p.addLine(to: CGPoint(x: 40, y: 5))
                p.addLine(to: CGPoint(x: 45, y: 8))
                // Right shoulder
                p.addLine(to: CGPoint(x: 65, y: 12))
                // Right side flowing down
                p.addQuadCurve(to: CGPoint(x: 58, y: 60), control: CGPoint(x: 68, y: 35))
                // Bottom wave
                p.addQuadCurve(to: CGPoint(x: 48, y: 55), control: CGPoint(x: 54, y: 62))
                p.addQuadCurve(to: CGPoint(x: 40, y: 58), control: CGPoint(x: 44, y: 52))
                p.addQuadCurve(to: CGPoint(x: 32, y: 55), control: CGPoint(x: 36, y: 62))
                p.addQuadCurve(to: CGPoint(x: 22, y: 60), control: CGPoint(x: 26, y: 52))
                // Left side flowing up
                p.addQuadCurve(to: CGPoint(x: 15, y: 12), control: CGPoint(x: 12, y: 35))
            }
            .fill(LinearGradient(colors: [Color(hex: "DC143C"), .neonMagenta, Color(hex: "8B0000")], startPoint: .top, endPoint: .bottom))
            .frame(width: 80, height: 65)
            .offset(y: wave)
            .shadow(color: .neonMagenta.opacity(0.6), radius: 8)

            // Gold clasp at top
            Circle()
                .fill(Color.neonGold)
                .frame(width: 8, height: 8)
                .offset(y: -22 + wave)
                .shadow(color: .neonGold.opacity(0.6), radius: 3)
        }
        .frame(width: 80, height: 80)
        .onAppear { withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { wave = -3 } }
    }
}

// Companion Wings Preview — real feathered angel wings spread wide
private struct WingsPreview: View {
    @State private var flap: CGFloat = 0
    var body: some View {
        ZStack {
            Circle().fill(Color.neonCyan.opacity(0.1)).frame(width: 65, height: 65)
            // Left wing — multiple feather layers
            ZStack {
                // Outer feathers
                Path { p in
                    p.move(to: CGPoint(x: 38, y: 30))
                    p.addQuadCurve(to: CGPoint(x: 5, y: 15), control: CGPoint(x: 20, y: 10))
                    p.addQuadCurve(to: CGPoint(x: 8, y: 35), control: CGPoint(x: 2, y: 28))
                    p.addQuadCurve(to: CGPoint(x: 38, y: 42), control: CGPoint(x: 20, y: 40))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [.white, Color(hex: "E0F7FA"), .neonCyan], startPoint: .top, endPoint: .bottom))

                // Inner feathers
                Path { p in
                    p.move(to: CGPoint(x: 38, y: 32))
                    p.addQuadCurve(to: CGPoint(x: 12, y: 20), control: CGPoint(x: 25, y: 18))
                    p.addQuadCurve(to: CGPoint(x: 15, y: 36), control: CGPoint(x: 10, y: 30))
                    p.addQuadCurve(to: CGPoint(x: 38, y: 40), control: CGPoint(x: 25, y: 38))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.5))
            }
            .rotationEffect(.degrees(Double(flap) * 8.0), anchor: .trailing)

            // Right wing — mirror of left
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: 42, y: 30))
                    p.addQuadCurve(to: CGPoint(x: 75, y: 15), control: CGPoint(x: 60, y: 10))
                    p.addQuadCurve(to: CGPoint(x: 72, y: 35), control: CGPoint(x: 78, y: 28))
                    p.addQuadCurve(to: CGPoint(x: 42, y: 42), control: CGPoint(x: 60, y: 40))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [.white, Color(hex: "E0F7FA"), .neonCyan], startPoint: .top, endPoint: .bottom))

                Path { p in
                    p.move(to: CGPoint(x: 42, y: 32))
                    p.addQuadCurve(to: CGPoint(x: 68, y: 20), control: CGPoint(x: 55, y: 18))
                    p.addQuadCurve(to: CGPoint(x: 65, y: 36), control: CGPoint(x: 70, y: 30))
                    p.addQuadCurve(to: CGPoint(x: 42, y: 40), control: CGPoint(x: 55, y: 38))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.5))
            }
            .rotationEffect(.degrees(Double(-flap) * 8.0), anchor: .leading)
        }
        .frame(width: 80, height: 80)
        .shadow(color: .neonCyan.opacity(0.5), radius: 8)
        .onAppear { withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { flap = 1 } }
    }
}

// MARK: - Preview

struct VaultShopView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VaultShopView()
        }
        .preferredColorScheme(.dark)
    }
}
