import SwiftUI

// MARK: - Recovery Framework Filter

enum RecoveryFramework: String, CaseIterable, Identifiable {
    case all = "All"
    case cbt = "CBT"
    case act = "ACT"
    case smart = "SMART"
    case mbrp = "MBRP"
    case science = "Science"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .all:     return "square.grid.2x2.fill"
        case .cbt:     return "brain.head.profile"
        case .act:     return "arrow.triangle.branch"
        case .smart:   return "target"
        case .mbrp:    return "leaf.fill"
        case .science: return "atom"
        }
    }

    var color: Color {
        switch self {
        case .all:     return .neonCyan
        case .cbt:     return .neonPurple
        case .act:     return .neonGreen
        case .smart:   return .neonOrange
        case .mbrp:    return .neonCyan
        case .science: return .neonMagenta
        }
    }
}

// MARK: - Recovery Article

struct Citation: Identifiable {
    let id = UUID()
    let sourceName: String
    let year: Int
    let documentTitle: String
}

struct RecoveryArticle: Identifiable {
    let id: String
    let title: String
    let summary: String
    let body: String
    let framework: RecoveryFramework
    let readTimeMinutes: Int
    let isPremium: Bool
    let citations: [Citation]
    let licenseNote: String?

    init(
        id: String,
        title: String,
        summary: String,
        body: String,
        framework: RecoveryFramework,
        readTimeMinutes: Int,
        isPremium: Bool,
        citations: [Citation] = [],
        licenseNote: String? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.body = body
        self.framework = framework
        self.readTimeMinutes = readTimeMinutes
        self.isPremium = isPremium
        self.citations = citations
        self.licenseNote = licenseNote
    }

    var readTimeLabel: String {
        "\(readTimeMinutes) min read"
    }
}

// MARK: - Recovery Library Content

