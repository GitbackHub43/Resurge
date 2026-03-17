import Foundation

struct ProgramTemplate: Identifiable {
    let id: String
    let programType: ProgramType
    let defaultTriggers: [String]
    let defaultCopingTools: [String]
    let defaultMetrics: [String]
    let baselineSuggestions: String
    let insightCards: [InsightCard]
    let uniqueToolIdentifier: String
    let uniqueToolName: String
}

enum ProgramTemplates {
    static let all: [ProgramTemplate] = [
        smoking, alcohol, porn, phone, socialMedia, gaming,
        sugar, emotionalEating, shopping, gambling
    ]

    static func template(for type: ProgramType) -> ProgramTemplate? {
        all.first { $0.programType == type }
    }

    static let smoking = ProgramTemplate(
        id: "smoking",
        programType: .smoking,
        defaultTriggers: ["After meals", "Morning coffee", "Work stress", "Social events", "Driving", "Alcohol consumption", "Boredom", "Phone calls"],
        defaultCopingTools: ["Deep breathing", "Nicotine replacement", "Walk outside", "Drink water", "Chew gum", "Call a friend", "5-minute delay"],
        defaultMetrics: ["Cigarettes avoided", "Money saved", "Lung capacity improvement"],
        baselineSuggestions: "Average smoker: 15 cigarettes/day at $0.50 each, 5 minutes per cigarette",
        insightCards: [
            InsightCard(id: UUID(), title: "Craving Peak", body: "Most nicotine cravings last 3-5 minutes. Each one you resist weakens the next.", iconName: "timer", category: "science", isPremium: false),
            InsightCard(id: UUID(), title: "Body Recovery", body: "After 48 hours, nerve endings begin to regrow. Taste and smell improve.", iconName: "heart.fill", category: "health", isPremium: false),
            InsightCard(id: UUID(), title: "Carbon Monoxide", body: "CO levels in your blood drop to normal within 12 hours of quitting.", iconName: "wind", category: "health", isPremium: false)
        ],
        uniqueToolIdentifier: "smoking_tools",
        uniqueToolName: "Nicotine Tracker"
    )

    static let alcohol = ProgramTemplate(
        id: "alcohol",
        programType: .alcohol,
        defaultTriggers: ["Happy hour invites", "Dinner parties", "Stress at work", "Loneliness", "Weekend routine", "Celebrations", "Arguments", "FOMO"],
        defaultCopingTools: ["Sparkling water", "NA beverages", "Call sponsor", "Journal feelings", "Physical exercise", "Mindful breathing", "Leave the situation"],
        defaultMetrics: ["Drinks avoided", "Money saved", "Sober days", "Sleep quality"],
        baselineSuggestions: "Track drinks per week. Average: 14 drinks/week at $8 each, 30 min per drink",
        insightCards: [
            InsightCard(id: UUID(), title: "Liver Recovery", body: "Your liver begins to recover within days. Fat deposits start reducing after 2 weeks.", iconName: "cross.case.fill", category: "health", isPremium: false),
            InsightCard(id: UUID(), title: "Sleep Improvement", body: "Alcohol disrupts REM sleep. Quality sleep returns within 1-2 weeks.", iconName: "moon.fill", category: "wellness", isPremium: false),
            InsightCard(id: UUID(), title: "Social Pressure", body: "Have a plan before social events. Knowing your response ahead of time reduces stress.", iconName: "person.2.fill", category: "strategy", isPremium: false)
        ],
        uniqueToolIdentifier: "alcohol_tools",
        uniqueToolName: "Event Planner"
    )

    static let porn = ProgramTemplate(
        id: "porn",
        programType: .porn,
        defaultTriggers: ["Late night browsing", "Boredom", "Loneliness", "Stress", "Social media triggers", "Being alone", "Insomnia", "Procrastination"],
        defaultCopingTools: ["Cold shower", "Physical exercise", "Call someone", "Leave the room", "Website blocker", "Accountability partner", "Mindfulness"],
        defaultMetrics: ["Clean days", "Time reclaimed", "Urges resisted"],
        baselineSuggestions: "Track time spent per day. Average: 30-60 min/day",
        insightCards: [
            InsightCard(id: UUID(), title: "Dopamine Reset", body: "Your brain's reward system begins recalibrating within 2 weeks of abstinence.", iconName: "brain.head.profile", category: "science", isPremium: false),
            InsightCard(id: UUID(), title: "Late Night Shield", body: "Most relapses happen between 10 PM and 2 AM. Use the shield tool during these hours.", iconName: "shield.fill", category: "strategy", isPremium: false)
        ],
        uniqueToolIdentifier: "porn_tools",
        uniqueToolName: "Emergency Shield"
    )

