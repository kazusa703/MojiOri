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

    // MARK: - Input fields with typed definitions

    var inputFields: [TemplateInputField] {
        switch self {
        case .typoArtClassic:
            [
                .init(id: "backgroundText", label: String(localized: "Background Text"),
                      fieldType: .text(multiline: false, maxLength: 100, placeholder: "the Digital Typo as Art")),
                .init(id: "titleText", label: String(localized: "Title"),
                      fieldType: .text(multiline: true, maxLength: 200, placeholder: "the\nDigital\nTypo\nas\nArt")),
                .init(id: "textureColor", label: String(localized: "Texture Color"),
                      fieldType: .color(palette: Self.redPalette)),
                .init(id: "titleColor", label: String(localized: "Title Color"),
                      fieldType: .color(palette: Self.whitePalette)),
                .init(id: "bgColor", label: String(localized: "Background Color"),
                      fieldType: .color(palette: Self.darkPalette)),
                .init(id: "titleFont", label: String(localized: "Title Font"), fieldType: .font),
            ]
        case .typoArtNeon:
            [
                .init(id: "backgroundText", label: String(localized: "Background Text"),
                      fieldType: .text(multiline: false, maxLength: 100, placeholder: "TypeArt TypoArt")),
                .init(id: "titleText", label: String(localized: "Title"),
                      fieldType: .text(multiline: true, maxLength: 200, placeholder: "type")),
                .init(id: "textureColor", label: String(localized: "Neon Color"),
                      fieldType: .color(palette: Self.neonPalette)),
                .init(id: "titleColor", label: String(localized: "Title Color"),
                      fieldType: .color(palette: Self.whitePalette)),
                .init(id: "bgColor", label: String(localized: "Background Color"),
                      fieldType: .color(palette: Self.darkPalette)),
                .init(id: "titleFont", label: String(localized: "Title Font"), fieldType: .font),
            ]
        case .logoPatternSphere:
            [
                .init(id: "patternText", label: String(localized: "Pattern Text"),
                      fieldType: .text(multiline: false, maxLength: 80, placeholder: "pattern logo")),
                .init(id: "titleText", label: String(localized: "Title"),
                      fieldType: .text(multiline: true, maxLength: 200, placeholder: "pattern\nlogo")),
                .init(id: "accentColor", label: String(localized: "Accent Color"),
                      fieldType: .color(palette: Self.spherePalette)),
                .init(id: "titleFont", label: String(localized: "Title Font"), fieldType: .font),
            ]
        case .waveText:
            [
                .init(id: "titleText", label: String(localized: "Text"),
                      fieldType: .text(multiline: false, maxLength: 30, placeholder: "WAVE")),
                .init(id: "bgColor", label: String(localized: "Background Color"),
                      fieldType: .color(palette: Self.darkPalette)),
                .init(id: "titleFont", label: String(localized: "Font"), fieldType: .font),
            ]
        case .retroHalftone:
            [
                .init(id: "titleText", label: String(localized: "Text"),
                      fieldType: .text(multiline: false, maxLength: 20, placeholder: "RETRO")),
                .init(id: "textureColor", label: String(localized: "Shadow Color"),
                      fieldType: .color(palette: Self.redPalette)),
                .init(id: "bgColor", label: String(localized: "Paper Color"),
                      fieldType: .color(palette: Self.paperPalette)),
                .init(id: "titleFont", label: String(localized: "Font"), fieldType: .font),
            ]
        case .gradientStack:
            [
                .init(id: "titleText", label: String(localized: "Text"),
                      fieldType: .text(multiline: false, maxLength: 20, placeholder: "STACK")),
                .init(id: "accentColor", label: String(localized: "Gradient Start"),
                      fieldType: .color(palette: Self.gradientPalette)),
                .init(id: "bgColor", label: String(localized: "Background Color"),
                      fieldType: .color(palette: Self.darkPalette)),
                .init(id: "titleFont", label: String(localized: "Font"), fieldType: .font),
            ]
        }
    }

    // MARK: - Color palettes

    static let redPalette: [ColorPreset] = [
        .init(id: "red1", label: "Crimson", hex: "#7A1616"),
        .init(id: "red2", label: "Scarlet", hex: "#CC2222"),
        .init(id: "red3", label: "Orange", hex: "#CC6600"),
        .init(id: "red4", label: "Purple", hex: "#661166"),
        .init(id: "red5", label: "Blue", hex: "#1A3366"),
    ]

    static let neonPalette: [ColorPreset] = [
        .init(id: "neon1", label: "Gold", hex: "#C8990D"),
        .init(id: "neon2", label: "Lime", hex: "#33CC33"),
        .init(id: "neon3", label: "Cyan", hex: "#00CCCC"),
        .init(id: "neon4", label: "Pink", hex: "#FF33AA"),
        .init(id: "neon5", label: "Electric", hex: "#3366FF"),
    ]

    static let whitePalette: [ColorPreset] = [
        .init(id: "w1", label: "White", hex: "#FFFFFF"),
        .init(id: "w2", label: "Cream", hex: "#FFF8E7"),
        .init(id: "w3", label: "Silver", hex: "#C0C0C0"),
        .init(id: "w4", label: "Gold", hex: "#FFD700"),
        .init(id: "w5", label: "Cyan", hex: "#00FFFF"),
    ]

    static let darkPalette: [ColorPreset] = [
        .init(id: "d1", label: "Black", hex: "#000000"),
        .init(id: "d2", label: "Navy", hex: "#0D0D2B"),
        .init(id: "d3", label: "Charcoal", hex: "#1A1A2E"),
        .init(id: "d4", label: "Wine", hex: "#2D0A0A"),
        .init(id: "d5", label: "Forest", hex: "#0A2D0A"),
    ]

    static let spherePalette: [ColorPreset] = [
        .init(id: "s1", label: "Teal", hex: "#008080"),
        .init(id: "s2", label: "Violet", hex: "#7B2D8E"),
        .init(id: "s3", label: "Gold", hex: "#B8860B"),
        .init(id: "s4", label: "Rose", hex: "#C04060"),
        .init(id: "s5", label: "Sky", hex: "#4682B4"),
    ]

    static let paperPalette: [ColorPreset] = [
        .init(id: "p1", label: "Cream", hex: "#F2EBD9"),
        .init(id: "p2", label: "White", hex: "#FAFAFA"),
        .init(id: "p3", label: "Kraft", hex: "#C4A35A"),
        .init(id: "p4", label: "Pink", hex: "#FFE0E0"),
        .init(id: "p5", label: "Mint", hex: "#E0FFE0"),
    ]

    static let gradientPalette: [ColorPreset] = [
        .init(id: "g1", label: "Blue", hex: "#1A33CC"),
        .init(id: "g2", label: "Purple", hex: "#8B00FF"),
        .init(id: "g3", label: "Red", hex: "#FF3333"),
        .init(id: "g4", label: "Teal", hex: "#00B3B3"),
        .init(id: "g5", label: "Gold", hex: "#CC9900"),
    ]

    // MARK: - Default parameters (legacy, used by renderers)

    var defaultParameters: TemplateParameters {
        switch self {
        case .typoArtClassic:
            TemplateParameters(
                backgroundColor: UIColor.black,
                textureTextColor: UIColor(hex: "7A1616"),
                titleTextColor: UIColor.white,
                textureFont: UIFont(name: "HelveticaNeue-CondensedBold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black),
                shadowOpacity: 1.0, shadowSpread: 20, shadowSize: 30,
                textureOpacity: 0.8, blendMode: .plusLighter
            )
        case .typoArtNeon:
            TemplateParameters(
                backgroundColor: UIColor.black,
                textureTextColor: UIColor(hex: "C8990D"),
                titleTextColor: UIColor.white,
                textureFont: UIFont(name: "HelveticaNeue-CondensedBold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black),
                shadowOpacity: 1.0, shadowSpread: 20, shadowSize: 30,
                textureOpacity: 0.8, blendMode: .colorDodge
            )
        case .logoPatternSphere:
            TemplateParameters(
                backgroundColor: UIColor.black,
                textureTextColor: UIColor(white: 0.773, alpha: 1),
                titleTextColor: UIColor.white,
                textureFont: UIFont(name: "TimesNewRomanPSMT", size: 61) ?? .systemFont(ofSize: 61),
                titleFont: UIFont(name: "TimesNewRomanPSMT", size: 30) ?? .systemFont(ofSize: 30),
                shadowOpacity: 0, shadowSpread: 0, shadowSize: 0,
                textureOpacity: 1.0, blendMode: .multiply,
                spherizeAmount: 0.35, hueShift: 190, saturation: 70, gradientOpacity: 0.8
            )
        case .waveText:
            TemplateParameters(
                backgroundColor: UIColor(hex: "0D0D28"),
                textureTextColor: .white, titleTextColor: .white,
                textureFont: .systemFont(ofSize: 16),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 80) ?? .systemFont(ofSize: 80, weight: .black),
                shadowOpacity: 0, shadowSpread: 0, shadowSize: 0,
                textureOpacity: 1.0, blendMode: .normal
            )
        case .retroHalftone:
            TemplateParameters(
                backgroundColor: UIColor(hex: "F2EBD9"),
                textureTextColor: UIColor(hex: "D93326"),
                titleTextColor: UIColor(hex: "1A1A1A"),
                textureFont: .systemFont(ofSize: 16),
                titleFont: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black),
                shadowOpacity: 0, shadowSpread: 0, shadowSize: 0,
                textureOpacity: 1.0, blendMode: .multiply
            )
        case .gradientStack:
            TemplateParameters(
                backgroundColor: UIColor(hex: "141420"),
                textureTextColor: .white, titleTextColor: .white,
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
