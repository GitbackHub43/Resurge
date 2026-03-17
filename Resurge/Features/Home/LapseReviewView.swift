import SwiftUI
import CoreData

struct LapseReviewView: View {
    @ObservedObject var habit: CDHabit
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Step State

    @State private var currentStep: Int = 0

    // Step 0 - What happened
    @State private var whatHappened: String = ""

    // Step 1 - Triggers
    @State private var selectedTriggers: Set<String> = []

    // Step 2 - Consequences
    @State private var selectedConsequences: Set<String> = []

    // Step 3 - What helped
    @State private var whatHelped: String = ""

    // Step 4 - If-then plan
    @State private var ifTrigger: String = ""
    @State private var thenAction: String = ""

    // MARK: - Data

    private let triggers = [
        "Stress", "Boredom", "Social pressure", "Loneliness", "Celebration",
        "Habit cue", "Emotional pain", "Physical craving", "Tiredness", "Anger"
    ]

    private let consequences = [
        "Felt guilty", "Wasted money", "Lost time", "Affected health",
        "Hurt relationships", "Broke promise to self", "Felt out of control"
    ]

    private let stepTitles = [
        "What Happened", "Identify Triggers", "Consequences",
        "What Helped", "If-Then Plan", "Self-Compassion"
    ]

    private let totalSteps = 6

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header

                // Progress indicator
                progressIndicator
                    .padding(.top, AppStyle.spacing)
                    .padding(.horizontal, AppStyle.screenPadding)

