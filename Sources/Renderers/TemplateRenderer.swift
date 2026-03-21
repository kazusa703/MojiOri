import UIKit

protocol TemplateRenderer: Sendable {
    var templateType: TemplateType { get }
    func render(inputs: [String: String], size: CGSize) async -> UIImage?
}

func renderer(for type: TemplateType) -> any TemplateRenderer {
    switch type {
    case .typoArtClassic: TypoArtClassicRenderer()
    case .typoArtNeon: TypoArtNeonRenderer()
    case .logoPatternSphere: LogoPatternSphereRenderer()
    case .waveText: WaveTextRenderer()
    case .retroHalftone: RetroHalftoneRenderer()
    case .gradientStack: GradientStackRenderer()
    }
}
