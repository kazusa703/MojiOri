import Foundation
import UIKit

enum TemplateType: String, Codable, CaseIterable, Identifiable {
    case typoArtClassic
    case typoArtNeon
    case logoPatternSphere
    case waveText
    case retroHalftone
    case gradientStack

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .typoArtClassic: String(localized: "Typo Art — Classic")
        case .typoArtNeon: String(localized: "Typo Art — Neon")
        case .logoPatternSphere: String(localized: "Logo Pattern — Sphere")
        case .waveText: String(localized: "Wave Text")
        case .retroHalftone: String(localized: "Retro Halftone")
        case .gradientStack: String(localized: "Gradient Stack")
        }
    }

    var inputFields: [TemplateInputField] {
        switch self {
        case .typoArtClassic:
            [
                TemplateInputField(
                    id: "backgroundText",
                    label: String(localized: "Background Text"),
                    placeholder: "the Digital Typo as Art",
                    isMultiline: false,
                    maxLength: 100
                ),
                TemplateInputField(
                    id: "titleText",
                    label: String(localized: "Title"),
                    placeholder: "the\nDigital\nTypo\nas\nArt",
                    isMultiline: true,
                    maxLength: 200
                ),
            ]
        case .typoArtNeon:
            [
                TemplateInputField(
                    id: "backgroundText",
                    label: String(localized: "Background Text"),
                    placeholder: "TypeArt TypoArt",
                    isMultiline: false,
                    maxLength: 100
                ),
                TemplateInputField(
                    id: "titleText",
                    label: String(localized: "Title"),
                    placeholder: "type",
                    isMultiline: true,
                    maxLength: 200
                ),
            ]
        case .logoPatternSphere:
            [
                TemplateInputField(
                    id: "patternText",
                    label: String(localized: "Pattern Text"),
                    placeholder: "pattern logo",
                    isMultiline: false,
                    maxLength: 80
                ),
                TemplateInputField(
                    id: "titleText",
                    label: String(localized: "Title"),
                    placeholder: "pattern\nlogo",
                    isMultiline: true,
                    maxLength: 200
                ),
            ]
        case .waveText:
            [
                TemplateInputField(
                    id: "titleText",
                    label: String(localized: "Text"),
                    placeholder: "WAVE",
                    isMultiline: false,
                    maxLength: 30
                ),
            ]
        case .retroHalftone:
            [
                TemplateInputField(
                    id: "titleText",
                    label: String(localized: "Text"),
                    placeholder: "RETRO",
                    isMultiline: false,
                    maxLength: 20
                ),
            ]
        case .gradientStack:
            [
                TemplateInputField(
                    id: "titleText",
                    label: String(localized: "Text"),
                    placeholder: "STACK",
                    isMultiline: false,
                    maxLength: 20
                ),
            ]
        }
    }

    var defaultParameters: TemplateParameters {
        switch self {
        case .typoArtClassic:
            TemplateParameters(
                backgroundColor: UIColor.black,
                textureTextColor: UIColor(red: 0.478, green: 0.086, blue: 0.086, alpha: 1),
                titleTextColor: UIColor.white,
                textureFont: UIFont(name: "HelveticaNeue-CondensedBold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black),
                shadowOpacity: 1.0,
                shadowSpread: 20,
                shadowSize: 30,
                textureOpacity: 0.8,
                blendMode: .plusLighter
            )
        case .typoArtNeon:
            TemplateParameters(
                backgroundColor: UIColor.black,
                textureTextColor: UIColor(red: 0.784, green: 0.6, blue: 0.051, alpha: 1),
                titleTextColor: UIColor.white,
                textureFont: UIFont(name: "HelveticaNeue-CondensedBold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black),
                shadowOpacity: 1.0,
                shadowSpread: 20,
                shadowSize: 30,
                textureOpacity: 0.8,
                blendMode: .colorDodge
            )
        case .logoPatternSphere:
            TemplateParameters(
                backgroundColor: UIColor.black,
                textureTextColor: UIColor(white: 0.773, alpha: 1),
                titleTextColor: UIColor.white,
                textureFont: UIFont(name: "TimesNewRomanPSMT", size: 61) ?? .systemFont(ofSize: 61),
                titleFont: UIFont(name: "TimesNewRomanPSMT", size: 30) ?? .systemFont(ofSize: 30),
                shadowOpacity: 0,
                shadowSpread: 0,
                shadowSize: 0,
                textureOpacity: 1.0,
                blendMode: .multiply,
                spherizeAmount: 0.35,
                hueShift: 190,
                saturation: 70,
                gradientOpacity: 0.8
            )
        case .waveText:
            TemplateParameters(
                backgroundColor: UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1),
                textureTextColor: .white,
                titleTextColor: .white,
                textureFont: .systemFont(ofSize: 16),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 80) ?? .systemFont(ofSize: 80, weight: .black),
                shadowOpacity: 0, shadowSpread: 0, shadowSize: 0,
                textureOpacity: 1.0, blendMode: .normal
            )
        case .retroHalftone:
            TemplateParameters(
                backgroundColor: UIColor(red: 0.95, green: 0.92, blue: 0.85, alpha: 1),
                textureTextColor: UIColor(red: 0.85, green: 0.2, blue: 0.15, alpha: 1),
                titleTextColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1),
                textureFont: .systemFont(ofSize: 16),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black),
                shadowOpacity: 0, shadowSpread: 0, shadowSize: 0,
                textureOpacity: 1.0, blendMode: .multiply
            )
        case .gradientStack:
            TemplateParameters(
                backgroundColor: UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1),
                textureTextColor: .white,
                titleTextColor: .white,
                textureFont: .systemFont(ofSize: 16),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black),
                shadowOpacity: 0, shadowSpread: 0, shadowSize: 0,
                textureOpacity: 1.0, blendMode: .normal
            )
        }
    }
}

struct TemplateParameters {
    var backgroundColor: UIColor
    var textureTextColor: UIColor
    var titleTextColor: UIColor
    var textureFont: UIFont
    var titleFont: UIFont
    var shadowOpacity: CGFloat
    var shadowSpread: CGFloat
    var shadowSize: CGFloat
    var textureOpacity: CGFloat
    var blendMode: CGBlendMode
    var spherizeAmount: CGFloat = 0
    var hueShift: CGFloat = 0
    var saturation: CGFloat = 0
    var gradientOpacity: CGFloat = 0
}
