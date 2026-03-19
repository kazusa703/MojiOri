import Foundation
import SwiftData

@Model
final class ArtworkHistory {
    var id: UUID
    var templateType: String
    var inputTexts: [String: String]
    var thumbnailData: Data?
    var createdAt: Date
    var isFavorite: Bool

    init(templateType: TemplateType, inputTexts: [String: String]) {
        self.id = UUID()
        self.templateType = templateType.rawValue
        self.inputTexts = inputTexts
        self.thumbnailData = nil
        self.createdAt = Date()
        self.isFavorite = false
    }

    var template: TemplateType? {
        TemplateType(rawValue: templateType)
    }
}
