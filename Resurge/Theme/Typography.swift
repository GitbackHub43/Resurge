import SwiftUI

enum Typography {
    static let largeTitle: Font = .largeTitle.weight(.bold)
    static let title: Font = .title2.weight(.semibold)
    static let headline: Font = .headline.weight(.semibold)
    static let body: Font = .body
    static let callout: Font = .callout
    static let caption: Font = .caption
    static let footnote: Font = .footnote

    static let counter: Font = .system(size: 64, weight: .bold, design: .rounded)
    static let counterLarge: Font = .system(size: 80, weight: .bold, design: .rounded)
    static let statValue: Font = .system(size: 36, weight: .bold, design: .rounded)
    static let statLabel: Font = .caption.weight(.medium)
    static let badge: Font = .system(size: 12, weight: .semibold, design: .rounded)
    static let timer: Font = .system(size: 64, weight: .light, design: .monospaced)
}
