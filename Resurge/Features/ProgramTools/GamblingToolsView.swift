import SwiftUI
import Combine

// MARK: - Gambling Tools View

struct GamblingToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Reality Check").tag(0)
                    Text("Emergency").tag(1)
                    Text("Self-Exclusion").tag(2)
                    Text("Delay Timer").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: RealityCheckCard()
                case 1: GamblingEmergencyContactCard()
                case 2: SelfExclusionCard()
                default: GamblingUrgeDelayTimerCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Gambling Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Reality Check Card

private struct LossEntry: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
    let date: Date
}

private struct RealityCheckCard: View {
    @State private var totalLosses: String = ""
    @State private var entries: [LossEntry] = [
        LossEntry(label: "Online slots", amount: 150.00, date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()),
        LossEntry(label: "Sports bet", amount: 75.00, date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()),
        LossEntry(label: "Casino visit", amount: 300.00, date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()),
    ]
    @State private var newLabel = ""
    @State private var newAmount = ""
    @State private var showFacts = false

    private var runningTotal: Double {
        entries.reduce(0) { $0 + $1.amount }
    }

    private let facts: [(icon: String, text: String)] = [
        ("chart.bar.fill", "The house edge means the casino always profits over time. Slot machines return only 85-95% of money put in."),
        ("percent", "The odds of hitting a jackpot on a slot machine are roughly 1 in 50,000,000."),
        ("brain.head.profile", "Problem gambling activates the same brain pathways as substance addiction."),
        ("dollarsign.circle.fill", "The average problem gambler accumulates $40,000-$70,000 in debt before seeking help."),
        ("clock.fill", "For every hour spent gambling, the average person loses $80-$120."),
        ("arrow.triangle.2.circlepath", "\"Chasing losses\" is the most common pattern - it never works mathematically."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Reality Check Card", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundColor(Color.neonOrange)

            Text("Face the numbers honestly. Track every loss to see the real cost.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Running total
            VStack(spacing: 4) {
                Text("Total Tracked Losses")
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                Text(String(format: "$%.2f", runningTotal))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color.neonOrange)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.neonOrange.opacity(0.08))
            .cornerRadius(12)

            // Log a loss
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "pencil.line")
                        .foregroundColor(Color.neonOrange)
                    TextField("What did you gamble on?", text: $newLabel)
                        .font(.subheadline)
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)

                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(Color.neonGold)
                    TextField("Amount lost", text: $newAmount)
                        .font(.subheadline)
                        .keyboardType(.decimalPad)
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)

                Button {
                    guard !newLabel.isEmpty, let amount = Double(newAmount) else { return }
                    let entry = LossEntry(label: newLabel, amount: amount, date: Date())
                    withAnimation {
                        entries.insert(entry, at: 0)
                        newLabel = ""
                        newAmount = ""
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Loss")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(newLabel.isEmpty ? Color.gray.opacity(0.3) : Color.neonOrange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(newLabel.isEmpty)
            }

            // Loss history
            if !entries.isEmpty {
                ForEach(entries) { entry in
                    HStack {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(Color.neonOrange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.label)
                                .font(Font.subheadline.weight(.medium))
                            Text(entry.date, style: .date)
                                .font(.caption2)
                                .foregroundColor(Color.subtleText)
                        }
                        Spacer()
                        Text(String(format: "-$%.2f", entry.amount))
                            .font(Font.subheadline.weight(.bold))
                            .foregroundColor(Color.neonOrange)
                    }
                    .padding(10)
                    .background(Color.appBackground)
                    .cornerRadius(10)
                }
            }

            // Facts toggle
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showFacts.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "info.circle.fill")
                    Text("The House Always Wins")
                        .font(Font.body.weight(.semibold))
                    Spacer()
                    Image(systemName: showFacts ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(Color.neonOrange)
                .padding()
                .background(Color.neonOrange.opacity(0.08))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

            if showFacts {
                ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: fact.icon)
                            .foregroundColor(Color.neonOrange)
                            .frame(width: 24)
                            .padding(.top, 2)
                        Text(fact.text)
                            .font(.caption)
                            .foregroundColor(Color.appText)
                            .lineSpacing(2)
                    }
                    .padding(.vertical, 4)
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