struct RecoveryLibrary {
    static let allArticles: [RecoveryArticle] = [
        RecoveryArticle(
            id: "cbt-1", title: "Identifying Cognitive Distortions",
            summary: "Learn to recognize the thought patterns that fuel your habits.",
            body: "Cognitive distortions are exaggerated or irrational thought patterns that reinforce negative thinking. In addiction recovery, these distortions often manifest as all-or-nothing thinking, catastrophizing, or minimizing the consequences of your behavior.\n\nAll-or-nothing thinking sounds like: \"I already slipped up today, so I might as well give in completely.\" This pattern ignores the value of partial progress and turns small setbacks into full relapses.\n\nCatastrophizing amplifies consequences: \"If I can't quit this, my entire life is ruined.\" While your habit may cause real harm, this kind of thinking paralyzes rather than motivates.\n\nThe first step to countering these distortions is simply noticing them. When you catch yourself in a distorted thought, pause and ask: \"Is this thought based on facts, or on feelings?\" Over time, this practice builds a mental habit of rational self-evaluation that weakens the grip of automatic, harmful thoughts.",
            framework: .cbt, readTimeMinutes: 5, isPremium: false
        ),
        RecoveryArticle(
            id: "cbt-2", title: "Thought Records for Cravings",
            summary: "Use structured journaling to break the craving cycle.",
            body: "A thought record is a structured way to examine the thoughts and feelings that arise during a craving. By writing them down, you create distance between yourself and the urge, making it easier to respond rationally rather than reactively.\n\nWhen a craving hits, note: (1) the situation, (2) the automatic thought, (3) the emotion and its intensity (0-100), (4) evidence for the thought, (5) evidence against it, and (6) a balanced alternative thought.\n\nFor example: Situation: \"Stressed after work.\" Thought: \"I deserve this, I've had a hard day.\" Emotion: Frustration (70). Evidence for: \"I did have a hard day.\" Evidence against: \"Giving in always makes me feel worse afterward.\" Alternative: \"I can find a healthier way to decompress.\"\n\nResearch suggests regular use of thought records can significantly reduce craving intensity over time.",
            framework: .cbt, readTimeMinutes: 7, isPremium: false
        ),
        RecoveryArticle(
            id: "act-1", title: "Acceptance & Commitment Basics",
            summary: "Stop fighting cravings and start living by your values.",
            body: "Acceptance and Commitment Therapy (ACT) takes a different approach to cravings: instead of trying to eliminate them, you learn to accept their presence without acting on them.\n\nThe core insight of ACT is that struggling against unwanted thoughts and feelings often makes them stronger. When you tell yourself \"I must not think about this,\" you've already thought about it. ACT teaches you to hold cravings lightly — acknowledging them without giving them power.\n\nThe \"Commitment\" part of ACT is about identifying your personal values and taking action aligned with them, even when it's uncomfortable. Your values become your compass. When a craving arises, you ask: \"What would I do right now if I were living according to my values?\"\n\nThis shift — from avoidance to values-driven action — has been shown to be particularly effective for people who have tried and failed with willpower-based approaches.",
            framework: .act, readTimeMinutes: 6, isPremium: false
        ),
        RecoveryArticle(
            id: "act-2", title: "Defusion: Unhooking from Thoughts",
            summary: "Techniques to create space between you and your urges.",
            body: "Cognitive defusion is an ACT technique that helps you see thoughts as just thoughts — not commands you must obey. When a craving thought arises like \"I need this now,\" defusion helps you step back and observe it without getting caught up in it.\n\nTry this technique: Take the thought \"I need to give in\" and rephrase it as \"I'm having the thought that I need to give in.\" Then try: \"I notice I'm having the thought that I need to give in.\" Each rephrasing creates more psychological distance.\n\nAnother defusion exercise: imagine placing each craving thought on a leaf floating down a stream. You don't push the leaves away or hold onto them — you simply watch them drift past.\n\nDefusion doesn't make cravings disappear. It changes your relationship to them, so they lose their power to dictate your behavior.",
            framework: .act, readTimeMinutes: 5, isPremium: true
        ),
        RecoveryArticle(
            id: "smart-1", title: "SMART Recovery: Self-Empowerment",
            summary: "Build motivation and manage urges with evidence-based tools.",
            body: "SMART Recovery stands for Self-Management and Recovery Training. Unlike 12-step programs, SMART is based on cognitive-behavioral principles and emphasizes self-empowerment over powerlessness.\n\nSMART's four-point program includes: (1) Building and Maintaining Motivation, (2) Coping with Urges, (3) Managing Thoughts, Feelings, and Behaviors, and (4) Living a Balanced Life.\n\nOne key SMART tool is the Cost-Benefit Analysis (CBA). Create a four-quadrant grid: benefits of continuing the habit, costs of continuing, benefits of stopping, and costs of stopping. This exercise often reveals that the perceived benefits of the habit are short-term and superficial, while the costs are long-term and significant.\n\nSMART also uses the DISARM technique for urges: Destructive Images and Self-talk Awareness and Refusal Method. This involves recognizing the \"enemy\" voice that rationalizes giving in, and actively refusing to follow it.",
            framework: .smart, readTimeMinutes: 8, isPremium: false
        ),
        RecoveryArticle(
            id: "mbrp-1", title: "Mindfulness-Based Relapse Prevention",
            summary: "Use present-moment awareness to prevent setbacks.",
            body: "Mindfulness-Based Relapse Prevention (MBRP) combines mindfulness meditation with cognitive-behavioral relapse prevention strategies. It teaches you to observe cravings and triggers with curiosity rather than judgment.\n\nThe foundation of MBRP is the \"urge surfing\" technique. Instead of fighting a craving or giving in to it, you observe it like a wave: it builds, peaks, and naturally subsides. Most cravings, when not acted upon, tend to pass within a relatively short time.\n\nTo practice urge surfing: when a craving arises, sit quietly and notice where you feel it in your body. Is it tension in your chest? Restlessness in your legs? Rate its intensity from 1-10. Breathe into the sensation. Watch as the intensity fluctuates — rising, falling, shifting. You are not the wave; you are the ocean.\n\nRegular mindfulness practice (even 10 minutes daily) has been shown to reduce relapse rates by up to 50% in clinical trials.",
            framework: .mbrp, readTimeMinutes: 6, isPremium: true
        ),
        RecoveryArticle(
            id: "science-1", title: "The Neuroscience of Habit Loops",
            summary: "How your brain creates and breaks habitual patterns.",
            body: "Every habit follows a neurological loop: cue, routine, reward. Understanding this loop is the first step to changing it.\n\nThe cue triggers your brain to initiate the behavior. It could be a time of day, an emotional state, a location, or the presence of certain people. The routine is the behavior itself. The reward is what your brain gets from the behavior — a dopamine hit, stress relief, social connection, or escape from boredom.\n\nThe key insight from neuroscience is that you can't simply delete a habit loop. The neural pathways are permanently etched into your basal ganglia. But you can overwrite the routine while keeping the same cue and reward.\n\nThis is why replacement behaviors are so powerful. If your cue is stress and your reward is relief, you need a new routine that provides genuine relief — exercise, deep breathing, calling a friend — rather than relying on willpower alone.\n\nNeuroplasticity means your brain physically rewires itself with each repetition of the new routine. The old pathways weaken through disuse while the new ones strengthen.",
            framework: .science, readTimeMinutes: 7, isPremium: false
        ),
        RecoveryArticle(
            id: "cbt-3", title: "Behavioral Activation for Recovery",
            summary: "Replace harmful habits by scheduling meaningful activities.",
            body: "Behavioral activation is a CBT technique that combats the emptiness many people feel when they stop a habit. The idea is simple but powerful: instead of focusing on what you're giving up, actively schedule rewarding activities that align with your values.\n\nStart by tracking your daily activities and rating each one for mastery (how accomplished you feel) and pleasure (how enjoyable it is). You'll likely notice patterns — certain times of day or situations where you're most vulnerable.\n\nThen, deliberately schedule alternative activities during those vulnerable windows. The activity doesn't need to be dramatic — a walk, a phone call, cooking a meal, or working on a hobby. The key is that it's planned in advance, so you have a concrete alternative when a craving hits.\n\nOver time, these scheduled activities become natural parts of your routine, building a life that's genuinely fulfilling rather than one that depends on the old habit for stimulation.",
            framework: .cbt, readTimeMinutes: 6, isPremium: true
        ),
        RecoveryArticle(
            id: "smart-2", title: "The Change Plan Worksheet",
            summary: "Create a structured roadmap for lasting behavior change.",
            body: "The Change Plan Worksheet is a SMART Recovery tool that helps you create a concrete, actionable plan for change. Unlike vague resolutions, it forces you to think through the specifics.\n\nThe worksheet covers: (1) The changes I want to make, (2) The most important reasons I want to make these changes, (3) The steps I plan to take, (4) How other people can help me, (5) I will know my plan is working when..., and (6) Things that could interfere with my plan.\n\nThe power of this exercise is in its specificity. \"I want to quit\" becomes \"I will replace my evening habit with a 20-minute walk and journal session, starting Monday. My partner will join me for walks on Tuesday and Thursday. I'll know it's working when I've completed 5 consecutive days.\"\n\nAnticipating obstacles is particularly valuable. By identifying potential challenges in advance, you can prepare contingency plans rather than being caught off guard.",
            framework: .smart, readTimeMinutes: 5, isPremium: false
        ),

        // MARK: - New Articles with Citations

        RecoveryArticle(
            id: "science-3", title: "Understanding Addiction: The Brain Science",
            summary: "How addiction changes your brain and what science tells us about recovery.",
            body: "Addiction is a chronic, relapsing disorder characterized by compulsive drug seeking, continued use despite harmful consequences, and long-lasting changes in the brain. It is considered both a complex brain disorder and a mental illness.\n\nThe brain's reward circuit, centered on the nucleus accumbens, is hijacked by addictive substances and behaviors. Normally, this circuit reinforces healthy behaviors like eating and social bonding. Addictive substances flood this circuit with dopamine, producing intense pleasure that the brain remembers and craves.\n\nOver time, the brain adapts by reducing its natural dopamine production and the number of dopamine receptors. This means you need more of the substance or behavior to feel the same effect (tolerance), and you feel worse without it (withdrawal).\n\nCritically, addiction also affects the prefrontal cortex, which is responsible for decision-making, impulse control, and judgment. This explains why people with addiction often make choices that seem irrational to others — the very brain regions needed for good judgment are compromised.\n\nThe good news from neuroscience is clear: brains can heal. With sustained abstinence, dopamine systems recover, prefrontal function improves, and new neural pathways form. Recovery is not just possible — it is visible on brain scans.",
            framework: .science, readTimeMinutes: 8, isPremium: false,
            citations: [
                Citation(sourceName: "National Institute on Drug Abuse (NIDA)", year: 2020, documentTitle: "Drugs, Brains, and Behavior: The Science of Addiction")
            ]
        ),

        RecoveryArticle(
            id: "science-4", title: "Withdrawal Safety: When to Seek Help",
            summary: "Understand withdrawal risks and when professional medical help is essential.",
            body: "Withdrawal is the body's response to the sudden absence of a substance it has become dependent on. While withdrawal from many substances is uncomfortable but not dangerous, some types of withdrawal can be life-threatening and require medical supervision.\n\nAlcohol withdrawal is one of the most dangerous. Symptoms can range from anxiety, tremors, and insomnia to seizures, hallucinations, and delirium tremens (DTs). DTs occur in a significant number of people undergoing alcohol withdrawal and can be fatal without medical treatment. Symptoms typically begin hours to days after last use and can persist for days.\n\nThese timelines are approximate. Individual experiences vary significantly. This is not medical advice.\n\nBenzodiazepine withdrawal carries similar risks. Abrupt cessation after prolonged use can trigger seizures and, in rare cases, be life-threatening. Medical professionals recommend a gradual taper rather than abrupt discontinuation.\n\nOpioid withdrawal, while intensely uncomfortable, is generally not life-threatening for otherwise healthy adults. However, the severe discomfort drives relapse, which is dangerous because reduced tolerance increases overdose risk.\n\nIMPORTANT: If you have been using alcohol heavily or benzodiazepines regularly, do not attempt to quit suddenly without medical guidance. Contact a healthcare provider or call SAMHSA's National Helpline at 1-800-662-4357 for free, confidential support.",
            framework: .science, readTimeMinutes: 7, isPremium: false,
            citations: [
                Citation(sourceName: "SAMHSA", year: 2015, documentTitle: "TIP 45: Detoxification and Substance Abuse Treatment")
            ],
            licenseNote: "WARNING: Withdrawal from alcohol or benzodiazepines can be life-threatening. Always consult a medical professional before discontinuing these substances."
        ),

        RecoveryArticle(
            id: "science-5", title: "The Science of Habit Change",
            summary: "How habits form and the proven framework for replacing them.",
            body: "Every habit operates through a neurological loop with three components: a cue (the trigger), a routine (the behavior), and a reward (the benefit your brain receives). Understanding this loop is the foundation of lasting change.\n\nCharles Duhigg's research popularized this model, but it builds on decades of behavioral neuroscience. The basal ganglia, a brain region involved in developing emotions, memories, and pattern recognition, stores habit loops so efficiently that they become automatic.\n\nThe golden rule of habit change is this: you cannot extinguish a habit, but you can change it. Keep the same cue and reward, but insert a new routine. A smoker whose cue is stress and whose reward is relief might replace smoking with a five-minute breathing exercise that provides the same sense of calm.\n\nKeystone habits are particularly powerful. These are habits that, when changed, trigger a cascade of other positive changes. Exercise is a classic keystone habit — people who begin exercising regularly often also start eating better, sleeping more, and being more productive.\n\nBelief is the final ingredient. Research shows that habit change is more likely to stick when people believe change is possible. This belief often comes from community — seeing others who have successfully changed reinforces that you can too.",
            framework: .science, readTimeMinutes: 6, isPremium: false,
            citations: [
                Citation(sourceName: "Charles Duhigg", year: 2012, documentTitle: "The Power of Habit: Why We Do What We Do in Life and Business"),
                Citation(sourceName: "National Institute on Drug Abuse (NIDA)", year: 2020, documentTitle: "Drugs, Brains, and Behavior: The Science of Addiction")
            ]
        ),

        RecoveryArticle(
            id: "science-6", title: "Smoking Cessation Benefits Timeline",
            summary: "A day-by-day look at how your body heals after quitting smoking.",
            body: "The following timeline is based on CDC published data. Individual results may vary.\n\nThe health benefits of quitting smoking begin within minutes and continue for years. Understanding this timeline can provide powerful motivation during difficult moments.\n\nWithin 20 minutes of your last cigarette, your heart rate and blood pressure begin to drop. Within 12 hours, the carbon monoxide level in your blood drops to normal, allowing your blood to carry more oxygen.\n\nAfter 2 weeks to 3 months, your circulation improves and your lung function increases. Walking becomes easier. You may notice you can climb stairs without getting winded.\n\nAt 1 to 9 months, coughing and shortness of breath decrease. Cilia (tiny hair-like structures in your lungs) start to regain normal function, increasing their ability to handle mucus, clean the lungs, and reduce the risk of infection.\n\nAt 1 year, your excess risk of coronary heart disease is half that of a continuing smoker's. At 5 years, your risk of cancers of the mouth, throat, esophagus, and bladder is cut in half. Cervical cancer risk falls to that of a non-smoker.\n\nAt 10 years, your risk of dying from lung cancer is about half that of a person who is still smoking. At 15 years, your risk of coronary heart disease is that of a non-smoker's.\n\nEvery smoke-free day is a step toward these milestones. Your body is healing right now.",
            framework: .science, readTimeMinutes: 5, isPremium: false,
            citations: [
                Citation(sourceName: "Centers for Disease Control and Prevention (CDC)", year: 2023, documentTitle: "Benefits of Quitting Smoking Over Time")
            ]
        ),

        RecoveryArticle(
            id: "science-7", title: "Evidence-Based Recovery Approaches",
            summary: "An overview of scientifically validated methods for addiction recovery.",
            body: "Recovery from addiction is supported by a growing body of scientific evidence. Multiple approaches have been validated through rigorous research, and the most effective recovery plans often combine several methods.\n\nCognitive Behavioral Therapy (CBT) helps individuals recognize and change maladaptive thought patterns that lead to substance use. Studies show CBT reduces relapse rates and improves treatment outcomes across multiple substance use disorders.\n\nMotivational Interviewing (MI) is a collaborative conversation style that strengthens a person's own motivation and commitment to change. Meta-analyses show MI is effective in reducing substance use, particularly when combined with other treatments.\n\nContingency Management (CM) uses positive reinforcement — tangible rewards for maintaining sobriety. Research demonstrates that CM produces some of the largest effect sizes of any addiction treatment, yet it remains underutilized.\n\nMedication-Assisted Treatment (MAT) combines behavioral therapy with FDA-approved medications for alcohol and opioid use disorders. MAT is considered the gold standard for opioid use disorder, reducing overdose deaths by 50% or more.\n\nMindfulness-Based Relapse Prevention (MBRP) teaches individuals to observe cravings without acting on them. Clinical trials show MBRP is as effective as traditional relapse prevention and may produce longer-lasting results.\n\nThe most important finding across all research: no single approach works for everyone. Effective recovery is personalized, often combining multiple evidence-based strategies.",
            framework: .science, readTimeMinutes: 9, isPremium: false,
            citations: [
                Citation(sourceName: "SAMHSA", year: 2023, documentTitle: "National Registry of Evidence-Based Programs and Practices (NREPP)")
            ]
        ),
    ]
}

