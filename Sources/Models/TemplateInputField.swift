import Foundation

struct TemplateInputField: Codable, Identifiable {
    let id: String
    let label: String
    let placeholder: String
    let isMultiline: Bool
    let maxLength: Int
}
