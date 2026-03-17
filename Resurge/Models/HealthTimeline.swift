import Foundation

struct HealthMilestone: Identifiable {
    let id = UUID()
    let timeDescription: String
    let requiredMinutes: Int
    let title: String
    let description: String
    let iconName: String
    let color: String

    // MARK: - Factory

    static func milestones(for programType: ProgramType) -> [HealthMilestone] {
        switch programType {
        case .smoking:          return smokingMilestones
        case .alcohol:          return alcoholMilestones
        case .porn:             return pornMilestones
        case .phone:            return phoneMilestones
        case .socialMedia:      return socialMediaMilestones
        case .gaming:           return gamingMilestones
        case .sugar:            return sugarMilestones
        case .emotionalEating:  return emotionalEatingMilestones
        case .shopping:         return shoppingMilestones
        case .gambling:         return gamblingMilestones
        }
    }

    // MARK: - Smoking (15 milestones)

    private static let smokingMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "20 minutes",
            requiredMinutes: 20,
            title: "Heart Rate Normalizes",
            description: "Your pulse and blood pressure begin to drop back to normal levels.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "8 hours",
            requiredMinutes: 480,
            title: "Carbon Monoxide Drops 50%",
            description: "Carbon monoxide levels in your blood fall by half. Oxygen levels start to recover.",
            iconName: "wind",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Carbon Monoxide Eliminated",
            description: "Your body has cleared all carbon monoxide. Your lungs begin to expel mucus and debris.",
            iconName: "lungs.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "48 hours",
            requiredMinutes: 2_880,
            title: "Taste & Smell Return",
            description: "Nicotine is fully eliminated from your body. Nerve endings begin regrowing, restoring taste and smell.",
            iconName: "nose",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "72 hours",
            requiredMinutes: 4_320,
            title: "Breathing Easier",
            description: "Bronchial tubes relax, making breathing easier. Energy levels increase noticeably.",
            iconName: "bubbles.and.sparkles.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Circulation Improves",
            description: "Blood flow improves throughout your body. Walking and exercise become easier.",
            iconName: "figure.walk",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Cilia Regrow",
            description: "Tiny hair-like structures in your lungs regrow. Coughing and shortness of breath decrease.",
            iconName: "leaf.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Lung Function Up 30%",
            description: "Your lung capacity has improved by up to 30%. Physical activity feels significantly easier.",
            iconName: "chart.line.uptrend.xyaxis",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Less Shortness of Breath",
            description: "Sinus congestion and shortness of breath have dramatically decreased. Cilia are fully functional.",
            iconName: "wind",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "9 months",
            requiredMinutes: 388_800,
            title: "Lungs Significantly Healed",
            description: "Your lungs have substantially repaired themselves. Infections and illness are far less frequent.",
            iconName: "cross.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Heart Disease Risk Halved",
            description: "Your risk of coronary heart disease is now half that of a smoker. A monumental health achievement.",
            iconName: "heart.circle.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "3 years",
            requiredMinutes: 1_576_800,
            title: "Heart Attack Risk Drops",
            description: "Your risk of a heart attack has dropped to near that of someone who has never smoked.",
            iconName: "bolt.heart.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "5 years",
            requiredMinutes: 2_628_000,
            title: "Stroke Risk Normalized",
            description: "Your stroke risk has dropped to the same level as a non-smoker.",
            iconName: "brain.head.profile",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "10 years",
            requiredMinutes: 5_256_000,
            title: "Lung Cancer Risk Halved",
            description: "Your risk of dying from lung cancer is now half that of a continuing smoker.",
            iconName: "shield.checkered",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "15 years",
            requiredMinutes: 7_884_000,
            title: "Heart Disease Risk Equals Non-Smoker",
            description: "Your risk of heart disease is now the same as someone who has never smoked. Full recovery achieved.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Alcohol (12 milestones)

