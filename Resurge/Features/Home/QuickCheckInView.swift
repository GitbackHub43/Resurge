import SwiftUI
import CoreData

struct QuickCheckInView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    let habit: CDHabit
    var initialEntry: CDDailyLogEntry? = nil

    @State private var selectedMood: Int = 3
    @State private var didLapse: Bool = false
    @State private var hasCravings: Bool = false
    @State private var cravingIntensity: Double = 5
    @State private var lapseNotes = ""
    @State private var showSuccess = false
    @State private var hasInteractedWithMood = false
    @State private var existingEntry: CDDailyLogEntry?
    @State private var hasLoadedData = false
    @State private var isUpdate = false

    private var programType: ProgramType {
        ProgramType(rawValue: habit.programType) ?? .smoking
    }

    private let moodEmojis = ["\u{1F61E}", "\u{1F61F}", "\u{1F610}", "\u{1F642}", "\u{1F604}"]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            checkInContent
        }
        .onAppear {
            isUpdate = false
            existingEntry = nil
            loadExistingEntry()
        }
        .fullScreenCover(isPresented: $showSuccess) {
            successView
        }
    }

    // MARK: - Check-In Content

    private var entryDate: String {
        let f = DateFormatter(); f.dateStyle = .long
        return f.string(from: existingEntry?.createdAt ?? initialEntry?.createdAt ?? DebugDate.now)
    }

    private var checkInContent: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            // Header
            VStack(spacing: 4) {
                HStack {
                    Text("Afternoon Check-In")
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
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill").foregroundColor(.neonCyan)
                    Text(entryDate).font(Typography.callout).foregroundColor(.textSecondary)
                    Spacer()
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.top, 20)

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    // Mood Section
                    VStack(spacing: 16) {
                        Text("How are you feeling right now?")
                            .font(Typography.headline)
                            .foregroundColor(.textPrimary)

                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { value in
                                Button {
                                    HapticManager.tap()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedMood = value
                                        hasInteractedWithMood = true
                                    }
                                } label: {
                                    Text(moodEmojis[value - 1])
                                        .font(.system(size: selectedMood == value ? 44 : 32))
                                        .scaleEffect(selectedMood == value ? 1.1 : 1.0)
                                        .opacity(selectedMood == value ? 1.0 : 0.5)
                                        .animation(.easeInOut(duration: 0.2), value: selectedMood)
                                }
                            }
                        }

                        Text(moodLabel)
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .neonCard(glow: moodColor)

                    // Lapse Section
                    VStack(spacing: 16) {
                        Text("Did you lapse up until this moment?")
                            .font(Typography.headline)
                            .foregroundColor(.textPrimary)

                        HStack(spacing: 16) {
                            Button {
                                HapticManager.tap()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    didLapse = false
                                }
                            } label: {
                                HStack {
                                    Image(systemName: didLapse ? "circle" : "checkmark.circle.fill")
                                    Text("No")
                                }
                                .font(Typography.headline)
                                .foregroundColor(didLapse ? .textSecondary : .neonGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(didLapse ? Color.cardBackground : Color.neonGreen.opacity(0.15))
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(didLapse ? Color.cardBorder : Color.neonGreen.opacity(0.4), lineWidth: 1)
                                )
                            }

                            Button {
                                HapticManager.tap()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    didLapse = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: didLapse ? "checkmark.circle.fill" : "circle")
                                    Text("Yes")
                                }
                                .font(Typography.headline)
                                .foregroundColor(didLapse ? .neonOrange : .textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(didLapse ? Color.neonOrange.opacity(0.15) : Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(didLapse ? Color.neonOrange.opacity(0.4) : Color.cardBorder, lineWidth: 1)
                                )
                            }
                        }

                        if didLapse {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Explain what happened")
                                    .font(Typography.caption).foregroundColor(.neonOrange)
                                TextEditor(text: $lapseNotes)
                                    .font(Typography.body).foregroundColor(.textPrimary)
                                    .frame(minHeight: 60)
                                    .padding(4)
                                    .background(Color.cardBackground)
                                    .cornerRadius(AppStyle.smallCornerRadius)
                            }
                        }
                    }
                    .neonCard(glow: didLapse ? .neonOrange : .neonCyan)

                    // Craving Section
                    VStack(spacing: 16) {
                        Text("Any cravings today?")
                            .font(Typography.headline)
                            .foregroundColor(.textPrimary)

                        HStack(spacing: 16) {
                            Button {
                                HapticManager.tap()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hasCravings = false
                                }
                            } label: {
                                HStack {
                                    Image(systemName: hasCravings ? "circle" : "checkmark.circle.fill")
                                    Text("No")
                                }
                                .font(Typography.headline)
                                .foregroundColor(hasCravings ? .textSecondary : .neonGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(hasCravings ? Color.cardBackground : Color.neonGreen.opacity(0.15))
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(hasCravings ? Color.cardBorder : Color.neonGreen.opacity(0.4), lineWidth: 1)
                                )
                            }

                            Button {
                                HapticManager.tap()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hasCravings = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: hasCravings ? "checkmark.circle.fill" : "circle")
                                    Text("Yes")
                                }
                                .font(Typography.headline)
                                .foregroundColor(hasCravings ? .neonOrange : .textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(hasCravings ? Color.neonOrange.opacity(0.15) : Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(hasCravings ? Color.neonOrange.opacity(0.4) : Color.cardBorder, lineWidth: 1)
                                )
                            }
                        }

                        if hasCravings {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Intensity")
                                        .font(Typography.caption)
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    Text("\(Int(cravingIntensity))/10")
                                        .font(Typography.headline)
                                        .foregroundColor(intensityColor)
                                }

                                Slider(value: $cravingIntensity, in: 1...10, step: 1)
                                    .accentColor(intensityColor)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .neonCard(glow: hasCravings ? .neonOrange : .neonCyan)
                }
                .padding(.horizontal, AppStyle.screenPadding)
            }

            // Done Button
            Button {
                saveCheckIn()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(existingEntry != nil ? "Update!" : "Done!")
                }
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 20) {
            Spacer()

            if didLapse {
                // Lapse comfort message
                ZStack {
                    Circle()
                        .fill(Color.neonCyan.opacity(0.08))
                        .frame(width: 160, height: 160)
                    Circle()
                        .stroke(Color.neonCyan.opacity(0.2), lineWidth: 2)
                        .frame(width: 140, height: 140)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.neonCyan)
                        .shadow(color: .neonCyan.opacity(0.5), radius: 20)
                }

                Text("It's okay. You're still here.")
                    .font(Typography.title)
                    .foregroundColor(.neonCyan)

                VStack(spacing: 8) {
                    Text("A lapse is not a collapse. Your timer has reset, but everything you've learned stays with you.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)

                    Text("The fact that you're being honest about it means you're still fighting. That takes real courage.")
                        .font(Font.callout.italic())
                        .foregroundColor(.neonCyan.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            } else {
                ZStack {
                    Circle()
                        .fill(Color.neonGreen.opacity(0.1))
                        .frame(width: 160, height: 160)
                    Circle()
                        .stroke(Color.neonGreen.opacity(0.3), lineWidth: 2)
                        .frame(width: 140, height: 140)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.neonGreen)
                        .shadow(color: .neonGreen.opacity(0.6), radius: 20)
                }

                Text(isUpdate ? "Updated!" : "Afternoon Check-in Complete!")
                    .font(Typography.title)
                    .rainbowText()

                Text("You're halfway through the day. Stay strong.")
                    .font(Typography.body)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(Typography.headline)
                    .foregroundColor(.neonCyan)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan.opacity(0.12))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.neonCyan.opacity(0.3), lineWidth: 1))
            }
            .padding(.bottom, 40)
        }
        .transition(.opacity)
        .background(Color.appBackground)
    }

    // MARK: - Helpers

    private var moodLabel: String {
        switch selectedMood {
        case 1: return "Struggling"
        case 2: return "Not great"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great"
        default: return "Okay"
        }
    }

    private var moodColor: Color {
        switch selectedMood {
        case 1, 2: return .neonOrange
        case 3: return .neonGold
        case 4, 5: return .neonGreen
        default: return .neonCyan
        }
    }

    private var intensityColor: Color {
        if cravingIntensity <= 3 {
            return .neonGreen
        } else if cravingIntensity <= 6 {
            return .neonGold
        } else {
            return .neonOrange
        }
    }

    // MARK: - Load Existing Entry

    private func loadExistingEntry() {
        if let entry = initialEntry {
            populateFromEntry(entry)
            return
        }

        let today = DebugDate.startOfToday
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date == %@", today as NSDate),
            NSPredicate(format: "entryType == %@", "afternoon")
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDDailyLogEntry.createdAt, ascending: false)]
        request.fetchLimit = 1

        if let entry = try? viewContext.fetch(request).first {
            populateFromEntry(entry)
        }
    }

    private func populateFromEntry(_ entry: CDDailyLogEntry) {
        existingEntry = entry
        isUpdate = true
        selectedMood = Int(entry.mood)
        if selectedMood < 1 || selectedMood > 5 { selectedMood = 3 }
        hasInteractedWithMood = true
        didLapse = entry.lapsedToday
        lapseNotes = entry.lapseNotes ?? ""
        hasCravings = entry.cravingToday > 0
        cravingIntensity = Double(entry.cravingToday)
        if cravingIntensity < 1 { cravingIntensity = 5 }
    }

    // MARK: - Save Logic

    private func saveCheckIn() {
        HapticManager.pledge()

        let entry: CDDailyLogEntry
        if let existing = existingEntry {
            entry = existing
        } else {
            entry = CDDailyLogEntry(context: viewContext)
            entry.id = UUID()
            entry.date = DebugDate.startOfToday
            entry.createdAt = Date()
            entry.habit = habit
        }

        entry.entryType = "afternoon"
        entry.mood = Int16(selectedMood)
        entry.didReflect = true
        entry.lapsedToday = didLapse
        entry.lapseNotes = didLapse ? (lapseNotes.isEmpty ? nil : lapseNotes) : nil
        entry.cravingToday = hasCravings ? Int16(cravingIntensity) : 0

        // Lapse resets the recovery timer
        if didLapse {
            habit.resetOnLapse()
        }

        do {
            try viewContext.save()
        } catch {
            print("QuickCheckInView: Failed to save \u{2014} \(error.localizedDescription)")
        }

        // Surges awarded only when all 3 daily loops complete (handled in HomeView)

        existingEntry = entry
        isUpdate = true

        // Evaluate badges immediately
        environment.achievementService.evaluate(for: habit)

        // Check if all 3 daily loop tasks are now done
        checkDailyLoopCompletion()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSuccess = true
        }
    }

    private func checkDailyLoopCompletion() {
        let today = DebugDate.startOfToday as NSDate
        let types = ["morning", "afternoon", "evening"]
        var completedCount = 0
        for entryType in types {
            let req = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "habit == %@", habit),
                NSPredicate(format: "date == %@", today),
                NSPredicate(format: "entryType == %@", entryType)
            ])
            if ((try? viewContext.count(for: req)) ?? 0) > 0 { completedCount += 1 }
        }
        if completedCount >= 3 {
            CelebrationManager.shared.trigger(.rainbowBurst)
        }
    }
}

// MARK: - Preview

struct QuickCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        let habit = CDHabit.create(
            in: env.viewContext,
            name: "Quit Smoking",
            programType: ProgramType.smoking.rawValue
        )
        QuickCheckInView(habit: habit)
            .environmentObject(env)
            .preferredColorScheme(.dark)
    }
}
