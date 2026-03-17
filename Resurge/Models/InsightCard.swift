import Foundation

struct InsightCard: Identifiable, Equatable {
    let id: UUID
    let title: String
    let body: String
    let iconName: String
    let category: String
    let isPremium: Bool

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        iconName: String,
        category: String,
        isPremium: Bool = false
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.iconName = iconName
        self.category = category
        self.isPremium = isPremium
    }
}