    private static let alcoholMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "6 hours",
            requiredMinutes: 360,
            title: "Cravings Peak",
            description: "Initial withdrawal cravings reach their highest intensity. Your body is beginning to adjust.",
            iconName: "flame.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Blood Sugar Normalizes",
            description: "Blood sugar levels begin stabilizing. Your body starts metabolizing stored nutrients properly.",
            iconName: "drop.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Withdrawal Symptoms Peak",
            description: "Physical withdrawal symptoms reach their maximum. After this point, they begin to subside.",
            iconName: "waveform.path.ecg",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Sleep Improves",
            description: "Sleep quality begins to improve. REM sleep cycles start normalizing, leading to more restorative rest.",
            iconName: "moon.stars.fill",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Stomach Lining Heals",
            description: "Your stomach lining begins to repair. Acid reflux and gastritis symptoms start to diminish.",
            iconName: "cross.circle.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Liver Fat Reduces",
            description: "Liver fat can reduce by up to 15%. Your liver is actively regenerating healthy tissue.",
            iconName: "leaf.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Blood Pressure Normalizes",
            description: "Blood pressure returns to healthier levels. Cardiovascular function measurably improves.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Liver Function Improves",
            description: "Liver function tests show significant improvement. Inflammation markers drop substantially.",
            iconName: "chart.line.downtrend.xyaxis",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "9 months",
            requiredMinutes: 388_800,
            title: "Brain Gray Matter Regenerates",
            description: "Brain gray matter begins to regenerate. Cognitive function, memory, and focus improve noticeably.",
            iconName: "brain.head.profile",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Liver Cirrhosis Risk Drops",
            description: "Risk of liver cirrhosis is significantly reduced. Overall organ health has markedly improved.",
            iconName: "shield.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "2 years",
            requiredMinutes: 1_051_200,
            title: "Cardiovascular Risk Reduced",
            description: "Cardiovascular disease risk is significantly reduced. Heart muscle function has substantially recovered.",
            iconName: "heart.circle.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "5 years",
            requiredMinutes: 2_628_000,
            title: "Brain Fully Recovered",
            description: "Brain structure and function have fully recovered. Cognitive abilities match those of non-drinkers.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Porn (10 milestones)

    private static let pornMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Dopamine Receptors Begin Resetting",
            description: "Your brain's reward system starts recalibrating after the constant overstimulation stops.",
            iconName: "brain.head.profile",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Urge Intensity Peaks",
            description: "Cravings are at their strongest. Your prefrontal cortex is beginning to regain control over impulses.",
            iconName: "flame.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Mental Clarity Begins",
            description: "Brain fog starts lifting. You may notice improved focus and reduced mental fatigue.",
            iconName: "lightbulb.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Emotional Sensitivity Returns",
            description: "Emotional blunting decreases. You begin feeling a wider range of genuine emotions.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Dopamine Baseline Recalibrates",
            description: "Dopamine receptor density begins normalizing. Everyday activities start feeling more rewarding.",
            iconName: "arrow.up.heart.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Social Confidence Improves",
            description: "Reduced shame and objectification patterns lead to healthier social interactions and eye contact.",
            iconName: "person.2.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Neural Pathways Rewired",
            description: "The brain has formed new neural pathways. Old compulsive patterns are significantly weakened.",
            iconName: "network",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Intimacy Connection Deepens",
            description: "Capacity for genuine emotional and physical intimacy is substantially restored.",
            iconName: "heart.circle.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Full Dopamine Recovery",
            description: "Reward system has fully recalibrated. Motivation and pleasure from healthy sources feel natural.",
            iconName: "star.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "2 years",
            requiredMinutes: 1_051_200,
            title: "Identity Transformation Complete",
            description: "The compulsive behavior is no longer part of your identity. Deep psychological freedom achieved.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Phone (10 milestones)

