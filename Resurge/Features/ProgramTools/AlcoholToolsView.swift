import SwiftUI
import Combine

// MARK: - Alcohol Tools View

struct AlcoholToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Plan Event").tag(0)
                    Text("Reflect").tag(1)
                    Text("Saved Plans").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: EventPlanBuilderCard()
                case 1: MorningReflectionCard()
                default: SavedPlansCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Alcohol Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Event Plan

private struct EventPlan: Identifiable {
    let id = UUID()
    var name: String
    var drinkAlternative: String
    var exitPlan: String
    var buddy: String
    let createdAt: Date
}

private class EventPlanStore: ObservableObject {
    @Published var plans: [EventPlan] = []

    func add(_ plan: EventPlan) {
        plans.insert(plan, at: 0)
    }

    func remove(at offsets: IndexSet) {
        plans.remove(atOffsets: offsets)
    }
}

private struct EventPlanBuilderCard: View {
    @StateObject private var store = EventPlanStore()
    @State private var eventName = ""
    @State private var drinkAlternative = ""
    @State private var exitPlan = ""
    @State private var buddyName = ""
    @State private var showSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Event Plan Builder", systemImage: "calendar.badge.plus")
                .font(.headline)
                .foregroundColor(Color.neonCyan)

            Text("Prepare before you go. Having a plan makes it easier to stick to your goals.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            VStack(spacing: 12) {
                InputField(title: "Event Name", placeholder: "e.g. Friday dinner", text: $eventName, icon: "calendar", iconColor: .neonCyan)
                InputField(title: "What will you drink instead?", placeholder: "e.g. Sparkling water with lime", text: $drinkAlternative, icon: "cup.and.saucer.fill", iconColor: .neonBlue)
                InputField(title: "Exit Plan", placeholder: "e.g. Leave by 10pm, drive myself", text: $exitPlan, icon: "door.left.hand.open", iconColor: .neonPurple)
                InputField(title: "Accountability Buddy", placeholder: "e.g. Sarah (will text if tempted)", text: $buddyName, icon: "person.2.fill", iconColor: .neonMagenta)
            }

            Button {
                guard !eventName.isEmpty else { return }
                let plan = EventPlan(
                    name: eventName,
                    drinkAlternative: drinkAlternative,
                    exitPlan: exitPlan,
                    buddy: buddyName,
                    createdAt: Date()
                )
                store.add(plan)
                eventName = ""
                drinkAlternative = ""
                exitPlan = ""
                buddyName = ""
                showSaved = true
            } label: {
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                    Text("Save Event Plan")
                        .font(Font.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Group {
                        if eventName.isEmpty {
                            LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                        } else {
                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .leading, endPoint: .trailing)
                        }
                    }
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(eventName.isEmpty)

            if showSaved && !store.plans.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Saved Plans (\(store.plans.count))")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.neonPurple)

                    ForEach(store.plans.prefix(3)) { plan in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.neonCyan)
                            Text(plan.name)
                                .font(.subheadline)
                            Spacer()
                            Text(plan.createdAt, style: .date)
                                .font(.caption2)
                                .foregroundColor(Color.subtleText)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Input Field Helper

private struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String
    var iconColor: Color = .neonCyan

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font.caption.weight(.medium))
                .foregroundColor(Color.subtleText)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                TextField(placeholder, text: $text)
                    .font(.subheadline)
            }
            .padding(12)
            .background(Color.appBackground)
            .cornerRadius(10)
        }
    }
}

// MARK: - Morning Reflection

private struct MorningReflectionCard: View {
    @State private var proudMoment = ""
    @State private var challenge = ""
    @State private var overallRating: Int = 3
    @State private var submitted = false

    private let ratingLabels = ["Rough", "Hard", "Okay", "Good", "Great"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Morning-After Reflection", systemImage: "sunrise.fill")
                .font(.headline)
                .foregroundColor(Color.neonOrange)

            if submitted {
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.neonMagenta)
                    Text("Reflection saved. Be proud of your awareness.")
                        .font(.subheadline)
                        .foregroundColor(Color.subtleText)
                        .multilineTextAlignment(.center)

                    Button("Write Another") {
                        submitted = false
                        proudMoment = ""
                        challenge = ""
                        overallRating = 3
                    }
                    .font(.subheadline)
                    .foregroundColor(Color.neonCyan)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                Text("How did last night go?")
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Rating")
                        .font(Font.caption.weight(.medium))
                        .foregroundColor(Color.subtleText)

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { value in
                            Button {
                                withAnimation { overallRating = value }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: value <= overallRating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(value <= overallRating ? Color.neonGold : Color.gray.opacity(0.3))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        Text(ratingLabels[overallRating - 1])
                            .font(Font.caption.weight(.medium))
                            .foregroundColor(Color.neonOrange)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Proud Moment")
                        .font(Font.caption.weight(.medium))
                        .foregroundColor(Color.subtleText)
                    TextEditor(text: $proudMoment)
                        .frame(height: 70)
                        .padding(8)
                        .background(Color.appBackground)
                        .cornerRadius(10)
                        .font(.subheadline)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Challenge Faced")
                        .font(Font.caption.weight(.medium))
                        .foregroundColor(Color.subtleText)
                    TextEditor(text: $challenge)
                        .frame(height: 70)
                        .padding(8)
                        .background(Color.appBackground)
                        .cornerRadius(10)
                        .font(.subheadline)
                }

                Button {
                    withAnimation { submitted = true }
                } label: {
                    Text("Save Reflection")
                        .font(Font.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(LinearGradient(colors: [.neonOrange, .neonMagenta, .neonPurple], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Saved Plans

private struct SavedPlansCard: View {
    @State private var samplePlans: [EventPlan] = [
        EventPlan(name: "Jake's Birthday", drinkAlternative: "Club soda with lime", exitPlan: "Uber home by 11pm", buddy: "Mike", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()),
        EventPlan(name: "Work Happy Hour", drinkAlternative: "Ginger beer", exitPlan: "Stay 1 hour max", buddy: "Sarah", createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()),
        EventPlan(name: "Wedding Reception", drinkAlternative: "Mocktail", exitPlan: "Drive myself, leave after cake", buddy: "Partner", createdAt: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Saved Event Plans", systemImage: "list.bullet.rectangle.portrait.fill")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            if samplePlans.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title)
                        .foregroundColor(Color.subtleText)
                    Text("No saved plans yet. Create one in the Plan Event tab.")
                        .font(.subheadline)
                        .foregroundColor(Color.subtleText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(samplePlans) { plan in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(plan.name)
                                .font(Font.subheadline.weight(.semibold))
                            Spacer()
                            Text(plan.createdAt, style: .date)
                                .font(.caption2)
                                .foregroundColor(Color.subtleText)
                        }

                        Group {
                            HStack(spacing: 6) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .frame(width: 16)
                                Text(plan.drinkAlternative)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "door.left.hand.open")
                                    .frame(width: 16)
                                Text(plan.exitPlan)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                    .frame(width: 16)
                                Text(plan.buddy)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Preview

struct AlcoholToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlcoholToolsView()
        }
    }
}
