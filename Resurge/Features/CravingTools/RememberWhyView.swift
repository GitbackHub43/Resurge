import SwiftUI
import CoreData

// MARK: - WhyNote Model

private struct WhyNote: Identifiable, Codable {
    let id: UUID
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

// MARK: - RememberWhyView

struct RememberWhyView: View {
    var habitId: UUID?
    var habitName: String?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.createdAt, ascending: false)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var activeHabits: FetchedResults<CDHabit>

    @State private var notes: [WhyNote] = []
    @State private var newNoteText: String = ""
    @State private var showAddNote: Bool = false

    private var storageKey: String {
        if let id = habitId {
            return "remember_why_notes_\(id.uuidString)"
        } else if let firstHabit = activeHabits.first {
            return "remember_why_notes_\(firstHabit.id.uuidString)"
        }
        return "remember_why_notes_global"
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppStyle.largeSpacing) {
                        // MARK: - Header
                        headerSection

                        // MARK: - Add Button
                        Button(action: { showAddNote = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add a Reason")
                            }
                        }
                        .buttonStyle(RainbowButtonStyle())
                        .padding(.horizontal, AppStyle.screenPadding)

                        // MARK: - Notes List
                        if notes.isEmpty {
                            emptyState
                        } else {
                            notesList
                        }
                    }
                    .padding(.vertical, AppStyle.spacing)
                }
            }
            .navigationTitle("Remember Why")
            .onAppear { loadNotes() }
            .sheet(isPresented: $showAddNote) {
                addNoteSheet
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppStyle.spacing) {
            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundColor(.neonMagenta)

            if let name = habitName {
                Text("Your Reasons for Quitting \(name)")
                    .font(Typography.headline)
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppStyle.screenPadding)
            }

            Text("When the urge hits, remember why you started.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)
        }
        .padding(.top, AppStyle.spacing)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppStyle.spacing) {
            Image(systemName: "text.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.subtleText.opacity(0.4))

            Text("Tap + to add your first reason to stay strong.")
                .font(Typography.callout)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Notes List

    private var notesList: some View {
        LazyVStack(spacing: AppStyle.spacing) {
            ForEach(notes) { note in
                noteCard(note: note)
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Note Card

    @ViewBuilder
    private func noteCard(note: WhyNote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.text)
                .font(Typography.body)
                .foregroundColor(.appText)

            Text(dateFormatter.string(from: note.createdAt))
                .font(Typography.caption)
                .foregroundColor(.subtleText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .contextMenu {
            Button(role: .destructive) {
                deleteNote(note)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Add Note Sheet

    private var addNoteSheet: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: AppStyle.largeSpacing) {
                    Text("Why did you start this journey?")
                        .font(Typography.headline)
                        .foregroundColor(.appText)
                        .padding(.top, AppStyle.largeSpacing)

                    TextEditor(text: $newNoteText)
                        .font(Typography.body)
                        .foregroundColor(.appText)
                        .frame(minHeight: 120)
                        .padding(AppStyle.spacing)
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
                        .padding(.horizontal, AppStyle.screenPadding)

                    Button(action: saveNewNote) {
                        HStack {
                            Text("Save Reason")
                        }
                    }
                    .buttonStyle(RainbowButtonStyle())
                    .opacity(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, AppStyle.screenPadding)

                    Spacer()
                }
            }
            .navigationTitle("Add a Reason")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newNoteText = ""
                        showAddNote = false
                    }
                    .foregroundColor(.neonCyan)
                }
            }
        }
    }

    // MARK: - Persistence

    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            notes = try JSONDecoder().decode([WhyNote].self, from: data)
        } catch {
            notes = []
        }
    }

    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Silently fail — notes remain in memory
        }
    }

    private func saveNewNote() {
        let trimmed = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let note = WhyNote(text: trimmed)
        notes.insert(note, at: 0)
        saveNotes()

        newNoteText = ""
        showAddNote = false
    }

    private func deleteNote(_ note: WhyNote) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
}

// MARK: - Preview

struct RememberWhyView_Previews: PreviewProvider {
    static var previews: some View {
        RememberWhyView(habitId: nil, habitName: nil)
            .preferredColorScheme(.dark)
    }
}