// MARK: - Recovery Library View

struct RecoveryLibraryView: View {
    @EnvironmentObject var environment: AppEnvironment

    @State private var searchText = ""
    @State private var selectedFramework: RecoveryFramework = .all

    private var filteredArticles: [RecoveryArticle] {
        var articles = RecoveryLibrary.allArticles

        if selectedFramework != .all {
            articles = articles.filter { $0.framework == selectedFramework }
        }

        if !searchText.isEmpty {
            articles = articles.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.summary.localizedCaseInsensitiveContains(searchText)
            }
        }

        return articles
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppStyle.spacing) {
                    // MARK: - Search Bar
                    searchBar

                    // MARK: - Framework Filter
                    frameworkFilter

                    // MARK: - Articles List
                    if filteredArticles.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: AppStyle.spacing) {
                            ForEach(filteredArticles) { article in
                                NavigationLink {
                                    ArticleReaderView(article: article)
                                        .environmentObject(environment)
                                } label: {
                                    articleCard(article)
                                }
                            }
                        }
                        .padding(.horizontal, AppStyle.screenPadding)
                    }
                }
                .padding(.vertical, AppStyle.spacing)
            }
        }
        .navigationTitle("Recovery Library")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            TextField("Search articles...", text: $searchText)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.3)
        )
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Framework Filter

    private var frameworkFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RecoveryFramework.allCases) { fw in
                    Button {
                        selectedFramework = fw
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: fw.iconName)
                                .font(Typography.caption)
                            Text(fw.rawValue)
                                .font(Typography.caption)
                                .font(Font.caption.weight(.semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedFramework == fw
                                ? Color.neonCyan
                                : Color.cardBackground
                        )
                        .foregroundColor(
                            selectedFramework == fw
                                ? .white
                                : .textSecondary
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    selectedFramework == fw
                                        ? LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.cardBorder, Color.cardBorder], startPoint: .leading, endPoint: .trailing),
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    // MARK: - Article Card

    private func articleCard(_ article: RecoveryArticle) -> some View {
        HStack(spacing: AppStyle.spacing) {
            // Framework color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(article.framework.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(article.title)
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)

                // Summary
                Text(article.summary)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)

                // Bottom row: framework badge + read time + premium
                HStack(spacing: 8) {
                    // Framework badge
                    HStack(spacing: 4) {
                        Image(systemName: article.framework.iconName)
                            .font(.system(size: 9))
                        Text(article.framework.rawValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(article.framework.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(article.framework.color.opacity(0.15))
                    .cornerRadius(6)

                    // Read time
                    Text(article.readTimeLabel)
                        .font(Typography.footnote)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    // Premium badge
                    if article.isPremium {
                        HStack(spacing: 3) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9))
                            Text("Premium")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.neonGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.neonGold.opacity(0.12))
                        .cornerRadius(6)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppStyle.spacing) {
            Spacer().frame(height: 60)
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            Text("No articles match your search")
                .font(Typography.body)
                .foregroundColor(.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppStyle.screenPadding)
    }
}

// MARK: - Preview

struct RecoveryLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryLibraryView()
                .environmentObject(AppEnvironment.preview)
        }
    }
}