    private static let phoneMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "2 hours",
            requiredMinutes: 120,
            title: "Phantom Vibrations Fade",
            description: "The urge to check your phone reflexively begins to diminish. You are breaking the autopilot loop.",
            iconName: "iphone.slash",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Present Moment Awareness",
            description: "Without constant notifications, you begin noticing your environment more fully.",
            iconName: "eye.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Attention Span Begins Recovering",
            description: "Your brain starts adjusting to longer periods without stimulation. Focus improves incrementally.",
            iconName: "brain.head.profile",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Sleep Quality Improves",
            description: "Reduced blue light exposure and pre-sleep scrolling lead to better melatonin production and deeper sleep.",
            iconName: "moon.stars.fill",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Reduced Anxiety",
            description: "Without the constant stream of information, baseline anxiety levels begin to drop.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Deep Work Capacity Returns",
            description: "Your ability to sustain focused, uninterrupted work for extended periods is significantly restored.",
            iconName: "brain",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Relationships Strengthen",
            description: "Being fully present in conversations and activities leads to deeper, more meaningful connections.",
            iconName: "person.2.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Dopamine System Rebalanced",
            description: "Your reward system no longer craves constant micro-hits of novelty. Sustained attention feels natural.",
            iconName: "chart.line.uptrend.xyaxis",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Creativity Flourishes",
            description: "Boredom tolerance has increased, unlocking deeper creative thinking and problem-solving abilities.",
            iconName: "paintbrush.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Intentional Living Mastered",
            description: "Technology serves you, not the other way around. You have built a healthy, intentional relationship with your devices.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Social Media (11 milestones)

    private static let socialMediaMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "1 hour",
            requiredMinutes: 60,
            title: "FOMO Awareness",
            description: "The fear of missing out is strongest right now. Recognizing it is the first step to freedom.",
            iconName: "bell.slash.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Comparison Cycle Breaks",
            description: "Without constant exposure to curated lives, social comparison begins to diminish.",
            iconName: "person.fill.xmark",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Reduced Information Overload",
            description: "Mental bandwidth frees up as your brain stops processing endless feeds of content.",
            iconName: "brain.head.profile",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Self-Esteem Stabilizes",
            description: "Without likes and follower counts, your self-worth begins anchoring to internal values instead.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Sleep and Mood Improve",
            description: "Less evening scrolling leads to better sleep. Mood becomes more stable without emotional triggering.",
            iconName: "moon.stars.fill",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Authentic Connection Grows",
            description: "You begin seeking out face-to-face or meaningful conversations instead of surface-level interactions.",
            iconName: "person.2.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Attention Span Recovers",
            description: "The ability to read long-form content and stay focused without checking feeds returns.",
            iconName: "book.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Identity Detaches from Online Persona",
            description: "Your sense of self is no longer tied to an online profile. Authenticity in daily life increases.",
            iconName: "person.fill.checkmark",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Reclaimed Hours Add Up",
            description: "Hundreds of hours have been redirected to hobbies, relationships, and personal growth.",
            iconName: "clock.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Grounded Self-Image",
            description: "Your self-worth is fully internal. External validation no longer drives your decisions or mood.",
            iconName: "shield.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "2 years",
            requiredMinutes: 1_051_200,
            title: "Digital Sovereignty Achieved",
            description: "You control your digital life with complete intentionality. The addiction loop is fully broken.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Gaming (10 milestones)

    private static let gamingMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "12 hours",
            requiredMinutes: 720,
            title: "Restlessness Peaks",
            description: "The boredom and restlessness are strongest now. Your brain is searching for its usual dopamine source.",
            iconName: "flame.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Sleep Schedule Resets",
            description: "Without late-night gaming sessions, your circadian rhythm begins to normalize.",
            iconName: "moon.stars.fill",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Physical Activity Increases",
            description: "With free time available, natural movement and exercise begin replacing sedentary hours.",
            iconName: "figure.walk",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Eye Strain Reduces",
            description: "Reduced screen time leads to less eye fatigue, fewer headaches, and improved visual comfort.",
            iconName: "eye.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Real-World Skills Develop",
            description: "Time previously spent gaming is redirected to learning new skills, hobbies, and personal projects.",
            iconName: "hammer.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Emotional Regulation Improves",
            description: "Without gaming as an escape, you develop healthier coping mechanisms for stress and frustration.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Dopamine Rebalanced",
            description: "Your reward system recalibrates. Achievement in real life feels genuinely rewarding again.",
            iconName: "brain.head.profile",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Social Life Revitalized",
            description: "Real-world friendships and social activities have replaced online-only connections.",
            iconName: "person.3.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Career or Academic Growth",
            description: "Thousands of reclaimed hours translate into measurable progress in career, education, or personal goals.",
            iconName: "chart.line.uptrend.xyaxis",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "2 years",
            requiredMinutes: 1_051_200,
            title: "Balanced Digital Life",
            description: "Gaming no longer dominates your identity. You have a healthy, controlled relationship with entertainment.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Sugar (10 milestones)