// MARK: - Emergency Contact Plan

private struct GamblingEmergencyContact: Identifiable {
    let id = UUID()
    var name: String
    var phone: String
    var relationship: String
}

private struct GamblingEmergencyContactCard: View {
    @State private var contacts: [GamblingEmergencyContact] = [
        GamblingEmergencyContact(name: "Sponsor - Mike", phone: "555-0123", relationship: "GA Sponsor"),
        GamblingEmergencyContact(name: "Partner", phone: "555-0456", relationship: "Family"),
    ]
    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelationship = ""
    @State private var showForm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Emergency Contact Plan", systemImage: "phone.circle.fill")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            Text("When the urge hits, call someone immediately. Pre-set your contacts so it takes one tap.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Contacts list
            ForEach(contacts) { contact in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.neonCyan.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "person.fill")
                            .foregroundColor(Color.neonCyan)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(Font.subheadline.weight(.medium))
                        Text(contact.relationship)
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    }

                    Spacer()

                    Button {
                        // In a real app, this would open the phone dialer
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                            Text("Call")
                                .font(Font.body.weight(.semibold))
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.neonCyan)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.appBackground)
                .cornerRadius(12)
            }

            // Add contact form
            Button {
                withAnimation { showForm.toggle() }
            } label: {
                HStack {
                    Image(systemName: showForm ? "chevron.up" : "person.badge.plus")
                    Text(showForm ? "Hide Form" : "Add Emergency Contact")
                        .font(Font.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.neonCyan.opacity(0.15))
                .foregroundColor(Color.neonCyan)
                .cornerRadius(12)
            }

            if showForm {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(Color.neonCyan)
                        TextField("Name", text: $newName)
                            .font(.subheadline)
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)

                    HStack {
                        Image(systemName: "phone")
                            .foregroundColor(Color.neonCyan)
                        TextField("Phone number", text: $newPhone)
                            .font(.subheadline)
                            .keyboardType(.phonePad)
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)

                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(Color.neonCyan)
                        TextField("Relationship (e.g. Sponsor)", text: $newRelationship)
                            .font(.subheadline)
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)

                    Button {
                        guard !newName.isEmpty, !newPhone.isEmpty else { return }
                        let contact = GamblingEmergencyContact(name: newName, phone: newPhone, relationship: newRelationship.isEmpty ? "Contact" : newRelationship)
                        withAnimation {
                            contacts.append(contact)
                            newName = ""
                            newPhone = ""
                            newRelationship = ""
                            showForm = false
                        }
                    } label: {
                        Text("Save Contact")
                            .font(Font.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(newName.isEmpty ? Color.gray.opacity(0.3) : Color.neonCyan)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(newName.isEmpty)
                }
            }

            // Helpline
            VStack(spacing: 8) {
                Divider()
                HStack {
                    Image(systemName: "phone.arrow.up.right.fill")
                        .foregroundColor(Color.neonOrange)
                    VStack(alignment: .leading) {
                        Text("National Problem Gambling Helpline")
                            .font(Font.caption.weight(.semibold))
                        Text("1-800-522-4700 (24/7, free, confidential)")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
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

// MARK: - Self-Exclusion Reminder

private struct ResourceItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
}

private struct SelfExclusionCard: View {
    private let resources: [ResourceItem] = [
        ResourceItem(name: "Casino Self-Exclusion", description: "Contact your state gaming commission to ban yourself from all casinos.", icon: "building.columns.fill"),
        ResourceItem(name: "Online Gambling Blocking", description: "Install Gamban or BetBlocker to block all gambling sites and apps.", icon: "lock.shield.fill"),
        ResourceItem(name: "Gamblers Anonymous", description: "Find a local GA meeting. No membership fees, just people who understand.", icon: "person.3.fill"),
        ResourceItem(name: "Financial Counseling", description: "National Foundation for Credit Counseling offers free debt advice.", icon: "dollarsign.circle.fill"),
        ResourceItem(name: "Therapy (CBT)", description: "Cognitive Behavioral Therapy is the most effective treatment for gambling addiction.", icon: "brain.head.profile"),
        ResourceItem(name: "Voluntary Account Closure", description: "Close all online betting accounts. Most sites have a responsible gambling section.", icon: "xmark.circle.fill"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Self-Exclusion Resources", systemImage: "shield.fill")
                .font(.headline)
                .foregroundColor(Color.neonPurple)

            Text("Taking action to limit access is one of the most powerful things you can do.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            let rainbowColors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]
            ForEach(Array(resources.enumerated()), id: \.element.id) { index, resource in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(rainbowColors[index % rainbowColors.count].opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: resource.icon)
                            .foregroundColor(rainbowColors[index % rainbowColors.count])
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(resource.name)
                            .font(Font.subheadline.weight(.semibold))
                        Text(resource.description)
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                            .lineSpacing(2)
                    }
                }
                .padding()
                .background(Color.appBackground)
                .cornerRadius(12)
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

// MARK: - Gambling Urge Delay Timer

private struct GamblingUrgeDelayTimerCard: View {
    @State private var timerRunning = false
    @State private var secondsRemaining: Int = 15 * 60 // 15 minutes
    @State private var selectedMinutes: Int = 15
    @State private var timerCancellable: AnyCancellable?
    @State private var urgesDelayed: Int = 3
    @State private var urgesResisted: Int = 2

    private let delayOptions = [5, 10, 15, 20, 30]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Gambling Urge Delay Timer", systemImage: "timer")
                .font(.headline)
                .foregroundColor(Color.neonMagenta)

            Text("When you feel the urge, commit to waiting. Most urges pass within 15-20 minutes.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Timer display
            VStack(spacing: 12) {
                Text(formatTimer(secondsRemaining))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(timerRunning ? Color.neonOrange : Color.appText)
                    .frame(maxWidth: .infinity)

                if timerRunning {
                    Text("Stay strong. The urge will pass.")
                        .font(Font.subheadline.weight(.medium))
                        .foregroundColor(Color.neonCyan)

                    // Coping prompts during timer
                    VStack(alignment: .leading, spacing: 8) {
                        promptRow(icon: "figure.walk", text: "Go for a walk or change your environment")
                        promptRow(icon: "phone.fill", text: "Call someone from your emergency contacts")
                        promptRow(icon: "drop.fill", text: "Drink a glass of water slowly")
                        promptRow(icon: "lungs.fill", text: "Try 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s")
                    }
                    .padding()
                    .background(Color.neonCyan.opacity(0.06))
                    .cornerRadius(12)
                }

                if !timerRunning {
                    // Duration picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Delay duration")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                        HStack(spacing: 8) {
                            ForEach(delayOptions, id: \.self) { minutes in
                                Button {
                                    selectedMinutes = minutes
                                    secondsRemaining = minutes * 60
                                } label: {
                                    Text("\(minutes)m")
                                        .font(Font.subheadline.weight(selectedMinutes == minutes ? .bold : .regular))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedMinutes == minutes ? Color.neonOrange : Color.appBackground)
                                        .foregroundColor(selectedMinutes == minutes ? .white : Color.appText)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                // Start / Stop button
                Button {
                    if timerRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                } label: {
                    HStack {
                        Image(systemName: timerRunning ? "stop.fill" : "play.fill")
                        Text(timerRunning ? "I Gave In" : "Start Delay Timer")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(timerRunning ? Color.gray.opacity(0.4) : Color.neonOrange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                if timerRunning {
                    Button {
                        withAnimation {
                            urgesResisted += 1
                            stopTimer()
                            secondsRemaining = selectedMinutes * 60
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                            Text("Urge Passed - I Resisted!")
                                .font(Font.body.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonCyan)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)

            // Stats
            HStack {
                VStack {
                    Text("\(urgesDelayed)")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Color.neonOrange)
                    Text("Urges Delayed")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 40)

                VStack {
                    Text("\(urgesResisted)")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Color.neonCyan)
                    Text("Urges Resisted")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)
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

    @ViewBuilder
    private func promptRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Color.neonCyan)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(Color.appText)
        }
    }

    private func formatTimer(_ totalSeconds: Int) -> String {
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func startTimer() {
        timerRunning = true
        urgesDelayed += 1
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else {
                    stopTimer()
                    urgesResisted += 1
                }
            }
    }

    private func stopTimer() {
        timerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}

// MARK: - Preview

struct GamblingToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GamblingToolsView()
        }
    }
}