                // Step content
                ScrollView {
                    VStack(spacing: AppStyle.largeSpacing) {
                        stepContent
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.top, AppStyle.largeSpacing)
                    .padding(.bottom, 100)
                }

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Lapse Review")
                .font(Typography.title)
                .rainbowText()
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
        .padding(.top, 20)
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.neonPurple : Color.cardBorder)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(index == currentStep ? Color.neonPurple.opacity(0.5) : Color.clear, lineWidth: 2)
                            .frame(width: 16, height: 16)
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentStep)

                if index < totalSteps - 1 {
                    Rectangle()
                        .fill(index < currentStep ? Color.neonPurple : Color.cardBorder)
                        .frame(height: 2)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0: stepWhatHappened
        case 1: stepIdentifyTriggers
        case 2: stepConsequences
        case 3: stepWhatHelped
        case 4: stepIfThenPlan
        case 5: stepSelfCompassion
        default: EmptyView()
        }
    }

    // MARK: - Step 0: What Happened

    private var stepWhatHappened: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text(stepTitles[0])
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text("Describe what happened. No judgment — just honesty.")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)

            TextEditor(text: $whatHappened)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .frame(minHeight: 150)
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Step 1: Identify Triggers

    private var stepIdentifyTriggers: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text(stepTitles[1])
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text("What triggered the lapse? Select all that apply.")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppStyle.spacing) {
                ForEach(triggers, id: \.self) { trigger in
                    triggerChip(trigger)
                }
            }
        }
    }

    private func triggerChip(_ trigger: String) -> some View {
        let isSelected = selectedTriggers.contains(trigger)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedTriggers.remove(trigger)
                } else {
                    selectedTriggers.insert(trigger)
                }
            }
        } label: {
            Text(trigger)
                .font(Typography.callout)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.neonPurple.opacity(0.3) : Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(isSelected ? Color.neonPurple.opacity(0.6) : Color.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Step 2: Consequences

    private var stepConsequences: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text(stepTitles[2])
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text("What consequences did you notice? This helps build awareness.")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)

            VStack(spacing: 8) {
                ForEach(consequences, id: \.self) { consequence in
                    consequenceRow(consequence)
                }
            }
        }
    }

    private func consequenceRow(_ consequence: String) -> some View {
        let isSelected = selectedConsequences.contains(consequence)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedConsequences.remove(consequence)
                } else {
                    selectedConsequences.insert(consequence)
                }
            }
        } label: {
            HStack(spacing: AppStyle.spacing) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(isSelected ? Color.neonOrange : .textSecondary)

                Text(consequence)
                    .font(Typography.body)
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)

                Spacer()
            }
            .padding(AppStyle.cardPadding)
            .background(isSelected ? Color.neonOrange.opacity(0.1) : Color.cardBackground)
            .cornerRadius(AppStyle.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                    .stroke(isSelected ? Color.neonOrange.opacity(0.4) : Color.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Step 3: What Helped

    private var stepWhatHelped: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text(stepTitles[3])
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text("Was there anything that helped you cope, even a little? What could help next time?")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)

            TextEditor(text: $whatHelped)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .frame(minHeight: 150)
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Step 4: If-Then Plan

    private var stepIfThenPlan: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text(stepTitles[4])
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text("Create a plan for next time. If a trigger happens, what will you do instead?")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("IF...")
                    .font(Typography.headline)
                    .foregroundColor(.neonGold)

                TextField("e.g., I feel stressed after work", text: $ifTrigger)
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .padding(AppStyle.cardPadding)
                    .background(Color.cardBackground)
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("THEN...")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)

                TextField("e.g., I will go for a 10-minute walk", text: $thenAction)
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .padding(AppStyle.cardPadding)
                    .background(Color.cardBackground)
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Step 5: Self-Compassion

    private var stepSelfCompassion: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            // Compassion icon
            ZStack {
                Circle()
                    .fill(Color.neonMagenta.opacity(0.1))
                    .frame(width: 100, height: 100)

                Circle()
                    .stroke(Color.neonMagenta.opacity(0.3), lineWidth: 2)
                    .frame(width: 90, height: 90)

                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.neonMagenta)
                    .shadow(color: .neonMagenta.opacity(0.6), radius: 12)
            }
            .padding(.top, AppStyle.spacing)

            Text(stepTitles[5])
                .font(Typography.title)
                .rainbowText()

            Text("A lapse is not a relapse. You recognized it, reflected on it, and you\u{2019}re still here. That takes courage.")
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.cardPadding)

            VStack(spacing: AppStyle.spacing) {
                Button {
                    saveLapseReview(resetStreak: false)
                } label: {
                    HStack {
                        Image(systemName: "arrow.forward.circle.fill")
                        Text("Continue Journey")
                    }
                }
                .buttonStyle(RainbowButtonStyle())

                Button {
                    saveLapseReview(resetStreak: true)
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Fresh Start")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonOrange))
            }
            .padding(.top, AppStyle.spacing)
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        Group {
            if currentStep < 5 {
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
                        .buttonStyle(SecondaryButtonStyle(color: .textSecondary))
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                        }
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(RainbowButtonStyle())
                }
            }
        }
    }

    // MARK: - Save Logic

    private func saveLapseReview(resetStreak: Bool) {
        let entry = CDCravingEntry(context: viewContext)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.eventType = "LAPSE_REVIEW"
        entry.triggerCategory = selectedTriggers.joined(separator: ", ")
        entry.triggerNote = whatHappened
        entry.copingToolUsed = whatHelped
        entry.outcome = "used"
        entry.didResist = false
        entry.intensity = 0
        entry.durationSeconds = 0
        entry.mood = 0
        entry.quantity = 0
        entry.habit = habit

        // Encode consequences as JSON array string
        if let jsonData = try? JSONSerialization.data(withJSONObject: Array(selectedConsequences)),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            entry.stateTags = jsonString
        }

        if resetStreak {
            habit.startDate = Date()
        }

        do {
            try viewContext.save()
        } catch {
            // Save failed silently — context will retry on next save
        }

        dismiss()
    }
}

// MARK: - Preview

struct LapseReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Quit Smoking",
            programType: ProgramType.smoking.rawValue
        )
        LapseReviewView(habit: habit)
            .environment(\.managedObjectContext, context)
            .preferredColorScheme(.dark)
    }
}
