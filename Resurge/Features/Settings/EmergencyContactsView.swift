import SwiftUI
import CoreData

// MARK: - Model

struct EmergencyContact: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var phoneNumber: String
}

// MARK: - View

struct EmergencyContactsView: View {
    @AppStorage("emergencyContacts") private var contactsData: String = "[]"
    @State private var contacts: [EmergencyContact] = []
    @State private var showingSaveConfirmation = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES")
    ) private var activeHabits: FetchedResults<CDHabit>

    private let maxContacts = 3

    private var habitHelplines: [(name: String, number: String, telURL: String, programIcon: String)] {
        var seen = Set<String>()
        var result: [(name: String, number: String, telURL: String, programIcon: String)] = []
        for habit in activeHabits {
            let program = ProgramType(rawValue: habit.programType) ?? .smoking
            for line in program.helplines {
                let key = line.number
                if !seen.contains(key) {
                    seen.insert(key)
                    let digits = line.number.filter { $0.isNumber }
                    result.append((
                        name: line.name,
                        number: line.number,
                        telURL: "tel:\(digits)",
                        programIcon: program.iconName
                    ))
                }
            }
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Emergency Contacts")
                        .font(Typography.title)
                        .rainbowText()
                    Text("Add up to 3 trusted people you can call when cravings hit hard.")
                        .font(Typography.body)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppStyle.screenPadding)

                // 988 Suicide & Crisis Lifeline (always shown)
                hotlineCard(
                    icon: "heart.circle.fill",
                    iconColor: .neonMagenta,
                    name: "988 Suicide & Crisis Lifeline",
                    number: "988",
                    telURL: "tel:988",
                    description: "Free, confidential, 24/7 support for people in distress."
                )
                .padding(.horizontal, AppStyle.screenPadding)

                // Per-habit helplines
                ForEach(Array(habitHelplines.enumerated()), id: \.offset) { _, line in
                    hotlineCard(
                        icon: line.programIcon,
                        iconColor: .neonGreen,
                        name: line.name,
                        number: line.number,
                        telURL: line.telURL,
                        description: "Support line based on your active habits."
                    )
                    .padding(.horizontal, AppStyle.screenPadding)
                }

                // Contact Cards
                ForEach(contacts.indices, id: \.self) { index in
                    contactCard(at: index)
                        .padding(.horizontal, AppStyle.screenPadding)
                }

                // Add Contact Button
                if contacts.count < maxContacts {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contacts.append(EmergencyContact(name: "", phoneNumber: ""))
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Contact")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle(color: .neonCyan))
                    .padding(.horizontal, AppStyle.screenPadding)
                }

                // Save Button
                Button {
                    saveContacts()
                    HapticManager.tap()
                    showingSaveConfirmation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingSaveConfirmation = false
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(showingSaveConfirmation ? "Saved!" : "Save Contacts")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(color: showingSaveConfirmation ? .neonGreen : .neonCyan))
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, 32)
            }
            .padding(.top, 16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            loadContacts()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Contact Card

    private func contactCard(at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Contact \(index + 1)")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        contacts.remove(at: index)
                        saveContacts()
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.neonOrange)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                TextField("Contact name", text: binding(for: index, keyPath: \.name))
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                TextField("Phone number", text: binding(for: index, keyPath: \.phoneNumber))
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .keyboardType(.phonePad)
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
            }
        }
        .neonCard(glow: .neonCyan)
    }

    // MARK: - Helpers

    private func binding(for index: Int, keyPath: WritableKeyPath<EmergencyContact, String>) -> Binding<String> {
        Binding(
            get: {
                guard index < contacts.count else { return "" }
                return contacts[index][keyPath: keyPath]
            },
            set: { newValue in
                guard index < contacts.count else { return }
                contacts[index][keyPath: keyPath] = newValue
            }
        )
    }

    private func loadContacts() {
        guard let data = contactsData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: data) else {
            return
        }
        contacts = decoded
    }

    private func saveContacts() {
        let validContacts = contacts.filter { !$0.name.isEmpty || !$0.phoneNumber.isEmpty }
        guard let data = try? JSONEncoder().encode(validContacts),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        contactsData = jsonString
    }

    private func hotlineCard(icon: String, iconColor: Color, name: String, number: String, telURL: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(name)
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
            }

            Text(description)
                .font(Typography.caption)
                .foregroundColor(.textSecondary)

            HStack {
                Text(number)
                    .font(Typography.body)
                    .foregroundColor(.textSecondary)
                Spacer()
                Button {
                    if let url = URL(string: telURL) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(Typography.caption.weight(.semibold))
                    .foregroundColor(.neonGreen)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.neonGreen.opacity(0.15))
                    .cornerRadius(AppStyle.smallCornerRadius)
                }
            }
        }
        .neonCard(glow: iconColor)
    }

}

// MARK: - Preview

struct EmergencyContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmergencyContactsView()
        }
        .preferredColorScheme(.dark)
    }
}