    static let phone = ProgramTemplate(
        id: "phone",
        programType: .phone,
        defaultTriggers: ["Waiting in line", "Waking up", "Before sleep", "During meals", "Boredom", "Notifications", "Work breaks", "Anxiety"],
        defaultCopingTools: ["Leave phone in another room", "Greyscale mode", "App timer", "Read a book", "Walk outside", "Talk to someone nearby", "Deep breathing"],
        defaultMetrics: ["Screen time reduced", "Pickups avoided", "Focus sessions"],
        baselineSuggestions: "Average: 4-7 hours/day screen time. Track pickups per day (80-100 average)",
        insightCards: [
            InsightCard(id: UUID(), title: "Attention Recovery", body: "Your attention span starts improving after just 3 days of reduced phone use.", iconName: "eye.fill", category: "science", isPremium: false),
            InsightCard(id: UUID(), title: "Scroll Interrupt", body: "The 60-second delay creates a conscious choice point, breaking automatic behavior.", iconName: "hand.raised.fill", category: "strategy", isPremium: false)
        ],
        uniqueToolIdentifier: "phone_tools",
        uniqueToolName: "Scroll Interrupt"
    )

    static let socialMedia = ProgramTemplate(
        id: "social_media",
        programType: .socialMedia,
        defaultTriggers: ["FOMO", "Boredom", "Need for validation", "Comparison habit", "News anxiety", "Loneliness", "Procrastination", "Morning routine"],
        defaultCopingTools: ["Post and leave", "Set time limit", "Unfollow triggers", "Call a friend instead", "Journal thoughts", "Go for a walk", "Create instead of consume"],
        defaultMetrics: ["Time saved", "Check-ins reduced", "Mindful sessions"],
        baselineSuggestions: "Track daily social media checks. Average: 50-80 checks/day, 2-3 hours total",
        insightCards: [
            InsightCard(id: UUID(), title: "Comparison Trap", body: "Social media shows curated highlights. Reducing exposure decreases anxiety within 1 week.", iconName: "arrow.triangle.2.circlepath", category: "wellness", isPremium: false),
            InsightCard(id: UUID(), title: "Cooldown Timer", body: "Waiting 30 minutes between checks builds awareness of automatic behavior.", iconName: "timer", category: "strategy", isPremium: false)
        ],
        uniqueToolIdentifier: "social_media_tools",
        uniqueToolName: "Check Cooldown"
    )

    static let gaming = ProgramTemplate(
        id: "gaming",
        programType: .gaming,
        defaultTriggers: ["Boredom", "Friend invites", "Tournament FOMO", "Stress escape", "After work", "Weekend mornings", "Achievement hunting", "Streaming"],
        defaultCopingTools: ["Set session timer", "Exit plan ritual", "Physical activity", "Social activity", "Creative hobby", "Read", "Cook a meal"],
        defaultMetrics: ["Hours reduced", "Sessions skipped", "Real-world activities"],
        baselineSuggestions: "Track gaming hours/day. Heavy gamers: 4-8 hours/day",
        insightCards: [
            InsightCard(id: UUID(), title: "Dopamine Regulation", body: "Gaming provides intense dopamine hits. Real-world activities feel more rewarding after 2 weeks.", iconName: "gamecontroller.fill", category: "science", isPremium: false),
            InsightCard(id: UUID(), title: "Exit Plan", body: "Decide your stop time before starting. Having an exit ritual makes it easier.", iconName: "door.right.hand.open", category: "strategy", isPremium: false)
        ],
        uniqueToolIdentifier: "gaming_tools",
        uniqueToolName: "Session Exit Plan"
    )

