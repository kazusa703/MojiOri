import CoreImage
import UIKit

final class TypoArtNeonRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .typoArtNeon
    private let textureGenerator = TextTextureGenerator()
    private let filterChain = FilterChain()

    func render(inputs: TemplateInputs, context: RenderContext) async -> UIImage? {
        let backgroundText = inputs.string(for: "backgroundText")
        let titleText = inputs.string(for: "titleText")
        let params = templateType.defaultParameters

        let textureColor = inputs.color(for: "textureColor", default: params.textureTextColor)
        let titleColor = inputs.color(for: "titleColor", default: params.titleTextColor)
        let bgColor = inputs.color(for: "bgColor", default: params.backgroundColor)
        let titleFont = inputs.font(for: "titleFont", default: params.titleFont)

        guard !backgroundText.isEmpty else { return nil }

        let size = context.size

        guard let textureImage = textureGenerator.generateTexture(
            text: backgroundText,
            font: params.textureFont,
            textColor: .white,
            backgroundColor: bgColor,
            canvasSize: size,
            lineSpacing: context.scaled(11.5)
        ) else { return nil }

        let ciTexture = CIImage(cgImage: textureImage)
        let processed = filterChain.applyHighlightShadow(to: ciTexture, highlightAmount: 0.3, shadowAmount: 0.2)

        guard let processedCG = context.toCGImage(processed) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gc = ctx.cgContext

            gc.translateBy(x: 0, y: size.height)
            gc.scaleBy(x: 1, y: -1)
            gc.draw(processedCG, in: CGRect(origin: .zero, size: size))

            gc.setBlendMode(params.blendMode)
            gc.setAlpha(params.textureOpacity)
            gc.setFillColor(textureColor.cgColor)
            gc.fill(CGRect(origin: .zero, size: size))

            gc.scaleBy(x: 1, y: -1)
            gc.translateBy(x: 0, y: -size.height)

            guard !titleText.isEmpty else { return }

            let titleFontSize = min(size.width * 0.8, context.fontSize(500))
            let scaledFont = titleFont.withSize(titleFontSize)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black
            shadow.shadowBlurRadius = context.scaled(params.shadowSize)
            shadow.shadowOffset = CGSize(width: 0, height: context.scaled(4))

            let attributes: [NSAttributedString.Key: Any] = [
                .font: scaledFont,
                .foregroundColor: titleColor,
                .paragraphStyle: paragraphStyle,
                .shadow: shadow,
            ]

            let attrString = NSAttributedString(string: titleText, attributes: attributes)
            let textRect = CGRect(
                x: size.width * 0.05,
                y: size.height * 0.1,
                width: size.width * 0.9,
                height: size.height * 0.8
            )
            attrString.draw(in: textRect)
        }
    }
}
