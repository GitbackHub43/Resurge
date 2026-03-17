import SwiftUI

// MARK: - RewardsView

struct RewardsView: View {
    let totalRP: Int
    let isPremiumUser: Bool
    let recentActivities: [RecentPointActivity]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppStyle.spacing), count: 3)

    private var unlockedIDs: Set<String> {
        Set(RewardCatalog.unlockedCollectibles(totalRP: totalRP, isPremium: isPremiumUser).map(\.id))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                rpHeaderSection
                progressSection
                collectionGridSection
                recentPointsSection
            }
            .padding(AppStyle.screenPadding)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Rewards")
    }

    // MARK: - Header

    private var rpHeaderSection: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("\(totalRP)")
                .font(Typography.statValue)
                .foregroundColor(.neonCyan)
                .shadow(color: .neonCyan.opacity(0.6), radius: 12, x: 0, y: 0)

            Text("Recovery Points")
                .font(Typography.statLabel)
                .foregroundColor(.textSecondary)
                .rainbowText()
        }
        .frame(maxWidth: .infinity)
        .rainbowCard()
    }

    // MARK: - Progress to Next

    private var progressSection: some View {
        Group {
            if let next = RewardCatalog.nextCollectible(totalRP: totalRP, isPremium: isPremiumUser) {
                let progress = RewardCatalog.progressToNext(totalRP: totalRP, isPremium: isPremiumUser)
                let glowColor = colorForName(next.glowColor)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next: \(next.name)")
                            .font(Typography.headline)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Text("\(totalRP) / \(next.requiredRP) RP")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.cardBorder)
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(glowColor)
                                .frame(width: geo.size.width * CGFloat(progress), height: 10)
                                .shadow(color: glowColor.opacity(0.5), radius: 6, x: 0, y: 0)
                        }
                    }
                    .frame(height: 10)
                }
                .modifier(NeonCardModifier(glowColor: glowColor))
            }
        }
    }

    // MARK: - Collection Grid

    private var collectionGridSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text("Collection")
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .rainbowText()

            LazyVGrid(columns: columns, spacing: AppStyle.spacing) {
                ForEach(RewardCatalog.allCollectibles) { collectible in
                    collectibleCard(for: collectible)
                }
            }
        }
    }

    private func collectibleCard(for collectible: Collectible) -> some View {
        let isUnlocked = unlockedIDs.contains(collectible.id)
        let isPremiumLocked = collectible.isPremium && !isPremiumUser
        let glowColor = colorForName(collectible.glowColor)

        return ZStack {
            // Background
            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                .fill(isUnlocked ? glowColor.opacity(0.12) : Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(
                            isUnlocked ? glowColor.opacity(0.4) : Color.cardBorder,
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isUnlocked ? glowColor.opacity(0.3) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 2
                )

            // Content
            VStack(spacing: 6) {
                ZStack {
                    if isUnlocked {
                        Image(systemName: collectible.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(glowColor)
                            .shadow(color: glowColor.opacity(0.6), radius: 6, x: 0, y: 0)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.textSecondary.opacity(0.5))
                    }

                    // Premium crown overlay
                    if isPremiumLocked {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.neonGold)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 36)

                Text(collectible.name)
                    .font(Typography.caption)
                    .foregroundColor(isUnlocked ? .textPrimary : .textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("\(collectible.requiredRP) RP")
                    .font(Typography.footnote)
                    .foregroundColor(isUnlocked ? glowColor : .textSecondary.opacity(0.6))
            }
            .padding(8)
        }
        .aspectRatio(0.85, contentMode: .fit)
    }

    // MARK: - Recent Points

    private var recentPointsSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text("Recent Points")
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .rainbowText()

            if recentActivities.isEmpty {
                Text("Complete activities to earn Recovery Points!")
                    .font(Typography.body)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .modifier(NeonCardModifier())
            } else {
                ForEach(recentActivities.prefix(5)) { activity in
                    HStack(spacing: AppStyle.spacing) {
                        Image(systemName: activity.action.iconName)
                            .font(.system(size: 18))
                            .foregroundColor(.neonCyan)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.action.displayName)
                                .font(Typography.headline)
                                .foregroundColor(.textPrimary)

                            Text(activity.dateString)
                                .font(Typography.caption)
                                .foregroundColor(.textSecondary)
                        }

                        Spacer()

                        Text("+\(activity.points) RP")
                            .font(Typography.callout)
                            .foregroundColor(.neonGreen)
                    }
                    .modifier(NeonCardModifier())
                }
            }
        }
    }

    // MARK: - Color Mapping

    private func colorForName(_ name: String) -> Color {
        switch name {
        case "neonCyan":    return .neonCyan
        case "neonMagenta": return .neonMagenta
        case "neonGreen":   return .neonGreen
        case "neonPurple":  return .neonPurple
        case "neonOrange":  return .neonOrange
        case "neonGold":    return .neonGold
        default:            return .neonCyan
        }
    }
}

// MARK: - Recent Point Activity

struct RecentPointActivity: Identifiable {
    let id: UUID
    let action: RecoveryPointAction
    let points: Int
    let date: Date

    init(id: UUID = UUID(), action: RecoveryPointAction, points: Int, date: Date) {
        self.id = id
        self.action = action
        self.points = points
        self.date = date
    }

    var dateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RewardsView(
                totalRP: 1_250,
                isPremiumUser: false,
                recentActivities: [
                    RecentPointActivity(action: .dailyCheckIn, points: 10, date: Date()),
                    RecentPointActivity(action: .cravingResisted, points: 25, date: Date().addingTimeInterval(-3600)),
                    RecentPointActivity(action: .journalEntry, points: 15, date: Date().addingTimeInterval(-7200)),
                ]
            )
        }
        .preferredColorScheme(.dark)
    }
}