    private static let sugarMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "6 hours",
            requiredMinutes: 360,
            title: "Blood Sugar Stabilizes",
            description: "Without a sugar spike, your blood glucose begins to level out. Insulin response normalizes.",
            iconName: "drop.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Cravings Intensify",
            description: "Sugar cravings are at their strongest as your body adjusts to stable energy sources.",
            iconName: "flame.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Energy Levels Even Out",
            description: "Without sugar crashes, your energy becomes more consistent throughout the day.",
            iconName: "bolt.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Taste Buds Reset",
            description: "Foods begin tasting sweeter naturally. Your palate recalibrates to appreciate subtle flavors.",
            iconName: "mouth.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Skin Begins Clearing",
            description: "Reduced inflammation from sugar leads to fewer breakouts and improved skin clarity.",
            iconName: "face.smiling.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Inflammation Decreases",
            description: "Systemic inflammation drops measurably. Joint pain and bloating may significantly decrease.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Weight Stabilizes",
            description: "Without excess sugar, your body naturally regulates weight. Fat storage patterns begin changing.",
            iconName: "scalemass.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Hormonal Balance Improves",
            description: "Insulin sensitivity improves significantly. Hormonal fluctuations caused by sugar spikes stabilize.",
            iconName: "chart.line.uptrend.xyaxis",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Cardiovascular Health Improves",
            description: "Triglyceride levels drop. Blood pressure and cholesterol markers show measurable improvement.",
            iconName: "heart.circle.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Metabolic Transformation",
            description: "Your metabolism has fully adapted. Diabetes risk is significantly reduced and energy is abundant.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Emotional Eating (10 milestones)

    private static let emotionalEatingMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "4 hours",
            requiredMinutes: 240,
            title: "Urge Surfing Begins",
            description: "You have ridden out the first emotional eating urge. Each time gets a little easier.",
            iconName: "water.waves",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Emotional Awareness Grows",
            description: "Without food as a buffer, you begin to identify the actual emotions driving the urge.",
            iconName: "eye.fill",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Alternative Coping Explored",
            description: "You start discovering other ways to process emotions: journaling, movement, conversation.",
            iconName: "pencil.and.outline",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Hunger Signals Clarify",
            description: "You begin distinguishing between physical hunger and emotional hunger more clearly.",
            iconName: "lightbulb.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Digestive System Calms",
            description: "Without binge episodes, your digestive system stabilizes. Bloating and discomfort decrease.",
            iconName: "leaf.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Emotional Resilience Builds",
            description: "You can sit with uncomfortable emotions without reaching for food. Distress tolerance is growing.",
            iconName: "shield.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Body Image Improves",
            description: "Breaking the binge-guilt cycle leads to a healthier relationship with your body.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Mindful Eating Established",
            description: "Eating has become a conscious, enjoyable activity rather than an emotional reaction.",
            iconName: "brain.head.profile",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Emotional Processing Mastered",
            description: "Healthy emotional coping is now your default. Food is nourishment, not therapy.",
            iconName: "star.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Freedom from Food Fixation",
            description: "Food no longer controls your emotional life. You have a peaceful, balanced relationship with eating.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Shopping (10 milestones)

