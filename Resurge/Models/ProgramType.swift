import Foundation

enum ProgramType: String, CaseIterable, Codable, Identifiable {
    case smoking
    case alcohol
    case porn
    case sugar
    case phone
    case gambling
    case socialMedia
    case gaming
    case emotionalEating
    case shopping

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .smoking:          return "Smoking"
        case .alcohol:          return "Alcohol"
        case .porn:             return "Pornography"
        case .phone:            return "Phone Addiction"
        case .gaming:           return "Gaming"
        case .socialMedia:      return "Social Media"
        case .sugar:            return "Sugar"
        case .emotionalEating:  return "Emotional Eating"
        case .shopping:         return "Shopping"
        case .gambling:         return "Gambling"
        // custom removed
        }
    }

    var iconName: String {
        switch self {
        case .smoking:          return "smoke.fill"
        case .alcohol:          return "wineglass.fill"
        case .porn:             return "eye.slash.fill"
        case .phone:            return "iphone"
        case .gaming:           return "gamecontroller.fill"
        case .socialMedia:      return "bubble.left.and.bubble.right.fill"
        case .sugar:            return "cup.and.saucer.fill"
        case .emotionalEating:  return "fork.knife"
        case .shopping:         return "cart.fill"
        case .gambling:         return "dice.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .smoking:          return "#E74C3C"  // Red
        case .alcohol:          return "#2196F3"  // Blue
        case .porn:             return "#E91E63"  // Pink
        case .phone:            return "#00BCD4"  // Cyan
        case .gaming:           return "#2ECC71"  // Green
        case .socialMedia:      return "#9B59B6"  // Purple
        case .sugar:            return "#FF9800"  // Orange
        case .emotionalEating:  return "#8D6E63"  // Warm brown
        case .shopping:         return "#1ABC9C"  // Teal
        case .gambling:         return "#D4AC0D"  // Gold
        }
    }

    var tagline: String {
        switch self {
        case .smoking:          return "Every breath is cleaner than the last."
        case .alcohol:          return "Clarity feels better than any buzz."
        case .porn:             return "Reclaim your attention and connection."
        case .phone:            return "Look up — life is happening now."
        case .gaming:           return "Level up in real life."
        case .socialMedia:      return "Your real life doesn't need likes."
        case .sugar:            return "Sweetness comes from within."
        case .emotionalEating:  return "Feel your feelings, don't feed them."
        case .shopping:         return "You already have enough."
        case .gambling:         return "The best bet is on yourself."
        }
    }

    var habitSpecificLabel: String {
        switch self {
        case .smoking: return "cigarettes"
        case .alcohol: return "drinks"
        case .porn: return "sessions"
        case .phone: return "hours of screen time"
        case .gaming: return "hours gaming"
        case .socialMedia: return "hours on social media"
        case .sugar: return "sugary items"
        case .emotionalEating: return "episodes"
        case .shopping: return "impulse purchases"
        case .gambling: return "betting sessions"
        }
    }

    var dailyLabel: String {
        switch self {
        case .smoking: return "Cigarettes per day"
        case .alcohol: return "Drinks per day"
        case .porn: return "Sessions per day"
        case .phone: return "Hours of screen time per day"
        case .gaming: return "Hours gaming per day"
        case .socialMedia: return "Hours on social media per day"
        case .sugar: return "Sugary items per day"
        case .emotionalEating: return "Episodes per day"
        case .shopping: return "Impulse purchases per week"
        case .gambling: return "Betting sessions per day"
        }
    }

    var helplines: [(name: String, number: String)] {
        switch self {
        case .smoking:          return [("Smokers' Quitline", "1-800-784-8669")]
        case .alcohol:          return [("SAMHSA Helpline", "1-800-662-4357")]
        case .porn:             return [("SAA Recovery", "1-800-477-8191")]
        case .phone, .socialMedia: return [("NAMI Helpline", "1-800-950-6264")]
        case .gaming:           return [("National Problem Gambling Helpline", "1-800-522-4700")]
        case .gambling:         return [("National Problem Gambling Helpline", "1-800-522-4700")]
        case .emotionalEating, .sugar: return [("NEDA Helpline", "1-800-931-2237")]
        case .shopping:         return [("Debtors Anonymous", "1-800-421-2383")]
        }
    }

    // MARK: - Individualized Messages

    var pledgeMessage: String {
        switch self {
        case .smoking: return "I choose clean air today. Every breath heals me."
        case .alcohol: return "I choose clarity today. My mind is sharper without it."
        case .porn: return "I choose real connection today. I am rewiring my brain."
        case .phone: return "I choose presence today. Life happens off-screen."
        case .gaming: return "I choose real achievements today. I level up in life."
        case .socialMedia: return "I choose real life today. I don't need likes to be worthy."
        case .sugar: return "I choose natural energy today. My body thanks me."
        case .emotionalEating: return "I choose to feel my feelings today, not feed them."
        case .shopping: return "I choose enough today. I already have what I need."
        case .gambling: return "I choose financial freedom today. The best bet is on myself."
        }
    }

    var reflectionMessage: String {
        switch self {
        case .smoking: return "How did your lungs feel today? What moments tested you?"
        case .alcohol: return "How clear was your mind today? Did any social situations challenge you?"
        case .porn: return "How present were you today? What real connections did you make?"
        case .phone: return "How much real life did you experience today? What did you notice off-screen?"
        case .gaming: return "What real-world achievement are you proud of today?"
        case .socialMedia: return "How did you feel without the scroll? What real moments stood out?"
        case .sugar: return "How was your energy today? Did you find healthier ways to treat yourself?"
        case .emotionalEating: return "What emotions came up today? How did you handle them?"
        case .shopping: return "Did you resist any impulse today? What are you grateful for having?"
        case .gambling: return "How did it feel keeping your money safe today?"
        }
    }

    var goalMessage: String {
        switch self {
        case .smoking: return "Your lungs are healing. Keep going — every smoke-free hour counts."
        case .alcohol: return "Your mind is clearing. Clarity is your superpower now."
        case .porn: return "Your brain is rewiring. Real connections are replacing old patterns."
        case .phone: return "You're reclaiming your attention. The real world is beautiful."
        case .gaming: return "You're leveling up in real life. Those are the achievements that matter."
        case .socialMedia: return "You're building authentic confidence. No filter needed."
        case .sugar: return "Your taste buds are resetting. Natural food will taste amazing soon."
        case .emotionalEating: return "You're learning to sit with feelings. That takes real courage."
        case .shopping: return "You're proving that happiness isn't for sale."
        case .gambling: return "Every day gamble-free is money in your pocket and peace in your mind."
        }
    }

    var highRiskMessage: String {
        switch self {
        case .smoking: return "High-risk moment approaching. Remember: the craving will pass in minutes."
        case .alcohol: return "High-risk window ahead. Have your plan ready. You've got this."
        case .porn: return "Be mindful right now. Step away from screens if you can."
        case .phone: return "Put the phone down. Take 3 deep breaths. Look around you."
        case .gaming: return "The game can wait. Your real life can't."
        case .socialMedia: return "Resist the urge to scroll. Do something real instead."
        case .sugar: return "Craving sugar? Drink water first. The urge will pass."
        case .emotionalEating: return "Pause before you eat. Are you hungry, or are you feeling something?"
        case .shopping: return "Before you buy, wait 24 hours. If you still want it tomorrow, reconsider."
        case .gambling: return "The odds are never in your favor. Walk away. Your future self thanks you."
        }
    }

    var healthCounterLabel: String {
        switch self {
        case .smoking: return "cigarettes not smoked"
        case .alcohol: return "drinks avoided"
        case .porn: return "hours of freedom"
        case .phone: return "hours phone-free"
        case .gaming: return "hours AFK"
        case .socialMedia: return "hours scroll-free"
        case .sugar: return "sugar-free days"
        case .emotionalEating: return "mindful days"
        case .shopping: return "no-spend days"
        case .gambling: return "gamble-free days"
        }
    }

    var triggers: [String] {
        switch self {
        case .smoking: return ["After-meal craving", "Morning wake-up craving", "Coffee break craving", "Seeing someone smoke", "While drinking alcohol", "Boredom craving", "Stress craving", "Social smoking pressure"]
        case .alcohol: return ["Social event pressure", "After-work stress", "Lonely evening", "Celebration temptation", "Weekend routine", "Boredom drinking urge", "Peer pressure", "Emotional pain"]
        case .porn: return ["Late night alone", "Boredom urge", "Stress relief seeking", "Feeling lonely", "Saw triggering content", "Before sleep habit", "After an argument", "Emotional numbness"]
        case .phone: return ["First thing in morning", "Waiting around bored", "Anxiety checking", "Before sleep scrolling", "During meals habit", "Mid-conversation urge", "Work procrastination", "Notification pull"]
        case .gaming: return ["After school/work escape", "Boredom gaming", "Stress relief gaming", "Friends are playing", "Weekend binge urge", "Feeling lonely", "Avoiding responsibilities", "Can't sleep"]
        case .socialMedia: return ["Fear of missing out", "Boredom scrolling", "Feeling lonely", "Comparison spiral", "Notification temptation", "Morning routine check", "Before sleep habit", "Seeking validation"]
        case .sugar: return ["After-meal sweet craving", "Stress eating sweets", "Celebration treat", "Boredom snacking", "Seeing sweets nearby", "Afternoon energy crash", "Emotional comfort eating", "Late night craving"]
        case .emotionalEating: return ["Feeling sad", "Anxiety eating", "Loneliness comfort", "Boredom eating", "Anger eating", "Stress overeating", "Tiredness snacking", "Feeling overwhelmed"]
        case .shopping: return ["Payday spending urge", "Stress shopping", "Boredom browsing", "Sale notification", "Social media ad", "Emotional retail therapy", "Celebration buying", "Comparison shopping"]
        case .gambling: return ["Payday urge to bet", "Watching sports urge", "Boredom gambling", "Stress relief betting", "Seeing gambling ads", "Financial desperation", "Winning streak feeling", "Chasing losses"]
        }
    }

    // MARK: - Daily Tips

    static func dailyTip(for program: ProgramType, dayOfYear: Int) -> String {
        let tips = program.programTips
        return tips[dayOfYear % tips.count]
    }

    var programTips: [String] {
        switch self {
        case .smoking: return [
            "Your body starts healing within 20 minutes of your last cigarette.",
            "Deep breathing replaces the hand-to-mouth habit. Try it now.",
            "Chew gum or eat a carrot when a craving hits. Occupy your mouth.",
            "After 48 hours smoke-free, your nerve endings begin to regrow.",
            "Avoid your smoking spots today. Change your route.",
            "Tell one person about your quit today. Accountability helps.",
            "The nicotine craving lasts about 3-5 minutes. You can outlast it.",
            "Drink cold water through a straw — it mimics the inhaling motion.",
            "After 72 hours, breathing gets easier as bronchial tubes relax.",
            "You are not giving something up. You are setting yourself free."
        ]
        case .alcohol: return [
            "Have a non-alcoholic drink ready before social events.",
            "HALT: Check if you're Hungry, Angry, Lonely, or Tired before acting.",
            "Your liver begins to recover within days of stopping.",
            "Plan your response to 'Why aren't you drinking?' before you need it.",
            "Morning clarity is one of the first gifts of sobriety.",
            "Replace your drinking ritual with a new evening routine.",
            "After 2 weeks sober, sleep quality dramatically improves.",
            "You don't need alcohol to be social. You never did.",
            "Track your sober days. Each one is an investment in yourself.",
            "Cravings are waves. They rise, peak, and always pass."
        ]
        case .porn: return [
            "Your brain's dopamine receptors are healing with every clean day.",
            "When urges hit, leave the room. Physical distance creates mental distance.",
            "Real intimacy is built on presence, not pixels.",
            "Install content blockers. Make the right choice the easy choice.",
            "After 2 weeks, many people report improved focus and energy.",
            "Replace screen time with physical activity. Your body will thank you.",
            "Talk to someone you trust about your journey. You're not alone.",
            "Boredom is the #1 trigger. Have a go-to activity ready.",
            "Your brain is literally rewiring itself right now. Be patient.",
            "Every day clean is a vote for the person you want to become."
        ]
        case .phone: return [
            "Put your phone in another room for the first hour after waking.",
            "Turn off non-essential notifications. You control your attention.",
            "Try the 'one sec' technique — pause and breathe before opening any app.",
            "Set a 'phone curfew' — no phone after 9 PM.",
            "Notice how you feel after 30 minutes phone-free. Usually better.",
            "Replace scrolling with reading a physical book.",
            "Charge your phone outside your bedroom tonight.",
            "Count your pickups today. Awareness is the first step.",
            "Your attention is your most valuable asset. Protect it.",
            "Real life has higher resolution than any screen."
        ]
        case .gaming: return [
            "What real-world skill can you level up today?",
            "The satisfaction from completing a real task lasts longer than any game achievement.",
            "Go outside for 15 minutes. Nature is the original open world.",
            "Replace gaming time with one productive hobby this week.",
            "Your sleep improves dramatically when you stop gaming before bed.",
            "Real friendships need face time, not screen time.",
            "Boredom is temporary. Gaming addiction steals years.",
            "Channel your competitive drive into exercise or learning.",
            "After 1 week game-free, notice how much time you actually have.",
            "You're not quitting fun. You're choosing a different kind of fun."
        ]
        case .socialMedia: return [
            "Comparison is the thief of joy. Your real life is enough.",
            "Unfollow accounts that make you feel worse about yourself.",
            "Message a real friend instead of scrolling through feeds.",
            "Most of what you see online is curated, not real.",
            "After 1 week off social media, most people report less anxiety.",
            "You don't need validation from strangers to be worthy.",
            "Replace your first morning scroll with 5 minutes of gratitude.",
            "FOMO is an illusion. You're not missing anything important.",
            "Your self-worth is not measured in likes, follows, or comments.",
            "Be the person who lives life, not the person who watches others live."
        ]
        case .sugar: return [
            "Read food labels today. Sugar hides in surprising places.",
            "Drink a glass of water when a craving hits. Often it's thirst, not hunger.",
            "After 3 days sugar-free, cravings begin to decrease significantly.",
            "Replace sugary snacks with fruit. Your taste buds will adjust.",
            "Sugar crashes cause the tiredness you're trying to fix with more sugar.",
            "Protein and healthy fats keep you satisfied longer than sugar ever will.",
            "Notice your energy levels today. Sugar-free days mean stable energy.",
            "Celebrate with experiences, not food. You deserve better than sugar.",
            "Your skin, mood, and sleep all improve when you reduce sugar.",
            "You're not depriving yourself. You're choosing to feel better."
        ]
        case .emotionalEating: return [
            "Before eating, ask: Am I physically hungry, or emotionally hungry?",
            "Name your feeling before you open the fridge. Sad? Anxious? Bored?",
            "Eat slowly today. Put your fork down between bites.",
            "Feelings are not emergencies. You can sit with discomfort.",
            "Call a friend instead of reaching for food. Connection feeds the soul.",
            "Keep a mood log alongside your food log. Patterns will emerge.",
            "Physical hunger builds gradually. Emotional hunger hits suddenly.",
            "You are not broken for eating emotionally. You're learning a new way.",
            "Find one non-food comfort today: a bath, a walk, music, journaling.",
            "Recovery is not about perfect eating. It's about understanding yourself."
        ]
        case .shopping: return [
            "Unsubscribe from 3 marketing emails today. Remove the temptation.",
            "Before buying, ask: Do I need this, or do I want the feeling of buying?",
            "Wait 24 hours before any non-essential purchase.",
            "Count your blessings, not your packages. Gratitude beats consumption.",
            "Delete shopping apps from your phone. Make it inconvenient.",
            "The dopamine hit from buying fades fast. The debt doesn't.",
            "Window shop with your eyes, not your wallet.",
            "Track what you DIDN'T buy today. That's real progress.",
            "Your home has enough. Your life has enough. You are enough.",
            "Replace shopping with a free activity: walk, read, create, connect."
        ]
        case .gambling: return [
            "The house always wins. Always. That's math, not luck.",
            "Calculate how much you've spent gambling. That number is real.",
            "Self-exclude from online platforms today. Remove the option.",
            "Every day without gambling is money saved and stress reduced.",
            "The excitement of winning is designed to keep you losing.",
            "No amount of winning will ever feel like enough. That's the trap.",
            "Talk to a financial counselor. Recovery includes your finances.",
            "Replace the thrill of gambling with exercise. Same dopamine, zero risk.",
            "Delete betting apps. Make it harder to access, not easier.",
            "Your worth is not determined by wins and losses."
        ]
        }
    }
}
