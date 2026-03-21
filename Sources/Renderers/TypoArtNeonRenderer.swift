import UIKit
import CoreImage

final class TypoArtNeonRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .typoArtNeon
    private let textureGenerator = TextTextureGenerator()
    private let filterChain = FilterChain()

    func render(inputs: [String: String], size: CGSize) async -> UIImage? {
        let backgroundText = inputs["backgroundText"] ?? ""
        let titleText = inputs["titleText"] ?? ""
        let params = templateType.defaultParameters

        guard !backgroundText.isEmpty else { return nil }

        // Step 1: Generate background texture
        guard let textureImage = textureGenerator.generateTexture(
            text: backgroundText,
            font: params.textureFont,
            textColor: .white,
            backgroundColor: params.backgroundColor,
            canvasSize: size,
            lineSpacing: 11.5
        ) else { return nil }

        // Step 2-3: Apply wrinkle pattern overlay (simulated with noise)
        let ciTexture = CIImage(cgImage: textureImage)
        let processed = filterChain.applyHighlightShadow(to: ciTexture, highlightAmount: 0.3, shadowAmount: 0.2)

        guard let processedCG = filterChain.toCGImage(processed) else { return nil }

        // Step 4-5: Apply neon color with colorDodge blend
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let finalImage = renderer.image { ctx in
            let context = ctx.cgContext

            // Draw base texture
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)
            context.draw(processedCG, in: CGRect(origin: .zero, size: size))

            // Apply gold-green color overlay
            context.setBlendMode(params.blendMode)
            context.setAlpha(params.textureOpacity)
            context.setFillColor(params.textureTextColor.cgColor)
            context.fill(CGRect(origin: .zero, size: size))

            // Reset transform
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -size.height)

            // Draw title
            guard !titleText.isEmpty else { return }

            let titleFontSize = min(size.width * 0.8, 500.0)
            let titleFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: titleFontSize)
                ?? .systemFont(ofSize: titleFontSize, weight: .black)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black
            shadow.shadowBlurRadius = params.shadowSize
            shadow.shadowOffset = CGSize(width: 0, height: 4)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: params.titleTextColor,
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

        return finalImage
    }
}
