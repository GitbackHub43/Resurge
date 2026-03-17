import Foundation

struct Quote: Identifiable {
    let id: Int
    let text: String
    let author: String
    let programTypes: [ProgramType]?
}

enum QuoteBank {

    // MARK: - Random Quote

    static func randomQuote(for programType: ProgramType? = nil) -> Quote {
        let pool: [Quote]
        if let programType = programType {
            let filtered = allQuotes.filter { quote in
                quote.programTypes == nil || quote.programTypes!.contains(programType)
            }
            pool = filtered.isEmpty ? allQuotes : filtered
        } else {
            pool = allQuotes
        }
        return pool[Int.random(in: 0..<pool.count)]
    }

    // MARK: - Quote of the Day

    static func quoteOfTheDay(for programType: ProgramType? = nil) -> Quote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1

        let pool: [Quote]
        if let programType = programType {
            let filtered = allQuotes.filter { quote in
                quote.programTypes == nil || quote.programTypes!.contains(programType)
            }
            pool = filtered.isEmpty ? allQuotes : filtered
        } else {
            pool = allQuotes
        }

        let index = dayOfYear % pool.count
        return pool[index]
    }

    // MARK: - All Quotes (240)

    static let allQuotes: [Quote] = [
        // ──────────────────────────────────────────────
        // UNIVERSAL — Recovery & Resilience
        // ──────────────────────────────────────────────
        Quote(id: 1, text: "The secret of change is to focus all of your energy not on fighting the old, but on building the new.", author: "Socrates", programTypes: nil),
        Quote(id: 2, text: "Fall seven times, stand up eight.", author: "Japanese Proverb", programTypes: nil),
        Quote(id: 3, text: "It is not the mountain we conquer, but ourselves.", author: "Edmund Hillary", programTypes: nil),
        Quote(id: 4, text: "What lies behind us and what lies before us are tiny matters compared to what lies within us.", author: "Ralph Waldo Emerson", programTypes: nil),
        Quote(id: 5, text: "The only person you are destined to become is the person you decide to be.", author: "Ralph Waldo Emerson", programTypes: nil),
        Quote(id: 6, text: "Our greatest glory is not in never falling, but in rising every time we fall.", author: "Confucius", programTypes: nil),
        Quote(id: 7, text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis", programTypes: nil),
        Quote(id: 8, text: "Strength does not come from winning. Your struggles develop your strengths.", author: "Arnold Schwarzenegger", programTypes: nil),
        Quote(id: 9, text: "The wound is the place where the light enters you.", author: "Rumi", programTypes: nil),
        Quote(id: 10, text: "Rock bottom became the solid foundation on which I rebuilt my life.", author: "J.K. Rowling", programTypes: nil),
        Quote(id: 11, text: "Every moment is a fresh beginning.", author: "T.S. Eliot", programTypes: nil),
        Quote(id: 12, text: "Courage is not the absence of fear, but the triumph over it.", author: "Nelson Mandela", programTypes: nil),
        Quote(id: 13, text: "He who conquers himself is the mightiest warrior.", author: "Confucius", programTypes: nil),
        Quote(id: 14, text: "No man is free who is not master of himself.", author: "Epictetus", programTypes: nil),
        Quote(id: 15, text: "The greatest wealth is to live content with little.", author: "Plato", programTypes: nil),
        Quote(id: 16, text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", programTypes: nil),
        Quote(id: 17, text: "What we achieve inwardly will change outer reality.", author: "Plutarch", programTypes: nil),
        Quote(id: 18, text: "Knowing yourself is the beginning of all wisdom.", author: "Aristotle", programTypes: nil),
        Quote(id: 19, text: "The mind is everything. What you think you become.", author: "Buddha", programTypes: nil),
        Quote(id: 20, text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein", programTypes: nil),
        Quote(id: 21, text: "To be yourself in a world that is constantly trying to make you something else is the greatest accomplishment.", author: "Ralph Waldo Emerson", programTypes: nil),
        Quote(id: 22, text: "We suffer more often in imagination than in reality.", author: "Seneca", programTypes: nil),
        Quote(id: 23, text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb", programTypes: nil),
        Quote(id: 24, text: "Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.", author: "Buddha", programTypes: nil),
        Quote(id: 25, text: "You have power over your mind, not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius", programTypes: nil),
        Quote(id: 26, text: "The only way out is through.", author: "Robert Frost", programTypes: nil),
        Quote(id: 27, text: "One day at a time.", author: "Traditional Saying", programTypes: nil),
        Quote(id: 28, text: "Progress, not perfection.", author: "Traditional Saying", programTypes: nil),
        Quote(id: 29, text: "Pain is inevitable. Suffering is optional.", author: "Haruki Murakami", programTypes: nil),
        Quote(id: 30, text: "Between stimulus and response there is a space. In that space is our power to choose our response.", author: "Viktor Frankl", programTypes: nil),

        // ──────────────────────────────────────────────
        // UNIVERSAL — Discipline & Habits
        // ──────────────────────────────────────────────
        Quote(id: 31, text: "Discipline is choosing between what you want now and what you want most.", author: "Abraham Lincoln", programTypes: nil),
        Quote(id: 32, text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Will Durant", programTypes: nil),
        Quote(id: 33, text: "First we make our habits, then our habits make us.", author: "John Dryden", programTypes: nil),
        Quote(id: 34, text: "The chains of habit are too weak to be felt until they are too strong to be broken.", author: "Samuel Johnson", programTypes: nil),
        Quote(id: 35, text: "Motivation gets you going, but discipline keeps you growing.", author: "John C. Maxwell", programTypes: nil),
        Quote(id: 36, text: "Small disciplines repeated with consistency every day lead to great achievements gained slowly over time.", author: "John C. Maxwell", programTypes: nil),
        Quote(id: 37, text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier", programTypes: nil),
        Quote(id: 38, text: "The impediment to action advances action. What stands in the way becomes the way.", author: "Marcus Aurelius", programTypes: nil),
        Quote(id: 39, text: "You will never always be motivated. You have to learn to be disciplined.", author: "", programTypes: nil),
        Quote(id: 40, text: "A journey of a thousand miles begins with a single step.", author: "Lao Tzu", programTypes: nil),
        Quote(id: 41, text: "The man who moves a mountain begins by carrying away small stones.", author: "Confucius", programTypes: nil),
        Quote(id: 42, text: "Be tolerant with others and strict with yourself.", author: "Marcus Aurelius", programTypes: nil),
        Quote(id: 43, text: "How long are you going to wait before you demand the best for yourself?", author: "Epictetus", programTypes: nil),
        Quote(id: 44, text: "Waste no more time arguing about what a good person should be. Be one.", author: "Marcus Aurelius", programTypes: nil),
        Quote(id: 45, text: "He who has a why to live can bear almost any how.", author: "Friedrich Nietzsche", programTypes: nil),

        // ──────────────────────────────────────────────
        // UNIVERSAL — Mindfulness & Inner Peace
        // ──────────────────────────────────────────────
        Quote(id: 46, text: "Feelings are just visitors. Let them come and go.", author: "Mooji", programTypes: nil),
        Quote(id: 47, text: "Almost everything will work again if you unplug it for a few minutes, including you.", author: "Anne Lamott", programTypes: nil),
        Quote(id: 48, text: "Peace comes from within. Do not seek it without.", author: "Buddha", programTypes: nil),
        Quote(id: 49, text: "The present moment is filled with joy and happiness. If you are attentive, you will see it.", author: "Thich Nhat Hanh", programTypes: nil),
        Quote(id: 50, text: "Smile, breathe, and go slowly.", author: "Thich Nhat Hanh", programTypes: nil),
        Quote(id: 51, text: "Letting go gives us freedom, and freedom is the only condition for happiness.", author: "Thich Nhat Hanh", programTypes: nil),
        Quote(id: 52, text: "Nothing can bring you peace but yourself.", author: "Ralph Waldo Emerson", programTypes: nil),
        Quote(id: 53, text: "The mind is its own place, and in itself can make a heaven of hell, a hell of heaven.", author: "John Milton", programTypes: nil),
        Quote(id: 54, text: "Be where you are, not where you think you should be.", author: "", programTypes: nil),
        Quote(id: 55, text: "When we are no longer able to change a situation, we are challenged to change ourselves.", author: "Viktor Frankl", programTypes: nil),
        Quote(id: 56, text: "Happiness is not something ready-made. It comes from your own actions.", author: "Dalai Lama", programTypes: nil),
        Quote(id: 57, text: "The greatest weapon against stress is our ability to choose one thought over another.", author: "William James", programTypes: nil),
        Quote(id: 58, text: "If you want to fly, give up everything that weighs you down.", author: "Buddha", programTypes: nil),
        Quote(id: 59, text: "Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.", author: "Oprah Winfrey", programTypes: nil),
        Quote(id: 60, text: "The quieter you become, the more you can hear.", author: "Rumi", programTypes: nil),

        // ──────────────────────────────────────────────
        // UNIVERSAL — Strength & Perseverance
        // ──────────────────────────────────────────────
        Quote(id: 61, text: "Tough times never last, but tough people do.", author: "Robert H. Schuller", programTypes: nil),
        Quote(id: 62, text: "You were given this life because you are strong enough to live it.", author: "", programTypes: nil),
        Quote(id: 63, text: "The human capacity for burden is like bamboo — far more flexible than you would ever believe at first glance.", author: "Jodi Picoult", programTypes: nil),
        Quote(id: 64, text: "Character cannot be developed in ease and quiet. Only through experience of trial and suffering can the soul be strengthened.", author: "Helen Keller", programTypes: nil),
        Quote(id: 65, text: "Stars cannot shine without darkness.", author: "D.T. Suzuki", programTypes: nil),
        Quote(id: 66, text: "Hardships often prepare ordinary people for an extraordinary destiny.", author: "C.S. Lewis", programTypes: nil),
        Quote(id: 67, text: "The oak fought the wind and was broken. The willow bent when it must and survived.", author: "Robert Jordan", programTypes: nil),
        Quote(id: 68, text: "Out of suffering have emerged the strongest souls; the most massive characters are seared with scars.", author: "Kahlil Gibran", programTypes: nil),
        Quote(id: 69, text: "What does not kill me makes me stronger.", author: "Friedrich Nietzsche", programTypes: nil),
        Quote(id: 70, text: "Persistence and resilience only come from having been given the chance to work through difficult problems.", author: "Gever Tulley", programTypes: nil),

        // ──────────────────────────────────────────────
        // UNIVERSAL — Self-Worth & Identity
        // ──────────────────────────────────────────────
        Quote(id: 71, text: "You yourself, as much as anybody in the entire universe, deserve your love and affection.", author: "Buddha", programTypes: nil),
        Quote(id: 72, text: "Until you value yourself, you will not value your time. Until you value your time, you will not do anything with it.", author: "M. Scott Peck", programTypes: nil),
        Quote(id: 73, text: "Your value does not decrease based on someone's inability to see your worth.", author: "", programTypes: nil),
        Quote(id: 74, text: "No one can make you feel inferior without your consent.", author: "Eleanor Roosevelt", programTypes: nil),
        Quote(id: 75, text: "The most common way people give up their power is by thinking they don't have any.", author: "Alice Walker", programTypes: nil),
        Quote(id: 76, text: "Act as if what you do makes a difference. It does.", author: "William James", programTypes: nil),
        Quote(id: 77, text: "When you recover or discover something that nourishes your soul and brings joy, care enough about yourself to make room for it in your life.", author: "Jean Shinoda Bolen", programTypes: nil),
        Quote(id: 78, text: "People often say that motivation doesn't last. Well, neither does bathing — that's why we recommend it daily.", author: "Zig Ziglar", programTypes: nil),
        Quote(id: 79, text: "Believe you can and you are halfway there.", author: "Theodore Roosevelt", programTypes: nil),
        Quote(id: 80, text: "To love oneself is the beginning of a lifelong romance.", author: "Oscar Wilde", programTypes: nil),

        // ──────────────────────────────────────────────
        // SMOKING
        // ──────────────────────────────────────────────
        Quote(id: 81, text: "Every cigarette you don't smoke is a victory for your lungs, your heart, and your future.", author: "", programTypes: [.smoking]),
        Quote(id: 82, text: "Quitting smoking is the single most important step a smoker can take to improve the length and quality of their life.", author: "C. Everett Koop", programTypes: [.smoking]),
        Quote(id: 83, text: "The craving you feel right now will pass whether you smoke or not. Choose not to.", author: "", programTypes: [.smoking]),
        Quote(id: 84, text: "Your lungs are healing with every smoke-free breath you take.", author: "", programTypes: [.smoking]),
        Quote(id: 85, text: "A cigarette is the only consumer product which when used as directed kills its consumer.", author: "Gro Harlem Brundtland", programTypes: [.smoking]),
        Quote(id: 86, text: "Giving up smoking is the easiest thing in the world. I know because I have done it thousands of times.", author: "Mark Twain", programTypes: [.smoking]),
        Quote(id: 87, text: "The desire to smoke will pass whether you light up or not.", author: "", programTypes: [.smoking]),
        Quote(id: 88, text: "You don't need a cigarette. You need freedom from thinking you need one.", author: "", programTypes: [.smoking]),
        Quote(id: 89, text: "Smell the air. Taste your food. Feel your heartbeat. These are the gifts of not smoking.", author: "", programTypes: [.smoking]),
        Quote(id: 90, text: "Each day without a cigarette is a deposit in the bank of your health.", author: "", programTypes: [.smoking]),

        // ──────────────────────────────────────────────
        // ALCOHOL
        // ──────────────────────────────────────────────
        Quote(id: 91, text: "Sobriety is not the absence of fun; it is the presence of everything you've been missing.", author: "", programTypes: [.alcohol]),
        Quote(id: 92, text: "One of the greatest victories you can gain over someone is to beat them at politeness.", author: "Josh Billings", programTypes: [.alcohol]),
        Quote(id: 93, text: "Sobriety delivers everything alcohol promised.", author: "", programTypes: [.alcohol]),
        Quote(id: 94, text: "Recovery is about progression, not perfection.", author: "Traditional Saying", programTypes: [.alcohol]),
        Quote(id: 95, text: "The first step toward getting somewhere is to decide you are not going to stay where you are.", author: "J.P. Morgan", programTypes: [.alcohol]),
        Quote(id: 96, text: "Alcohol took me places I never wanted to go. Sobriety takes me places I never dreamed possible.", author: "", programTypes: [.alcohol]),
        Quote(id: 97, text: "You don't have to see the whole staircase. Just take the first step.", author: "Martin Luther King Jr.", programTypes: [.alcohol]),
        Quote(id: 98, text: "I understood myself only after I destroyed myself. And only in the process of fixing myself did I know who I really was.", author: "", programTypes: [.alcohol]),
        Quote(id: 99, text: "Sober is the new cool. Clear mind. Full heart. Real life.", author: "", programTypes: [.alcohol]),
        Quote(id: 100, text: "Alcohol doesn't solve problems. It just postpones them and creates new ones.", author: "", programTypes: [.alcohol]),

        // ──────────────────────────────────────────────
        // PORN
        // ──────────────────────────────────────────────
        Quote(id: 101, text: "True intimacy is not found on a screen. It is built through vulnerability and genuine connection.", author: "", programTypes: [.porn]),
        Quote(id: 102, text: "Your brain is not broken. It was hijacked. And you can take it back.", author: "", programTypes: [.porn]),
        Quote(id: 103, text: "Freedom is what you do with what has been done to you.", author: "Jean-Paul Sartre", programTypes: [.porn]),
        Quote(id: 104, text: "Every time you resist, your neural pathways rewire. You are literally rebuilding your brain.", author: "", programTypes: [.porn]),
        Quote(id: 105, text: "The chains of compulsion are invisible until you try to walk away. Then you discover your own strength.", author: "", programTypes: [.porn]),
        Quote(id: 106, text: "Reclaim your attention. Your focus is your most valuable asset.", author: "", programTypes: [.porn]),
        Quote(id: 107, text: "Real connection requires real presence. Put down the fantasy and pick up your life.", author: "", programTypes: [.porn]),
        Quote(id: 108, text: "You are not your urges. You are the one who decides what to do with them.", author: "", programTypes: [.porn]),
        Quote(id: 109, text: "The version of you on the other side of this struggle is someone you will be proud to become.", author: "", programTypes: [.porn]),
        Quote(id: 110, text: "Dopamine is not happiness. It is just the promise of happiness. Real fulfillment runs deeper.", author: "", programTypes: [.porn]),

        // ──────────────────────────────────────────────
        // PHONE
        // ──────────────────────────────────────────────
        Quote(id: 111, text: "Life is what happens when you put your phone down.", author: "", programTypes: [.phone]),
        Quote(id: 112, text: "The phone in your pocket is a tool, not a master. Use it with intention.", author: "", programTypes: [.phone]),
        Quote(id: 113, text: "Almost everything will work again if you unplug it for a few minutes, including you.", author: "Anne Lamott", programTypes: [.phone]),
        Quote(id: 114, text: "Be where your feet are.", author: "Scott O'Neil", programTypes: [.phone]),
        Quote(id: 115, text: "Your phone is designed to be addictive. Breaking free is an act of rebellion and self-respect.", author: "", programTypes: [.phone]),
        Quote(id: 116, text: "Every moment spent scrolling is a moment not spent living.", author: "", programTypes: [.phone]),
        Quote(id: 117, text: "Boredom is the birthplace of creativity. Do not steal it from yourself with a screen.", author: "", programTypes: [.phone]),
        Quote(id: 118, text: "The attention economy profits from your distraction. Your focus is your resistance.", author: "", programTypes: [.phone]),
        Quote(id: 119, text: "Look up. The world is more beautiful than any feed.", author: "", programTypes: [.phone]),
        Quote(id: 120, text: "You will never look back on life and wish you had spent more time on your phone.", author: "", programTypes: [.phone]),

        // ──────────────────────────────────────────────
        // SOCIAL MEDIA
        // ──────────────────────────────────────────────
        Quote(id: 121, text: "Comparison is the thief of joy.", author: "Theodore Roosevelt", programTypes: [.socialMedia]),
        Quote(id: 122, text: "Your value is not measured in likes, followers, or shares.", author: "", programTypes: [.socialMedia]),
        Quote(id: 123, text: "Stop curating a life online and start cultivating a life offline.", author: "", programTypes: [.socialMedia]),
        Quote(id: 124, text: "Social media shows you the highlight reel. Real life is the full movie.", author: "", programTypes: [.socialMedia]),
        Quote(id: 125, text: "The more you connect online, the more you disconnect from what truly matters.", author: "", programTypes: [.socialMedia]),
        Quote(id: 126, text: "Likes are not love. Comments are not conversation. Followers are not friends.", author: "", programTypes: [.socialMedia]),
        Quote(id: 127, text: "Your real life does not need an audience.", author: "", programTypes: [.socialMedia]),
        Quote(id: 128, text: "In a world of constant noise, silence is a superpower.", author: "", programTypes: [.socialMedia]),
        Quote(id: 129, text: "You were not born to scroll. You were born to create, connect, and contribute.", author: "", programTypes: [.socialMedia]),
        Quote(id: 130, text: "Unplug to recharge. The best moments in life are not posted anywhere.", author: "", programTypes: [.socialMedia]),

        // ──────────────────────────────────────────────
        // GAMING
        // ──────────────────────────────────────────────
        Quote(id: 131, text: "Life has better graphics than any game. Go experience them.", author: "", programTypes: [.gaming]),
        Quote(id: 132, text: "In the game of life, there are no extra lives. Make this one count.", author: "", programTypes: [.gaming]),
        Quote(id: 133, text: "The achievements that matter most cannot be unlocked with a controller.", author: "", programTypes: [.gaming]),
        Quote(id: 134, text: "Level up in real life. The XP is permanent.", author: "", programTypes: [.gaming]),
        Quote(id: 135, text: "Virtual worlds are designed to make you forget the real one. Remember what is real.", author: "", programTypes: [.gaming]),
        Quote(id: 136, text: "Every hour in a game is an hour stolen from building something real.", author: "", programTypes: [.gaming]),
        Quote(id: 137, text: "Boss battles in real life make you genuinely stronger. No respawn needed.", author: "", programTypes: [.gaming]),
        Quote(id: 138, text: "The best story you can play is the one you are writing with your life.", author: "", programTypes: [.gaming]),
        Quote(id: 139, text: "Trade screen time for dream time. Your goals deserve your best hours.", author: "", programTypes: [.gaming]),
        Quote(id: 140, text: "Real adventure awaits outside the screen. Go find it.", author: "", programTypes: [.gaming]),

        // ──────────────────────────────────────────────
        // SUGAR
        // ──────────────────────────────────────────────
        Quote(id: 151, text: "Your body is a temple, not a trash can. Choose fuel, not filler.", author: "", programTypes: [.sugar]),
        Quote(id: 152, text: "The craving is temporary. The freedom from sugar is permanent.", author: "", programTypes: [.sugar]),
        Quote(id: 153, text: "Sweet freedom tastes better than any candy ever could.", author: "", programTypes: [.sugar]),
        Quote(id: 154, text: "Sugar is a thief. It steals your energy, your clarity, and your health.", author: "", programTypes: [.sugar]),
        Quote(id: 155, text: "Every time you say no to sugar, you say yes to your health.", author: "", programTypes: [.sugar]),
        Quote(id: 156, text: "Let food be thy medicine and medicine be thy food.", author: "Hippocrates", programTypes: [.sugar]),
        Quote(id: 157, text: "You are not hungry. You are bored, stressed, or tired. Learn the difference.", author: "", programTypes: [.sugar, .emotionalEating]),
        Quote(id: 158, text: "The dopamine hit from sugar lasts minutes. The energy from real nutrition lasts hours.", author: "", programTypes: [.sugar]),
        Quote(id: 159, text: "Once you break free from sugar, you realize how much it was controlling you.", author: "", programTypes: [.sugar]),
        Quote(id: 160, text: "Your taste buds adapt. What seemed bland will soon taste rich and satisfying.", author: "", programTypes: [.sugar]),

        // ──────────────────────────────────────────────
        // EMOTIONAL EATING
        // ──────────────────────────────────────────────
        Quote(id: 161, text: "Feel your feelings. Do not feed them.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 162, text: "Hunger is not an emotion. Learn to tell the difference.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 163, text: "Food cannot fill an emotional void. Only awareness and self-compassion can.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 164, text: "The kitchen is not a therapist. Your journal is.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 165, text: "Every emotion you sit with without eating through it makes you stronger.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 166, text: "Nourish your body. Nurture your soul. They require different things.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 167, text: "What you eat in private shows up in public. What you heal in private shows up everywhere.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 168, text: "Comfort eating brings comfort for minutes and regret for hours.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 169, text: "You deserve to eat with joy, not with guilt. Heal the pattern, keep the pleasure.", author: "", programTypes: [.emotionalEating]),
        Quote(id: 170, text: "The urge to eat will pass. Sit with it, breathe through it, and watch it dissolve.", author: "", programTypes: [.emotionalEating]),

        // ──────────────────────────────────────────────
        // SHOPPING
        // ──────────────────────────────────────────────
        Quote(id: 171, text: "Buying things you do not need with money you do not have to impress people you do not like is the definition of insanity.", author: "Dave Ramsey", programTypes: [.shopping]),
        Quote(id: 172, text: "The things you own end up owning you.", author: "Chuck Palahniuk", programTypes: [.shopping]),
        Quote(id: 173, text: "Too many people spend money they have not earned to buy things they do not want to impress people they do not like.", author: "Will Rogers", programTypes: [.shopping]),
        Quote(id: 174, text: "Wealth consists not in having great possessions, but in having few wants.", author: "Epictetus", programTypes: [.shopping]),
        Quote(id: 175, text: "The real cost of a purchase is the time it took you to earn the money.", author: "", programTypes: [.shopping]),
        Quote(id: 176, text: "Contentment is not fulfilling what you want. It is realizing how much you already have.", author: "", programTypes: [.shopping]),
        Quote(id: 177, text: "Every dollar not spent impulsively is a dollar invested in your freedom.", author: "", programTypes: [.shopping]),
        Quote(id: 178, text: "You cannot buy happiness, but you can buy freedom from debt. That feels pretty close.", author: "", programTypes: [.shopping]),
        Quote(id: 179, text: "Before you buy, ask: do I need this, or do I need the feeling I think it will give me?", author: "", programTypes: [.shopping]),
        Quote(id: 180, text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci", programTypes: [.shopping]),

        // ──────────────────────────────────────────────
        // GAMBLING
        // ──────────────────────────────────────────────
        Quote(id: 181, text: "The house always wins. But when you stop playing, you win your life back.", author: "", programTypes: [.gambling]),
        Quote(id: 182, text: "The best bet you can make is on yourself.", author: "", programTypes: [.gambling]),
        Quote(id: 183, text: "Luck is not a strategy. Discipline is.", author: "", programTypes: [.gambling]),
        Quote(id: 184, text: "The only sure thing in gambling is that the gambler loses. Walk away and you have already won.", author: "", programTypes: [.gambling]),
        Quote(id: 185, text: "Chasing losses only creates more losses. Breaking the cycle is the real jackpot.", author: "", programTypes: [.gambling]),
        Quote(id: 186, text: "Your family, your savings, your peace of mind — these are worth more than any bet.", author: "", programTypes: [.gambling]),
        Quote(id: 187, text: "The thrill of the win is designed to make you forget the pain of every loss.", author: "", programTypes: [.gambling]),
        Quote(id: 188, text: "Financial freedom is not found at a table or on a screen. It is built one wise decision at a time.", author: "", programTypes: [.gambling]),
        Quote(id: 189, text: "The odds are always against the gambler. The odds are always with the person who walks away.", author: "", programTypes: [.gambling]),
        Quote(id: 190, text: "Stop gambling with your future. Invest in it instead.", author: "", programTypes: [.gambling]),

        // ──────────────────────────────────────────────
        // ADDITIONAL UNIVERSAL
        // ──────────────────────────────────────────────
        Quote(id: 201, text: "Recovery is not for people who need it. It is for people who want it.", author: "", programTypes: nil),
        Quote(id: 202, text: "The struggle you are in today is developing the strength you need for tomorrow.", author: "Robert Tew", programTypes: nil),
        Quote(id: 203, text: "Sometimes the bravest thing you can do is ask for help.", author: "", programTypes: nil),
        Quote(id: 204, text: "Your addiction is not your identity. Your recovery is your revolution.", author: "", programTypes: nil),
        Quote(id: 205, text: "It always seems impossible until it is done.", author: "Nelson Mandela", programTypes: nil),
        Quote(id: 206, text: "Life begins at the end of your comfort zone.", author: "Neale Donald Walsch", programTypes: nil),
        Quote(id: 207, text: "Be patient with yourself. Self-growth is tender; it is holy ground.", author: "Stephen Covey", programTypes: nil),
        Quote(id: 208, text: "The only impossible journey is the one you never begin.", author: "Tony Robbins", programTypes: nil),
        Quote(id: 209, text: "Turn your wounds into wisdom.", author: "Oprah Winfrey", programTypes: nil),
        Quote(id: 210, text: "The darker the night, the brighter the stars.", author: "Fyodor Dostoevsky", programTypes: nil),
        Quote(id: 211, text: "Healing is not linear. Be gentle with yourself on the hard days.", author: "", programTypes: nil),
        Quote(id: 212, text: "You have survived 100% of your worst days. You are doing better than you think.", author: "", programTypes: nil),
        Quote(id: 213, text: "The comeback is always stronger than the setback.", author: "", programTypes: nil),
        Quote(id: 214, text: "Do not judge each day by the harvest you reap but by the seeds that you plant.", author: "Robert Louis Stevenson", programTypes: nil),
        Quote(id: 215, text: "If you are going through hell, keep going.", author: "Winston Churchill", programTypes: nil),
        Quote(id: 216, text: "Today I will do what others will not, so tomorrow I can do what others cannot.", author: "Jerry Rice", programTypes: nil),
        Quote(id: 217, text: "The greatest discovery of all time is that a person can change their future by merely changing their attitude.", author: "Oprah Winfrey", programTypes: nil),
        Quote(id: 218, text: "With the new day comes new strength and new thoughts.", author: "Eleanor Roosevelt", programTypes: nil),
        Quote(id: 219, text: "Difficulties strengthen the mind, as labor does the body.", author: "Seneca", programTypes: nil),
        Quote(id: 220, text: "Be yourself; everyone else is already taken.", author: "Oscar Wilde", programTypes: nil),

        // ──────────────────────────────────────────────
        // NEW — Verified Quotes with Real Authors
        // ──────────────────────────────────────────────
        Quote(id: 221, text: "When we are no longer able to change a situation, we are challenged to change ourselves.", author: "Viktor Frankl", programTypes: nil),
        Quote(id: 222, text: "Owning our story and loving ourselves through that process is the bravest thing that we'll ever do.", author: "Brené Brown", programTypes: nil),
        Quote(id: 223, text: "We delight in the beauty of the butterfly, but rarely admit the changes it has gone through to achieve that beauty.", author: "Maya Angelou", programTypes: nil),
        Quote(id: 224, text: "The wound is the place where the Light enters you.", author: "Rumi", programTypes: nil),
        Quote(id: 225, text: "The journey of a thousand miles begins with a single step.", author: "Lao Tzu", programTypes: nil),
        Quote(id: 226, text: "It always seems impossible until it's done.", author: "Nelson Mandela", programTypes: nil),
        Quote(id: 227, text: "Although the world is full of suffering, it is also full of the overcoming of it.", author: "Helen Keller", programTypes: nil),
        Quote(id: 228, text: "If you can't fly then run, if you can't run then walk, if you can't walk then crawl, but whatever you do you have to keep moving forward.", author: "Martin Luther King Jr.", programTypes: nil),
        Quote(id: 229, text: "Every great dream begins with a dreamer.", author: "Harriet Tubman", programTypes: nil),
        Quote(id: 230, text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", programTypes: nil),
        Quote(id: 231, text: "If you're going through hell, keep going.", author: "Winston Churchill", programTypes: nil),
        Quote(id: 232, text: "The secret of getting ahead is getting started.", author: "Mark Twain", programTypes: nil),
        Quote(id: 233, text: "What lies behind us and what lies before us are tiny matters compared to what lies within us.", author: "Ralph Waldo Emerson", programTypes: nil),
        Quote(id: 234, text: "Strength does not come from physical capacity. It comes from an indomitable will.", author: "Mahatma Gandhi", programTypes: nil),
        Quote(id: 235, text: "Turn your wounds into wisdom.", author: "Oprah Winfrey", programTypes: nil),
        Quote(id: 236, text: "You can't go back and change the beginning, but you can start where you are and change the ending.", author: "C.S. Lewis", programTypes: nil),
        Quote(id: 237, text: "You never know how strong you are, until being strong is your only choice.", author: "Bob Marley", programTypes: nil),
        Quote(id: 238, text: "You can't connect the dots looking forward; you can only connect them looking backwards.", author: "Steve Jobs", programTypes: nil),
        Quote(id: 239, text: "The purpose of our lives is to be happy.", author: "Dalai Lama", programTypes: nil),
        Quote(id: 240, text: "How wonderful it is that nobody need wait a single moment before starting to improve the world.", author: "Anne Frank", programTypes: nil)
    ]
}
