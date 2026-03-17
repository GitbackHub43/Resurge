import Foundation

struct LibraryItem: Identifiable, Codable, Equatable {

    enum ContentType: String, Codable, CaseIterable, Identifiable {
        case article
        case video
        case meditation

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .article:    return "Article"
            case .video:      return "Video"
            case .meditation: return "Meditation"
            }
        }

        var iconName: String {
            switch self {
            case .article:    return "doc.text.fill"
            case .video:      return "play.rectangle.fill"
            case .meditation: return "leaf.fill"
            }
        }
    }

    let id: String
    let title: String
    let summary: String
    let category: String
    let contentType: ContentType
    let body: String
    let videoURL: String?
    let isPremium: Bool
    let programTypes: [ProgramType]

    init(
        id: String,
        title: String,
        summary: String,
        category: String,
        contentType: ContentType,
        body: String,
        videoURL: String? = nil,
        isPremium: Bool = false,
        programTypes: [ProgramType] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.contentType = contentType
        self.body = body
        self.videoURL = videoURL
        self.isPremium = isPremium
        self.programTypes = programTypes
    }
}
