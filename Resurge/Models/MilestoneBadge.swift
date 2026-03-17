import Foundation

enum BadgeCategory: String, CaseIterable, Codable {
    case time
    case behavior
    case streak
    case program
    case tool
}

struct MilestoneBadge: Identifiable, Equatable {
    let key: String
    let title: String
    let description: String
    let iconName: String
    let requiredDays: Int
    let isPremium: Bool
    let category: BadgeCategory
    let programType: ProgramType?
    let tier: Int?
    let trackName: String?
    let requiredCount: Int

    init(
        key: String,
        title: String,
        description: String,
        iconName: String,
        requiredDays: Int,
        isPremium: Bool,
        category: BadgeCategory,
        programType: ProgramType? = nil,
        tier: Int? = nil,
        trackName: String? = nil,
        requiredCount: Int = 0
    ) {
        self.key = key
        self.title = title
        self.description = description
        self.iconName = iconName
        self.requiredDays = requiredDays
        self.isPremium = isPremium
        self.category = category
        self.programType = programType
        self.tier = tier
        self.trackName = trackName
        self.requiredCount = requiredCount
    }

    var id: String { key }

    static func == (lhs: MilestoneBadge, rhs: MilestoneBadge) -> Bool {
        lhs.key == rhs.key
    }

    // MARK: - All Badges

    static let allBadges: [MilestoneBadge] = (timeBadges + behaviorBadges + streakBadges + programBadges + allTrackBadges).sorted { $0.requiredDays < $1.requiredDays }

    // MARK: - Health Badges (generated from HealthTimeline per habit)

    /// Generates health milestone badges from the HealthTimeline for a specific program type.
    /// Each badge corresponds to an actual health improvement milestone for that habit.
    static func healthBadges(for programType: ProgramType) -> [MilestoneBadge] {
        let milestones = HealthMilestone.milestones(for: programType)
        return milestones.enumerated().map { index, milestone in
            let days = max(1, milestone.requiredMinutes / 1440) // Convert minutes to days (min 1)
            return MilestoneBadge(
                key: "health_\(programType.rawValue)_\(index)",
                title: milestone.title,
                description: milestone.description,
                iconName: milestone.iconName,
                requiredDays: days,
                isPremium: index >= 5, // First 5 free, rest premium
                category: .behavior,
                programType: programType
            )
        }
    }

    // MARK: - Tiered Track Badges

    static let allTrackBadges: [MilestoneBadge] = waveRiderTrack + resilienceBuilderTrack + planStreakTrack + urgeScientistTrack + valuesChampTrack

    static let waveRiderTrack: [MilestoneBadge] = [
        MilestoneBadge(key: "wave_rider_1", title: "Wave Rider I", description: "Complete craving protocol 5 times", iconName: "water.waves", requiredDays: 0, isPremium: false, category: .tool, tier: 1, trackName: "Wave Rider", requiredCount: 5),
        MilestoneBadge(key: "wave_rider_2", title: "Wave Rider II", description: "Complete craving protocol 20 times", iconName: "water.waves", requiredDays: 0, isPremium: false, category: .tool, tier: 2, trackName: "Wave Rider", requiredCount: 20),
        MilestoneBadge(key: "wave_rider_3", title: "Wave Rider III", description: "Complete craving protocol 50 times", iconName: "water.waves", requiredDays: 0, isPremium: true, category: .tool, tier: 3, trackName: "Wave Rider", requiredCount: 50),
        MilestoneBadge(key: "wave_rider_4", title: "Wave Rider IV", description: "Complete craving protocol 100 times", iconName: "water.waves", requiredDays: 0, isPremium: true, category: .tool, tier: 4, trackName: "Wave Rider", requiredCount: 100),
    ]

