import Foundation

struct CoachingTask: Codable, Identifiable, Equatable {
    let id: UUID
    let dayNumber: Int
    let title: String
    let description: String
    var isCompleted: Bool
    let category: String

    init(
        id: UUID = UUID(),
        dayNumber: Int,
        title: String,
        description: String,
        isCompleted: Bool = false,
        category: String
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.category = category
    }
}
