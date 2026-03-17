import Foundation

struct DailyChallengeService {

    // MARK: - Challenge for Day

    /// Returns a deterministic challenge based on the day number and recovery phase.
    /// The challenge rotates through the pool for the current phase.
    static func challengeForDay(_ daysSober: Int, programType: ProgramType) -> DailyChallenge {
        let phase = RecoveryPhase.phase(for: daysSober)
        let pool = challenges(for: phase)
        let index = daysSober % pool.count
        return pool[index]
    }

    // MARK: - Challenge Pools

    static func challenges(for phase: RecoveryPhase) -> [DailyChallenge] {
        switch phase {
        case .detox:          return detoxChallenges
        case .building:       return buildingChallenges
        case .strengthening:  return strengtheningChallenges
        case .maintaining:    return maintainingChallenges
        }
    }

    // MARK: - Detox (Days 1-7)

    private static let detoxChallenges: [DailyChallenge] = [
        DailyChallenge(
            id: "detox_01",
            title: "Write Why You Started",
            description: "Take 5 minutes to write down the reasons you decided to make this change. Keep it somewhere visible.",
            iconName: "pencil.and.outline",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_02",
            title: "Identify 3 Triggers",
            description: "List three situations, emotions, or places that make you want to relapse. Awareness is the first step.",
            iconName: "exclamationmark.triangle",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_03",
            title: "Practice 4-7-8 Breathing",
            description: "Inhale for 4 seconds, hold for 7, exhale for 8. Repeat 4 times to calm your nervous system.",
            iconName: "wind",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_04",
            title: "Tell Someone You Trust",
            description: "Share your goal with a friend, family member, or support person. Accountability increases success.",
            iconName: "person.2.fill",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_05",
            title: "Drink 8 Glasses of Water",
            description: "Hydration helps your body heal. Track your water intake throughout the day.",
            iconName: "drop.fill",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_06",
            title: "Take a Cold Shower",
            description: "A brief cold shower can reset your nervous system and reduce cravings. Start with 30 seconds.",
            iconName: "snowflake",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_07",
            title: "Remove One Temptation",
            description: "Delete an app, throw away a stash, or remove something from your environment that enables the habit.",
            iconName: "trash.fill",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_08",
            title: "Go for a 10-Minute Walk",
            description: "Movement releases endorphins and helps break the craving cycle. Just 10 minutes outside.",
            iconName: "figure.walk",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_09",
            title: "Set Up Your Emergency Contacts",
            description: "Add trusted people to your emergency contacts so you can reach out when cravings hit hard.",
            iconName: "phone.fill",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_10",
            title: "Write a Letter to Your Future Self",
            description: "Describe the person you want to become. What does life look like free from this habit?",
            iconName: "envelope.fill",
            phase: .detox
        ),
        DailyChallenge(
            id: "detox_11",
            title: "Create a Coping Playlist",
            description: "Put together a playlist of songs that motivate, calm, or empower you during tough moments.",
            iconName: "music.note.list",
            phase: .detox
        )
    ]

    // MARK: - Building (Days 8-30)

    private static let buildingChallenges: [DailyChallenge] = [
        DailyChallenge(
            id: "building_01",
            title: "Try a New Coping Tool",
            description: "Experiment with a coping strategy you haven't tried yet. Meditation, art, exercise — find what works.",
            iconName: "wrench.and.screwdriver.fill",
            phase: .building
        ),
        DailyChallenge(
            id: "building_02",
            title: "Journal Your Feelings",
            description: "Write about what you're feeling today without judgment. Getting it out helps process emotions.",
            iconName: "book.fill",
            phase: .building
        ),
        DailyChallenge(
            id: "building_03",
            title: "Walk for 20 Minutes",
            description: "A longer walk builds both physical health and mental resilience. Notice the world around you.",
            iconName: "figure.walk",
            phase: .building
        ),
        DailyChallenge(
            id: "building_04",
            title: "Celebrate a Small Win",
            description: "Acknowledge something you did well today, no matter how small. Progress deserves recognition.",
            iconName: "star.fill",
            phase: .building
        ),
        DailyChallenge(
            id: "building_05",
            title: "Practice Body Scan Meditation",
            description: "Spend 10 minutes scanning your body from head to toe, releasing tension in each area.",
            iconName: "figure.mind.and.body",
            phase: .building
        ),
        DailyChallenge(
            id: "building_06",
            title: "Cook a Healthy Meal",
            description: "Nourish your body with a home-cooked meal. The act of cooking is itself a mindful practice.",
            iconName: "fork.knife",
            phase: .building
        ),
        DailyChallenge(
            id: "building_07",
            title: "Establish a Morning Routine",
            description: "Write down 3-5 things you'll do each morning. Structure helps prevent impulsive decisions.",
            iconName: "sunrise.fill",
            phase: .building
        ),
        DailyChallenge(
            id: "building_08",
            title: "Reach Out to a Friend",
            description: "Send a message or call someone you care about. Social connection is a natural mood booster.",
            iconName: "message.fill",
            phase: .building
        ),
        DailyChallenge(
            id: "building_09",
            title: "Learn Something New",
            description: "Watch a tutorial, read an article, or try a new skill. Redirect your energy into growth.",
            iconName: "lightbulb.fill",
            phase: .building
        ),
        DailyChallenge(
            id: "building_10",
            title: "Create a Vision Board",
            description: "Collect images and words that represent the life you're building. Visualize your success.",
            iconName: "photo.on.rectangle.angled",
            phase: .building
        ),
        DailyChallenge(
            id: "building_11",
            title: "Practice Gratitude",
            description: "Write down 3 things you're grateful for today. Gratitude shifts your focus from lack to abundance.",
            iconName: "heart.fill",
            phase: .building
        )
    ]

