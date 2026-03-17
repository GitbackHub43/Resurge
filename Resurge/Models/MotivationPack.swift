import Foundation

struct MotivationPack: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let productIdentifier: String
    let quotes: [String]
    var isPurchased: Bool

    init(
        id: String,
        name: String,
        description: String,
        productIdentifier: String,
        quotes: [String],
        isPurchased: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.productIdentifier = productIdentifier
        self.quotes = quotes
        self.isPurchased = isPurchased
    }
}
