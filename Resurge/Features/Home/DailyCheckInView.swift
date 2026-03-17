import SwiftUI
import CoreData

struct DailyCheckInView: View {
    @ObservedObject var habit: CDHabit

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Scale State (0–10)

    @State private var mood: Double = 5
    @State private var stress: Double = 5
    @State private var energy: Double = 5
    @State private var sleepQuality: Double = 5
    @State private var loneliness: Double = 5
    @State private var cravingToday: Double = 5

    // MARK: - Text Fields

    @State private var wins: String = ""
    @State private var planForTomorrow: String = ""

    // MARK: - Pledge

    @State private var didPledge: Bool = false
    @State private var pledgeText: String = ""

    // MARK: - Lapse

    @State private var lapsedToday: Bool = false
    @State private var lapseNotes: String = ""

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    headerSection
                    feelingsSection
                    pledgeSection
                    lapseSection
                    winsSection
                    planSection
                    saveButton
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .onAppear(perform: loadExistingEntry)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Daily Check-In")
                    .font(Typography.largeTitle)
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

            HStack {
                Text(formattedDate)
                    .font(Typography.callout)
                    .foregroundColor(.textSecondary)
                Spacer()
            }
        }
        .padding(.top, 20)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }

    // MARK: - Feelings Section

    private var feelingsSection: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("How are you feeling?")
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            scaleCard(label: "Mood", value: $mood, lowEmoji: "\u{1F61E}", highEmoji: "\u{1F60A}", tint: .neonCyan)
            scaleCard(label: "Stress", value: $stress, lowEmoji: "\u{1F9D8}", highEmoji: "\u{1F630}", tint: .neonBlue)
            scaleCard(label: "Energy", value: $energy, lowEmoji: "\u{1F50B}", highEmoji: "\u{26A1}", tint: .neonPurple)
            scaleCard(label: "Sleep Quality", value: $sleepQuality, lowEmoji: "\u{1F634}", highEmoji: "\u{1F31F}", tint: .neonMagenta)
            scaleCard(label: "Loneliness", value: $loneliness, lowEmoji: "\u{1F465}", highEmoji: "\u{1F3DD}\u{FE0F}", tint: .neonOrange)
            scaleCard(label: "Craving Intensity", value: $cravingToday, lowEmoji: "\u{2705}", highEmoji: "\u{1F525}", tint: .neonGold)
        }
    }

    private func scaleCard(label: String, value: Binding<Double>, lowEmoji: String, highEmoji: String, tint: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(Typography.headline)
                    .foregroundColor(tint)
            }

            HStack(spacing: 8) {
                Text(lowEmoji)
                    .font(.title3)
                Slider(value: value, in: 0...10, step: 1)
                    .accentColor(tint)
                Text(highEmoji)
                    .font(.title3)
            }
        }
        .neonCard()
    }

    // MARK: - Pledge Section

    private var pledgeSection: some View {
        VStack(spacing: AppStyle.spacing) {
            HStack {
                Text("Today's Pledge")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                Toggle("", isOn: $didPledge)
                    .labelsHidden()
                    .tint(.neonPurple)
            }

            if didPledge {
                TextField("Write your pledge...", text: $pledgeText)
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
        .neonCard()
    }

    // MARK: - Lapse Section

    private var lapseSection: some View {
        VStack(spacing: AppStyle.spacing) {
            HStack {
                Text("Did you lapse today?")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                Toggle("", isOn: $lapsedToday)
                    .labelsHidden()
                    .tint(.neonOrange)
            }

            if lapsedToday {
                VStack(alignment: .leading, spacing: 4) {
                    Text("What happened?")
                        .font(Typography.caption)
                        .foregroundColor(.neonOrange)

                    TextEditor(text: $lapseNotes)
                        .font(Typography.body)
                        .foregroundColor(.textPrimary)
                        .frame(minHeight: 80)
                        .padding(4)
                        .background(Color.cardBackground)
                        .cornerRadius(AppStyle.smallCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                .stroke(Color.neonOrange.opacity(0.4), lineWidth: 1)
                        )
                }
            }
        }
        .neonCard(glow: lapsedToday ? .neonOrange : .neonCyan)
    }

    // MARK: - Wins Section

    private var winsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Wins Today")
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            TextEditor(text: $wins)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .frame(minHeight: 80)
                .padding(4)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
        .neonCard(glow: .neonGold)
    }

    // MARK: - Plan Section

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plan for Tomorrow")
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            TextEditor(text: $planForTomorrow)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .frame(minHeight: 80)
                .padding(4)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
        .neonCard()
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveEntry()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Check-In")
            }
        }
        .buttonStyle(RainbowButtonStyle())
    }

    // MARK: - Load Existing Entry

    private func loadExistingEntry() {
        guard let entry = fetchTodayEntry() else { return }
        mood = Double(entry.mood)
        stress = Double(entry.stress)
        energy = Double(entry.energy)
        sleepQuality = Double(entry.sleepQuality)
        loneliness = Double(entry.loneliness)
        cravingToday = Double(entry.cravingToday)
        wins = entry.wins ?? ""
        planForTomorrow = entry.planForTomorrow ?? ""
        didPledge = entry.didPledge
        pledgeText = entry.pledgeText ?? ""
        lapsedToday = entry.lapsedToday
        lapseNotes = entry.lapseNotes ?? ""
    }

    // MARK: - Save Logic

    private func saveEntry() {
        let entry = fetchTodayEntry() ?? createNewEntry()

        entry.mood = Int16(mood)
        entry.stress = Int16(stress)
        entry.energy = Int16(energy)
        entry.sleepQuality = Int16(sleepQuality)
        entry.loneliness = Int16(loneliness)
        entry.cravingToday = Int16(cravingToday)
        entry.wins = wins.isEmpty ? nil : wins
        entry.planForTomorrow = planForTomorrow.isEmpty ? nil : planForTomorrow
        entry.didPledge = didPledge
        entry.pledgeText = didPledge ? (pledgeText.isEmpty ? nil : pledgeText) : nil
        entry.lapsedToday = lapsedToday
        entry.lapseNotes = lapsedToday ? (lapseNotes.isEmpty ? nil : lapseNotes) : nil

        do {
            try viewContext.save()
        } catch {
            print("DailyCheckInView: Failed to save entry — \(error.localizedDescription)")
        }

        dismiss()
    }

    private func fetchTodayEntry() -> CDDailyLogEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        ])
        request.fetchLimit = 1

        return try? viewContext.fetch(request).first
    }

    private func createNewEntry() -> CDDailyLogEntry {
        let entry = CDDailyLogEntry(context: viewContext)
        entry.id = UUID()
        entry.date = Date()
        entry.createdAt = Date()
        entry.habit = habit
        return entry
    }
}

// MARK: - Preview

struct DailyCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Quit Smoking",
            programType: ProgramType.smoking.rawValue
        )
        DailyCheckInView(habit: habit)
            .environment(\.managedObjectContext, context)
            .preferredColorScheme(.dark)
    }
}
