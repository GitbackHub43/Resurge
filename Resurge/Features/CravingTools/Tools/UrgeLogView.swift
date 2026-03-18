import SwiftUI
import CoreData

struct UrgeLogView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES")
    ) private var habits: FetchedResults<CDHabit>

    // MARK: - State

    @State private var currentStep: Int = 0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var intensity: Double = 5
    @State private var selectedTriggers: Set<String> = []
    @State private var showPatterns: Bool = false
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    // Pattern data
    @State private var totalEntries: Int = 0
    @State private var peakHour: String = "--"
    @State private var topTrigger: String = "--"
    @State private var avgIntensity: String = "--"
    @State private var riskiestDay: String = "--"

    private let triggerOptions: [(id: String, label: String, icon: String)] = [
        ("Stress", "Stress", "bolt.heart.fill"),
        ("Boredom", "Boredom", "clock.fill"),
        ("Loneliness", "Loneliness", "person.fill.questionmark"),
        ("Social", "Social", "person.2.fill"),
        ("Cue", "Cue", "eye.fill"),
        ("Pain", "Pain", "bandage.fill"),
        ("Celebration", "Celebration", "party.popper.fill"),
        ("Tiredness", "Tiredness", "powersleep")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    Spacer().frame(height: 8)

                    if isComplete {
                        completionContent
                    } else {
                        quickLogContent
                    }

                    // Pattern Insights Section
                    if totalEntries >= 7 {
                        patternInsightsSection
                    }

                    Spacer().frame(height: 8)
                }
                .padding(.horizontal, AppStyle.screenPadding)
            }
        }
        .navigationTitle("Urge Log")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "urgeLog", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "urgeLog", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onAppear {
            fetchPatternData()
        }
    }

    // MARK: - Quick Log Content

    private var quickLogContent: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            progressBar

            stepDots

            switch currentStep {
            case 0:
                intensityStep
            case 1:
                triggerStep
            default:
                EmptyView()
            }

            navigationButtons
        }
    }

    // MARK: - Step 1: Intensity

    private var intensityStep: some View {
        VStack(spacing: 24) {
            Text("How intense is this urge?")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            Text("\(Int(intensity))")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(intensityColor)

            Slider(value: $intensity, in: 1...10, step: 1)
                .accentColor(intensityColor)
                .padding(.horizontal, 32)

            HStack {
                Text("Mild")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                Spacer()
                Text("Extreme")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }
            .padding(.horizontal, 32)
        }
    }

    private var intensityColor: Color {
        let val = intensity / 10.0
        if val <= 0.3 { return .neonGreen }
        if val <= 0.6 { return .yellow }
        if val <= 0.8 { return .orange }
        return .neonMagenta
    }

    // MARK: - Step 2: Triggers

    private var triggerStep: some View {
        VStack(spacing: 20) {
            Text("What triggered this urge?")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            let columns = [GridItem(.adaptive(minimum: 90), spacing: 10)]

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(triggerOptions, id: \.id) { trigger in
                    let isSelected = selectedTriggers.contains(trigger.id)
                    Button {
                        if isSelected {
                            selectedTriggers.remove(trigger.id)
                        } else {
                            selectedTriggers.insert(trigger.id)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: trigger.icon)
                                .font(.title3)
                            Text(trigger.label)
                                .font(Typography.caption)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 70)
                        .background(isSelected ? Color.neonMagenta.opacity(0.15) : Color.cardBackground)
                        .foregroundColor(isSelected ? .neonMagenta : .appText)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.neonMagenta : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cardBackground)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.neonCyan, .neonPurple, .neonGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(currentStep + 1) / 2.0, height: 8)
                    .animation(.easeInOut(duration: 0.4), value: currentStep)
            }
        }
        .frame(height: 8)
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        let colors: [Color] = [.neonCyan, .neonGold]
        return HStack(spacing: 10) {
            ForEach(0..<2) { index in
                Circle()
                    .fill(index <= currentStep ? colors[index] : Color.cardBackground)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(colors[index].opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: index <= currentStep ? colors[index].opacity(0.4) : .clear, radius: 4, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: AppStyle.spacing) {
            if currentStep > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonCyan))
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentStep < 1 {
                        currentStep += 1
                    } else {
                        saveEntry()
                        isComplete = true
                        confettiVisible = true
                    }
                }
            } label: {
                HStack {
                    Text(currentStep < 1 ? "Next" : "Log It")
                    if currentStep < 1 {
                        Image(systemName: "chevron.right")
                    } else {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .buttonStyle(RainbowButtonStyle())
        }
    }

    // MARK: - Completion Content

    private var completionContent: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            if confettiVisible {
                SparkleParticlesView(count: 30, colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold])
                    .frame(height: 150)
                    .transition(.opacity)
            }

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.neonGreen)
                .shadow(color: .neonGreen.opacity(0.5), radius: 16, x: 0, y: 0)
                .scaleEffect(confettiVisible ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: confettiVisible)

            Text("Logged!")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("Every log builds your pattern map.\nKnowledge is power over cravings.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)

            Button {
                showResistPopup = true
            } label: {
                Text("Done")
            }
            .buttonStyle(RainbowButtonStyle())
        }
    }

    // MARK: - Pattern Insights Section

    private var patternInsightsSection: some View {
        VStack(spacing: 16) {
            RainbowDivider()

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.neonGold)
                Text("Pattern Insights")
                    .font(Typography.title)
                    .foregroundColor(.appText)
                Spacer()
                Text("\(totalEntries) logs")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }

            let insightColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

            LazyVGrid(columns: insightColumns, spacing: 12) {
                insightCard(icon: "clock.fill", stat: peakHour, label: "Peak Hour", glow: .neonCyan)
                insightCard(icon: "bolt.heart.fill", stat: topTrigger, label: "Top Trigger", glow: .neonMagenta)
                insightCard(icon: "flame.fill", stat: avgIntensity, label: "Avg Intensity", glow: .neonOrange)
                insightCard(icon: "calendar", stat: riskiestDay, label: "Riskiest Day", glow: .neonPurple)
            }
        }
    }

    private func insightCard(icon: String, stat: String, label: String, glow: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(glow)

            Text(stat)
                .font(Typography.headline)
                .foregroundColor(.appText)

            Text(label)
                .font(Typography.caption)
                .foregroundColor(.subtleText)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .neonCard(glow: glow)
    }

    // MARK: - Core Data

    private func saveEntry() {
        guard let habit = habits.first else { return }
        let triggerString = selectedTriggers.joined(separator: ",")
        CDCravingEntry.create(
            in: viewContext,
            habit: habit,
            intensity: Int16(intensity),
            triggerCategory: triggerString.isEmpty ? nil : triggerString,
            copingToolUsed: "urgeLog",
            didResist: true,
            durationSeconds: 0
        )
        do {
            try viewContext.save()
        } catch {
            // Silently handle save errors
        }
        fetchPatternData()
    }

    private func fetchPatternData() {
        guard let habit = habits.first else { return }

        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDCravingEntry.timestamp, ascending: false)]

        guard let entries = try? viewContext.fetch(request), !entries.isEmpty else {
            totalEntries = 0
            return
        }

        totalEntries = entries.count

        // Peak hour
        var hourCounts: [Int: Int] = [:]
        for entry in entries {
            let hour = Calendar.current.component(.hour, from: entry.timestamp)
            hourCounts[hour, default: 0] += 1
        }
        if let peak = hourCounts.max(by: { $0.value < $1.value }) {
            let hour = peak.key
            let formatter = DateFormatter()
            formatter.dateFormat = "h a"
            let cal = Calendar.current
            if let date = cal.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) {
                peakHour = formatter.string(from: date)
            }
        }

        // Top trigger
        var triggerCounts: [String: Int] = [:]
        for entry in entries {
            guard let triggers = entry.triggerCategory else { continue }
            for t in triggers.split(separator: ",") {
                let trimmed = t.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    triggerCounts[trimmed, default: 0] += 1
                }
            }
        }
        if let top = triggerCounts.max(by: { $0.value < $1.value }) {
            topTrigger = top.key
        }

        // Average intensity
        let totalIntensity = entries.reduce(0) { $0 + Int($1.intensity) }
        let avg = Double(totalIntensity) / Double(entries.count)
        avgIntensity = String(format: "%.1f", avg)

        // Riskiest day of week
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var dayCounts: [Int: Int] = [:]
        for entry in entries {
            let weekday = Calendar.current.component(.weekday, from: entry.timestamp)
            dayCounts[weekday, default: 0] += 1
        }
        if let riskiest = dayCounts.max(by: { $0.value < $1.value }) {
            let dayIndex = riskiest.key - 1
            if dayIndex >= 0 && dayIndex < dayNames.count {
                riskiestDay = dayNames[dayIndex]
            }
        }
    }
}

struct UrgeLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UrgeLogView()
        }
        .preferredColorScheme(.dark)
    }
}