    static let resilienceBuilderTrack: [MilestoneBadge] = [
        MilestoneBadge(key: "resilience_1", title: "Resilience Builder I", description: "Complete 5 lapse recovery flows", iconName: "arrow.counterclockwise.circle.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 1, trackName: "Resilience Builder", requiredCount: 5),
        MilestoneBadge(key: "resilience_2", title: "Resilience Builder II", description: "Complete 20 lapse recovery flows", iconName: "arrow.counterclockwise.circle.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 2, trackName: "Resilience Builder", requiredCount: 20),
        MilestoneBadge(key: "resilience_3", title: "Resilience Builder III", description: "Complete 50 lapse recovery flows", iconName: "arrow.counterclockwise.circle.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 3, trackName: "Resilience Builder", requiredCount: 50),
        MilestoneBadge(key: "resilience_4", title: "Resilience Builder IV", description: "Complete 100 lapse recovery flows", iconName: "arrow.counterclockwise.circle.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 4, trackName: "Resilience Builder", requiredCount: 100),
    ]

    static let planStreakTrack: [MilestoneBadge] = [
        MilestoneBadge(key: "plan_streak_1", title: "Plan Streak I", description: "Complete morning plan 5 days", iconName: "sunrise.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 1, trackName: "Plan Streak", requiredCount: 5),
        MilestoneBadge(key: "plan_streak_2", title: "Plan Streak II", description: "Complete morning plan 20 days", iconName: "sunrise.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 2, trackName: "Plan Streak", requiredCount: 20),
        MilestoneBadge(key: "plan_streak_3", title: "Plan Streak III", description: "Complete morning plan 50 days", iconName: "sunrise.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 3, trackName: "Plan Streak", requiredCount: 50),
        MilestoneBadge(key: "plan_streak_4", title: "Plan Streak IV", description: "Complete morning plan 100 days", iconName: "sunrise.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 4, trackName: "Plan Streak", requiredCount: 100),
    ]

    static let urgeScientistTrack: [MilestoneBadge] = [
        MilestoneBadge(key: "urge_scientist_1", title: "Urge Scientist I", description: "Log 5 urges in the Urge Log", iconName: "list.clipboard.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 1, trackName: "Urge Scientist", requiredCount: 5),
        MilestoneBadge(key: "urge_scientist_2", title: "Urge Scientist II", description: "Log 20 urges in the Urge Log", iconName: "list.clipboard.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 2, trackName: "Urge Scientist", requiredCount: 20),
        MilestoneBadge(key: "urge_scientist_3", title: "Urge Scientist III", description: "Log 50 urges in the Urge Log", iconName: "list.clipboard.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 3, trackName: "Urge Scientist", requiredCount: 50),
        MilestoneBadge(key: "urge_scientist_4", title: "Urge Scientist IV", description: "Log 100 urges in the Urge Log", iconName: "list.clipboard.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 4, trackName: "Urge Scientist", requiredCount: 100),
    ]

    static let valuesChampTrack: [MilestoneBadge] = [
        MilestoneBadge(key: "values_champ_1", title: "Values Champ I", description: "Complete Values Compass 5 times", iconName: "safari.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 1, trackName: "Values Champ", requiredCount: 5),
        MilestoneBadge(key: "values_champ_2", title: "Values Champ II", description: "Complete Values Compass 20 times", iconName: "safari.fill", requiredDays: 0, isPremium: false, category: .tool, tier: 2, trackName: "Values Champ", requiredCount: 20),
        MilestoneBadge(key: "values_champ_3", title: "Values Champ III", description: "Complete Values Compass 50 times", iconName: "safari.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 3, trackName: "Values Champ", requiredCount: 50),
        MilestoneBadge(key: "values_champ_4", title: "Values Champ IV", description: "Complete Values Compass 100 times", iconName: "safari.fill", requiredDays: 0, isPremium: true, category: .tool, tier: 4, trackName: "Values Champ", requiredCount: 100),
    ]

    static let allTracks: [(name: String, badges: [MilestoneBadge])] = [
        ("Wave Rider", waveRiderTrack),
        ("Resilience Builder", resilienceBuilderTrack),
        ("Plan Streak", planStreakTrack),
        ("Urge Scientist", urgeScientistTrack),
        ("Values Champ", valuesChampTrack),
    ]

    // MARK: - Time Milestones (10)

    static let timeBadges: [MilestoneBadge] = [
        MilestoneBadge(
            key: "1_day",
            title: "First Step",
            description: "Completed your first day free.",
            iconName: "flame.fill",
            requiredDays: 1,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "3_days",
            title: "Building Momentum",
            description: "Three days strong — the habit is forming.",
            iconName: "bolt.fill",
            requiredDays: 3,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "1_week",
            title: "One Week Warrior",
            description: "A full week of freedom.",
            iconName: "shield.fill",
            requiredDays: 7,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "2_weeks",
            title: "Fortnight Fighter",
            description: "Two weeks of consistent effort.",
            iconName: "star.fill",
            requiredDays: 14,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "1_month",
            title: "Monthly Master",
            description: "One full month — you are rewriting your brain.",
            iconName: "crown.fill",
            requiredDays: 30,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "2_months",
            title: "Double Down",
            description: "Two months of dedication.",
            iconName: "trophy.fill",
            requiredDays: 60,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "3_months",
            title: "Quarter Champion",
            description: "90 days — a new identity is taking shape.",
            iconName: "medal.fill",
            requiredDays: 90,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "6_months",
            title: "Half-Year Hero",
            description: "Six months of freedom and growth.",
            iconName: "laurel.leading",
            requiredDays: 180,
            isPremium: false,
            category: .time
        ),
        MilestoneBadge(
            key: "9_months",
            title: "Nine-Month Navigator",
            description: "Three quarters of a year — deeply rooted in your new life.",
            iconName: "compass.drawing",
            requiredDays: 270,
            isPremium: true,
            category: .time
        ),
        MilestoneBadge(
            key: "1_year",
            title: "Annual Legend",
            description: "One full year — you are transformed.",
            iconName: "sparkles",
            requiredDays: 365,
            isPremium: true,
            category: .time
        )
    ]

    // MARK: - Behavior Badges (13)

    static let behaviorBadges: [MilestoneBadge] = [
        MilestoneBadge(
            key: "first_journal",
            title: "First Journal Entry",
            description: "You wrote your first journal entry. Reflection is powerful.",
            iconName: "book.fill",
            requiredDays: 0,
            isPremium: false,
            category: .behavior
        ),
        MilestoneBadge(
            key: "journal_10",
            title: "Reflective Writer",
            description: "10 journal entries written. You are building self-awareness.",
            iconName: "text.book.closed.fill",
            requiredDays: 0,
            isPremium: false,
            category: .behavior
        ),
        MilestoneBadge(
            key: "journal_50",
            title: "Journaling Devotee",
            description: "50 journal entries. Your reflective practice is deeply established.",
            iconName: "pencil.and.outline",
            requiredDays: 0,
            isPremium: true,
            category: .behavior
        ),
        MilestoneBadge(
            key: "journal_100",
            title: "Story of Strength",
            description: "100 journal entries. You are writing your own recovery story.",
            iconName: "text.book.closed.fill",
            requiredDays: 0,
            isPremium: true,
            category: .behavior
        ),
        MilestoneBadge(
            key: "journal_250",
            title: "Chronicle Keeper",
            description: "250 journal entries. Your journal is a testament to your journey.",
            iconName: "books.vertical.fill",
            requiredDays: 0,
            isPremium: true,
            category: .behavior
        ),
        MilestoneBadge(
            key: "journal_500",
            title: "Master Chronicler",
            description: "500 journal entries. You have built an extraordinary record of growth.",
            iconName: "scroll.fill",
            requiredDays: 0,
            isPremium: true,
            category: .behavior
        ),
        MilestoneBadge(
            key: "craving_crusher_10",
            title: "Craving Crusher",
            description: "Resisted 10 cravings using the toolkit. Your willpower is growing.",
            iconName: "hand.raised.fill",
            requiredDays: 0,
            isPremium: false,
            category: .behavior
        ),
        MilestoneBadge(
            key: "craving_crusher_50",
            title: "Craving Conqueror",
            description: "50 cravings resisted. You have mastered the urge.",
            iconName: "bolt.shield.fill",
            requiredDays: 0,
            isPremium: true,
            category: .behavior
        ),
        MilestoneBadge(
            key: "week_warrior",
            title: "Week Warrior",
            description: "7 daily check-ins in a row. Consistency is key.",
            iconName: "checkmark.seal.fill",
            requiredDays: 0,
            isPremium: false,
            category: .behavior
        ),
        MilestoneBadge(
            key: "tool_explorer",
            title: "Tool Explorer",
            description: "Used 5 different coping tools. Versatility is strength.",
            iconName: "wrench.and.screwdriver.fill",
            requiredDays: 0,
            isPremium: false,
            category: .behavior
        ),
        // Health badges are generated per-habit from HealthTimeline — see healthBadges(for:)
        MilestoneBadge(
            key: "time_100",
            title: "100 Hours Reclaimed",
            description: "One hundred hours redirected to things that matter.",
            iconName: "clock.fill",
            requiredDays: 0,
            isPremium: false,
            category: .behavior
        ),
        MilestoneBadge(
            key: "time_500",
            title: "500 Hours Reclaimed",
            description: "Five hundred hours reclaimed. That is over 20 full days of your life back.",
            iconName: "hourglass",
            requiredDays: 0,
            isPremium: true,
            category: .behavior
        )
    ]

    // MARK: - Streak Badges (8)

    static let streakBadges: [MilestoneBadge] = [
        MilestoneBadge(
            key: "streak_3",
            title: "3-Day Streak",
            description: "Three consecutive days checked in. Momentum is building.",
            iconName: "flame.fill",
            requiredDays: 3,
            isPremium: false,
            category: .streak
        ),
        MilestoneBadge(
            key: "streak_7",
            title: "7-Day Streak",
            description: "A full week of daily engagement. The habit of recovery is forming.",
            iconName: "flame.fill",
            requiredDays: 7,
            isPremium: false,
            category: .streak
        ),
        MilestoneBadge(
            key: "streak_14",
            title: "14-Day Streak",
            description: "Two weeks of unbroken commitment.",
            iconName: "flame.fill",
            requiredDays: 14,
            isPremium: false,
            category: .streak
        ),
        MilestoneBadge(
            key: "streak_30",
            title: "30-Day Streak",
            description: "A full month of daily check-ins. You are unstoppable.",
            iconName: "flame.fill",
            requiredDays: 30,
            isPremium: false,
            category: .streak
        ),
        MilestoneBadge(
            key: "streak_60",
            title: "60-Day Streak",
            description: "Two months without missing a day. Extraordinary discipline.",
            iconName: "flame.fill",
            requiredDays: 60,
            isPremium: true,
            category: .streak
        ),
        MilestoneBadge(
            key: "streak_100",
            title: "100-Day Streak",
            description: "One hundred consecutive days. You have made recovery a lifestyle.",
            iconName: "flame.fill",
            requiredDays: 100,
            isPremium: true,
            category: .streak
        ),
        MilestoneBadge(
            key: "streak_200",
            title: "200-Day Streak",
            description: "Two hundred days of unwavering daily commitment.",
            iconName: "flame.fill",
            requiredDays: 200,
            isPremium: true,
            category: .streak
        ),
        MilestoneBadge(
            key: "streak_365",
            title: "365-Day Streak",
            description: "A full year without missing a single day. Legendary dedication.",
            iconName: "flame.fill",
            requiredDays: 365,
            isPremium: true,
            category: .streak
        )
    ]

    // MARK: - Program Badges (36 — 3 per program)

    static let programBadges: [MilestoneBadge] = [
        // Smoking
        MilestoneBadge(key: "smoking_7d", title: "Fresh Lungs", description: "7 days smoke-free. Your lungs are already healing.", iconName: "lungs", requiredDays: 7, isPremium: false, category: .program, programType: .smoking),
        MilestoneBadge(key: "smoking_30d", title: "Smoke-Free Warrior", description: "30 days without a cigarette. You are a warrior.", iconName: "shield.fill", requiredDays: 30, isPremium: false, category: .program, programType: .smoking),
        MilestoneBadge(key: "smoking_90d", title: "Breathing Free", description: "90 days smoke-free. Every breath is a victory.", iconName: "wind", requiredDays: 90, isPremium: false, category: .program, programType: .smoking),

        // Alcohol
        MilestoneBadge(key: "alcohol_7d", title: "Clear Headed", description: "7 days sober. Clarity is returning.", iconName: "brain.head.profile", requiredDays: 7, isPremium: false, category: .program, programType: .alcohol),
        MilestoneBadge(key: "alcohol_30d", title: "Sober Socialite", description: "30 days sober. You can celebrate without drinking.", iconName: "person.2.fill", requiredDays: 30, isPremium: false, category: .program, programType: .alcohol),
        MilestoneBadge(key: "alcohol_90d", title: "Dry Champion", description: "90 days alcohol-free. You are a champion of sobriety.", iconName: "trophy.fill", requiredDays: 90, isPremium: false, category: .program, programType: .alcohol),

        // Porn
        MilestoneBadge(key: "porn_7d", title: "Mind Reclaimed", description: "7 days free. Your mind is yours again.", iconName: "brain", requiredDays: 7, isPremium: false, category: .program, programType: .porn),
        MilestoneBadge(key: "porn_30d", title: "Eyes Forward", description: "30 days free. Your focus is on what truly matters.", iconName: "eye.fill", requiredDays: 30, isPremium: false, category: .program, programType: .porn),
        MilestoneBadge(key: "porn_90d", title: "Freedom Fighter", description: "90 days free. You are fighting for real connection.", iconName: "figure.walk", requiredDays: 90, isPremium: false, category: .program, programType: .porn),

        // Phone
        MilestoneBadge(key: "phone_7d", title: "Screen Break", description: "7 days of reduced screen time. Look up and live.", iconName: "iphone.slash", requiredDays: 7, isPremium: false, category: .program, programType: .phone),
        MilestoneBadge(key: "phone_30d", title: "Digital Detox", description: "30 days with healthy phone habits.", iconName: "antenna.radiowaves.left.and.right.slash", requiredDays: 30, isPremium: false, category: .program, programType: .phone),
        MilestoneBadge(key: "phone_90d", title: "Unplugged Hero", description: "90 days of mindful phone use. You are truly present.", iconName: "bolt.slash.fill", requiredDays: 90, isPremium: false, category: .program, programType: .phone),

        // Social Media
        MilestoneBadge(key: "social_7d", title: "Offline Mode", description: "7 days free from social media. Real life is better.", iconName: "wifi.slash", requiredDays: 7, isPremium: false, category: .program, programType: .socialMedia),
        MilestoneBadge(key: "social_30d", title: "Real Connections", description: "30 days building real-world connections.", iconName: "person.2.wave.2.fill", requiredDays: 30, isPremium: false, category: .program, programType: .socialMedia),
        MilestoneBadge(key: "social_90d", title: "Social Freedom", description: "90 days free. Your self-worth is not measured in likes.", iconName: "hand.raised.fill", requiredDays: 90, isPremium: false, category: .program, programType: .socialMedia),

        // Gaming
        MilestoneBadge(key: "gaming_7d", title: "Touch Grass", description: "7 days away from excessive gaming. The real world awaits.", iconName: "leaf.fill", requiredDays: 7, isPremium: false, category: .program, programType: .gaming),
        MilestoneBadge(key: "gaming_30d", title: "Real Life Leveler", description: "30 days leveling up in real life.", iconName: "figure.run", requiredDays: 30, isPremium: false, category: .program, programType: .gaming),
        MilestoneBadge(key: "gaming_90d", title: "Game Over Addiction", description: "90 days free. Game over for the addiction.", iconName: "flag.checkered", requiredDays: 90, isPremium: false, category: .program, programType: .gaming),

        // Sugar
        MilestoneBadge(key: "sugar_7d", title: "Sweet Freedom", description: "7 days sugar-free. Your body is thanking you.", iconName: "xmark.circle.fill", requiredDays: 7, isPremium: false, category: .program, programType: .sugar),
        MilestoneBadge(key: "sugar_30d", title: "Sugar Crusher", description: "30 days without sugar. Cravings are crushed.", iconName: "hammer.fill", requiredDays: 30, isPremium: false, category: .program, programType: .sugar),
        MilestoneBadge(key: "sugar_90d", title: "Health Champion", description: "90 days sugar-free. Your health is your wealth.", iconName: "heart.circle.fill", requiredDays: 90, isPremium: false, category: .program, programType: .sugar),

        // Emotional Eating
        MilestoneBadge(key: "emotional_eating_7d", title: "Mindful Eater", description: "7 days of mindful eating. Feel, don't feed.", iconName: "brain.head.profile", requiredDays: 7, isPremium: false, category: .program, programType: .emotionalEating),
        MilestoneBadge(key: "emotional_eating_30d", title: "Emotion Master", description: "30 days mastering your emotions without food.", iconName: "heart.fill", requiredDays: 30, isPremium: false, category: .program, programType: .emotionalEating),
        MilestoneBadge(key: "emotional_eating_90d", title: "Inner Peace", description: "90 days of inner peace. You nourish your soul, not your cravings.", iconName: "sparkles", requiredDays: 90, isPremium: false, category: .program, programType: .emotionalEating),

        // Shopping
        MilestoneBadge(key: "shopping_7d", title: "Impulse Free", description: "7 days without impulsive purchases. You are in control.", iconName: "hand.raised.fill", requiredDays: 7, isPremium: false, category: .program, programType: .shopping),
        MilestoneBadge(key: "shopping_30d", title: "Mindful Living", description: "30 days of intentional choices. Less clutter, more clarity.", iconName: "leaf.fill", requiredDays: 30, isPremium: false, category: .program, programType: .shopping),
        MilestoneBadge(key: "shopping_90d", title: "Freedom from Impulse", description: "90 days of self-control. You choose what truly matters.", iconName: "star.fill", requiredDays: 90, isPremium: false, category: .program, programType: .shopping),

        // Gambling
        MilestoneBadge(key: "gambling_7d", title: "Safe Bet", description: "7 days gamble-free. The safest bet is on yourself.", iconName: "shield.fill", requiredDays: 7, isPremium: false, category: .program, programType: .gambling),
        MilestoneBadge(key: "gambling_30d", title: "Risk-Free Living", description: "30 days without gambling. Living risk-free.", iconName: "lock.fill", requiredDays: 30, isPremium: false, category: .program, programType: .gambling),
        MilestoneBadge(key: "gambling_90d", title: "Jackpot of Life", description: "90 days gamble-free. You hit the real jackpot.", iconName: "star.fill", requiredDays: 90, isPremium: false, category: .program, programType: .gambling)
    ]
}