    private static let shoppingMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "6 hours",
            requiredMinutes: 360,
            title: "Impulse Resisted",
            description: "You resisted the first strong urge to make an unnecessary purchase. The dopamine craving fades.",
            iconName: "hand.raised.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Buyer's Clarity",
            description: "Without impulse purchases, you begin to see how many past buys were emotionally driven.",
            iconName: "eye.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Notification Triggers Identified",
            description: "You recognize how sales alerts, ads, and apps trigger the urge to shop.",
            iconName: "bell.slash.fill",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Financial Awareness Grows",
            description: "You start tracking where your money actually goes. Financial anxiety begins to decrease.",
            iconName: "dollarsign.circle.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Emotional Needs Identified",
            description: "You begin understanding what emotional need shopping was fulfilling: comfort, control, excitement.",
            iconName: "heart.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Savings Begin Accumulating",
            description: "Money that would have been spent impulsively starts building up. Financial security grows.",
            iconName: "banknote.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Gratitude for What You Have",
            description: "Contentment with current possessions grows. The desire for more begins to quiet.",
            iconName: "gift.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Debt Reduction Progress",
            description: "Consistent avoidance of unnecessary spending leads to measurable debt reduction.",
            iconName: "chart.line.downtrend.xyaxis",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Financial Freedom Approaching",
            description: "Significant savings accumulated. Financial stress is markedly reduced and future planning improves.",
            iconName: "star.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Mindful Consumer",
            description: "Every purchase is intentional and aligned with your values. Shopping addiction is behind you.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

    // MARK: - Gambling (11 milestones)

    private static let gamblingMilestones: [HealthMilestone] = [
        HealthMilestone(
            timeDescription: "1 hour",
            requiredMinutes: 60,
            title: "Urge Acknowledged",
            description: "You recognized the gambling urge and chose not to act on it. Awareness is the first victory.",
            iconName: "hand.raised.fill",
            color: "#FF6B35"
        ),
        HealthMilestone(
            timeDescription: "24 hours",
            requiredMinutes: 1_440,
            title: "Chasing Losses Stops",
            description: "One full day without trying to win back what was lost. The cycle of chasing is broken.",
            iconName: "xmark.octagon.fill",
            color: "#FF2D92"
        ),
        HealthMilestone(
            timeDescription: "3 days",
            requiredMinutes: 4_320,
            title: "Financial Bleeding Stops",
            description: "Three days of no gambling means money has stopped flowing out to bets and wagers.",
            iconName: "dollarsign.circle.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "1 week",
            requiredMinutes: 10_080,
            title: "Sleep and Stress Improve",
            description: "Without the anxiety of active bets and losses, sleep quality and stress levels improve.",
            iconName: "moon.stars.fill",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "2 weeks",
            requiredMinutes: 20_160,
            title: "Dopamine System Adjusting",
            description: "Your brain begins recalibrating away from the extreme highs and lows of gambling outcomes.",
            iconName: "brain.head.profile",
            color: "#BF40FF"
        ),
        HealthMilestone(
            timeDescription: "1 month",
            requiredMinutes: 43_200,
            title: "Trust Begins Rebuilding",
            description: "Loved ones start to see consistent change. Relationship repair becomes possible.",
            iconName: "person.2.fill",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "2 months",
            requiredMinutes: 86_400,
            title: "Financial Planning Resumes",
            description: "Budgeting and saving become possible again. Financial control is being restored.",
            iconName: "banknote.fill",
            color: "#39FF14"
        ),
        HealthMilestone(
            timeDescription: "3 months",
            requiredMinutes: 129_600,
            title: "Cognitive Distortions Weaken",
            description: "Magical thinking about luck and systems fades. Rational decision-making strengthens.",
            iconName: "lightbulb.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "6 months",
            requiredMinutes: 259_200,
            title: "Significant Savings Recovered",
            description: "Money that would have been gambled away has been saved. Financial security is tangible.",
            iconName: "chart.line.uptrend.xyaxis",
            color: "#00F5FF"
        ),
        HealthMilestone(
            timeDescription: "1 year",
            requiredMinutes: 525_600,
            title: "Complete Risk Recalibration",
            description: "Your relationship with risk and reward has fully normalized. Healthy excitement comes from real life.",
            iconName: "shield.fill",
            color: "#FFD700"
        ),
        HealthMilestone(
            timeDescription: "2 years",
            requiredMinutes: 1_051_200,
            title: "Financial and Emotional Freedom",
            description: "Gambling no longer holds any power over you. Financial and emotional recovery is complete.",
            iconName: "sparkles",
            color: "#FFD700"
        )
    ]

}
