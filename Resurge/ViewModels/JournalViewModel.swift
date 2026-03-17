import SwiftUI
import CoreData

final class JournalViewModel: ObservableObject {
    @Published var showEditor = false
    @Published var editingEntry: CDJournalEntry?
    @Published var filterMode: FilterMode = .all

    enum FilterMode: String, CaseIterable, Identifiable {
        case all = "All"
        case reflections = "Reflections"
        var id: String { rawValue }
    }

    private let journalRepository: JournalRepositoryProtocol

    init(journalRepository: JournalRepositoryProtocol) {
        self.journalRepository = journalRepository
    }

    func createEntry(habit: CDHabit?, title: String, body: String, mood: Int, isReflection: Bool, prompt: String?) {
        guard let habit = habit else { return }
        _ = journalRepository.create(
            habit: habit,
            title: title,
            body: body,
            mood: mood,
            isReflection: isReflection,
            prompt: prompt
        )
    }

    func deleteEntry(_ entry: CDJournalEntry) {
        journalRepository.delete(entry)
    }
}
