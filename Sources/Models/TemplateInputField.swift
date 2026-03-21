import Foundation
import UIKit

// MARK: - Input field types

enum InputFieldType: Codable {
    case text(multiline: Bool, maxLength: Int, placeholder: String)
    case color(palette: [ColorPreset])
    case font
}

struct ColorPreset: Codable, Identifiable {
    let id: String
    let label: String
    let hex: String

    var uiColor: UIColor {
        UIColor(hex: hex)
    }
}

struct TemplateInputField: Identifiable {
    let id: String
    let label: String
    let fieldType: InputFieldType
}

// MARK: - Type-safe input values

enum TemplateValue {
    case string(String)
    case color(UIColor)
    case font(UIFont)
}

struct TemplateInputs {
    private var values: [String: TemplateValue] = [:]

    func string(for key: String) -> String {
        if case .string(let v) = values[key] { return v }
        return ""
    }

    func color(for key: String, default defaultColor: UIColor = .white) -> UIColor {
        if case .color(let v) = values[key] { return v }
        return defaultColor
    }

    func font(for key: String, default defaultFont: UIFont) -> UIFont {
        if case .font(let v) = values[key] { return v }
        return defaultFont
    }

    mutating func set(_ value: TemplateValue, for key: String) {
        values[key] = value
    }

    /// Convert to [String: String] for backward compatibility and history storage
    var textValues: [String: String] {
        var result: [String: String] = [:]
        for (key, value) in values {
            if case .string(let s) = value {
                result[key] = s
            }
        }
        return result
    }

    var hasInput: Bool {
        values.values.contains { value in
            if case .string(let s) = value { return !s.isEmpty }
            return false
        }
    }
}

// MARK: - UIColor hex extension

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: CGFloat
        switch hex.count {
        case 6:
            r = CGFloat((int >> 16) & 0xFF) / 255
            g = CGFloat((int >> 8) & 0xFF) / 255
            b = CGFloat(int & 0xFF) / 255
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