    // MARK: - Strengthening (Days 31-90)

    private static let strengtheningChallenges: [DailyChallenge] = [
        DailyChallenge(
            id: "strength_01",
            title: "Help Someone Else Struggling",
            description: "Share your experience or offer encouragement to someone earlier in their journey.",
            iconName: "hand.raised.fill",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_02",
            title: "Review Your Progress",
            description: "Look back at where you started and appreciate how far you've come. Data doesn't lie.",
            iconName: "chart.line.uptrend.xyaxis",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_03",
            title: "Practice Gratitude",
            description: "Write 5 things you're grateful for that are possible because of your recovery.",
            iconName: "heart.fill",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_04",
            title: "Plan for a Trigger Situation",
            description: "Think about an upcoming situation that might tempt you. Create a specific plan to handle it.",
            iconName: "shield.fill",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_05",
            title: "Try a 30-Minute Workout",
            description: "Push yourself physically. Exercise builds discipline that carries into all areas of life.",
            iconName: "flame.fill",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_06",
            title: "Read About Recovery",
            description: "Read a chapter from a recovery book or an article about building healthy habits.",
            iconName: "book.fill",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_07",
            title: "Practice Saying No",
            description: "Rehearse declining an offer or invitation that could compromise your recovery.",
            iconName: "hand.raised.slash.fill",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_08",
            title: "Deep Clean a Room",
            description: "A clean environment supports a clear mind. Spend 30 minutes organizing your space.",
            iconName: "sparkles",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_09",
            title: "Write About Your Transformation",
            description: "How have you changed since you started? What surprised you about the journey?",
            iconName: "pencil.and.outline",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_10",
            title: "Set a 90-Day Goal",
            description: "What do you want to achieve by day 90? Write it down and break it into steps.",
            iconName: "target",
            phase: .strengthening
        ),
        DailyChallenge(
            id: "strength_11",
            title: "Meditate for 15 Minutes",
            description: "Sit in silence and observe your thoughts without attachment. Build your inner calm.",
            iconName: "figure.mind.and.body",
            phase: .strengthening
        )
    ]

    // MARK: - Maintaining (Days 91+)

    private static let maintainingChallenges: [DailyChallenge] = [
        DailyChallenge(
            id: "maintain_01",
            title: "Mentor a Beginner",
            description: "Share your wisdom with someone in the early stages. Teaching strengthens your own commitment.",
            iconName: "person.2.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_02",
            title: "Set a New Goal",
            description: "Recovery opened doors. What new challenge excites you? Career, fitness, creative — dream big.",
            iconName: "flag.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_03",
            title: "Reflect on How Far You've Come",
            description: "Compare who you are today to who you were on day one. Celebrate your transformation.",
            iconName: "arrow.up.right.circle.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_04",
            title: "Share Your Story",
            description: "Write about your journey. Your story could inspire someone who is struggling right now.",
            iconName: "text.bubble.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_05",
            title: "Give Back to Your Community",
            description: "Volunteer, donate, or simply be present for someone who needs it. Recovery is about growth.",
            iconName: "gift.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_06",
            title: "Review Your Emergency Plan",
            description: "Even at 91+ days, complacency is a risk. Update your coping strategies and contacts.",
            iconName: "shield.checkered",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_07",
            title: "Practice Advanced Meditation",
            description: "Try a 20+ minute meditation session. Explore new techniques like loving-kindness or visualization.",
            iconName: "figure.mind.and.body",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_08",
            title: "Teach a Coping Skill",
            description: "Share a technique that helped you with a friend or family member. Spread the tools of recovery.",
            iconName: "wrench.and.screwdriver.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_09",
            title: "Plan a Reward",
            description: "Plan something special with the time or money you've saved. You've earned it.",
            iconName: "star.circle.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_10",
            title: "Journal About Your Identity",
            description: "You're no longer defined by your habit. Who are you becoming? Write freely.",
            iconName: "person.crop.circle.fill",
            phase: .maintaining
        ),
        DailyChallenge(
            id: "maintain_11",
            title: "Reconnect with a Passion",
            description: "Revisit a hobby or interest you neglected. Recovery gives you the bandwidth to pursue joy.",
            iconName: "paintpalette.fill",
            phase: .maintaining
        )
    ]
}