    static let sugar = ProgramTemplate(
        id: "sugar",
        programType: .sugar,
        defaultTriggers: ["After meals", "Stress", "Mid-afternoon slump", "Social pressure", "Boredom", "Emotional comfort", "Advertising", "Coffee breaks"],
        defaultCopingTools: ["Drink water", "Eat protein snack", "Take a walk", "Brush teeth", "Delay 15 minutes", "Substitution (fruit)", "Journal the craving"],
        defaultMetrics: ["Sugar servings avoided", "Money saved", "Energy level"],
        baselineSuggestions: "Track sugary items per day. Average: 3-5 servings at $3 each",
        insightCards: [
            InsightCard(id: UUID(), title: "Sugar Crash", body: "Blood sugar spikes lead to crashes 2-3 hours later, creating a cycle. Log your energy.", iconName: "bolt.fill", category: "health", isPremium: false),
            InsightCard(id: UUID(), title: "Substitution Works", body: "Replacing sugar with naturally sweet foods reduces cravings within 5-7 days.", iconName: "leaf.fill", category: "strategy", isPremium: false)
        ],
        uniqueToolIdentifier: "sugar_tools",
        uniqueToolName: "Substitution List"
    )

    static let emotionalEating = ProgramTemplate(
        id: "emotional_eating",
        programType: .emotionalEating,
        defaultTriggers: ["Stress", "Sadness", "Loneliness", "Boredom", "Anxiety", "Anger", "Celebration", "Tiredness"],
        defaultCopingTools: ["HALT check", "Self-compassion pause", "Call a friend", "Journal emotions", "Take a walk", "Deep breathing", "Drink water first"],
        defaultMetrics: ["Emotional eating episodes avoided", "HALT checks done", "Mindful meals"],
        baselineSuggestions: "Track emotional eating episodes per week and the emotions involved",
        insightCards: [
            InsightCard(id: UUID(), title: "HALT Check", body: "Before eating, ask: Am I Hungry, Angry, Lonely, or Tired? Address the real need.", iconName: "hand.raised.fill", category: "strategy", isPremium: false),
            InsightCard(id: UUID(), title: "Emotional Awareness", body: "Naming your emotion reduces its intensity by up to 50% (affect labeling).", iconName: "heart.text.square.fill", category: "science", isPremium: false)
        ],
        uniqueToolIdentifier: "emotional_eating_tools",
        uniqueToolName: "HALT Check"
    )

    static let shopping = ProgramTemplate(
        id: "shopping",
        programType: .shopping,
        defaultTriggers: ["Sale notifications", "Boredom browsing", "Emotional distress", "Social media ads", "Pay day", "Comparison", "Retail therapy", "Free shipping threshold"],
        defaultCopingTools: ["24-hour cart quarantine", "Wishlist later", "Unsubscribe from emails", "Budget review", "Walk away", "Call a friend", "One-in-one-out rule"],
        defaultMetrics: ["Impulse purchases avoided", "Money saved", "Cart quarantines completed"],
        baselineSuggestions: "Track impulse purchases per week and total spending",
        insightCards: [
            InsightCard(id: UUID(), title: "Cart Quarantine", body: "Waiting 24 hours before purchasing eliminates 70% of impulse buys.", iconName: "cart.fill", category: "strategy", isPremium: false),
            InsightCard(id: UUID(), title: "Dopamine Shopping", body: "The excitement is in the anticipation, not the purchase. The high fades within hours.", iconName: "brain.head.profile", category: "science", isPremium: false)
        ],
        uniqueToolIdentifier: "shopping_tools",
        uniqueToolName: "Cart Quarantine"
    )

    static let gambling = ProgramTemplate(
        id: "gambling",
        programType: .gambling,
        defaultTriggers: ["Sports events", "Online ads", "Winning streak", "Losing streak", "Boredom", "Financial stress", "Social pressure", "Alcohol"],
        defaultCopingTools: ["Reality check card", "Self-exclusion tools", "Call helpline", "Financial review", "Emergency contact", "Physical activity", "Delay and distract"],
        defaultMetrics: ["Gambling-free days", "Money saved", "Urges resisted"],
        baselineSuggestions: "Track gambling sessions and amounts per week",
        insightCards: [
            InsightCard(id: UUID(), title: "House Always Wins", body: "Every game is mathematically designed for the house to profit long-term. The only winning move is not to play.", iconName: "dollarsign.circle.fill", category: "reality", isPremium: false),
            InsightCard(id: UUID(), title: "Chasing Losses", body: "The urge to recover losses is the most dangerous trigger. Losses are permanent; more gambling adds more.", iconName: "exclamationmark.triangle.fill", category: "strategy", isPremium: false)
        ],
        uniqueToolIdentifier: "gambling_tools",
        uniqueToolName: "Reality Check"
    )

}
