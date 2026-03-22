import CoreImage
import UIKit

final class TypoArtClassicRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .typoArtClassic
    private let textureGenerator = TextTextureGenerator()
    private let filterChain = FilterChain()

    func render(inputs: TemplateInputs, context: RenderContext) async -> UIImage? {
        let backgroundText = inputs.string(for: "backgroundText")
        let titleText = inputs.string(for: "titleText")
        let params = templateType.defaultParameters

        // User-customizable colors
        let textureColor = inputs.color(for: "textureColor", default: params.textureTextColor)
        let titleColor = inputs.color(for: "titleColor", default: params.titleTextColor)
        let bgColor = inputs.color(for: "bgColor", default: params.backgroundColor)
        let titleFont = inputs.font(for: "titleFont", default: params.titleFont)

        guard !backgroundText.isEmpty else { return nil }

        let size = context.size

        // Step 1: Generate background texture with white text
        guard let textureImage = textureGenerator.generateTexture(
            text: backgroundText,
            font: params.textureFont,
            textColor: .white,
            backgroundColor: bgColor,
            canvasSize: size,
            lineSpacing: context.scaled(11.5)
        ) else { return nil }

        // Step 2: Scale texture 125%
        let scaledTexture = scaleImage(textureImage, by: 1.25, canvasSize: size)

        // Step 3-4: Apply lighting effect
        let ciTexture = CIImage(cgImage: scaledTexture ?? textureImage)
        let litTexture = filterChain.applyHighlightShadow(to: ciTexture, highlightAmount: 0.2)

        guard let litCGImage = context.toCGImage(litTexture) else { return nil }

        // Step 5: Apply color overlay with blend mode
        let coloredTexture = applyColorOverlay(
            to: litCGImage,
            color: textureColor,
            blendMode: params.blendMode,
            opacity: params.textureOpacity,
            canvasSize: size
        )

        let offsetTexture = coloredTexture ?? litCGImage

        // Step 7-8: Draw title text and compose
        return composeFinal(
            background: offsetTexture,
            titleText: titleText,
            titleColor: titleColor,
            titleFont: titleFont,
            params: params,
            context: context
        )
    }

    private func scaleImage(_ image: CGImage, by scale: CGFloat, canvasSize: CGSize) -> CGImage? {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let scaled = renderer.image { ctx in
            let gc = ctx.cgContext
            gc.setFillColor(UIColor.black.cgColor)
            gc.fill(CGRect(origin: .zero, size: canvasSize))
            let w = canvasSize.width * scale
            let h = canvasSize.height * scale
            let dx = (canvasSize.width - w) / 2
            let dy = (canvasSize.height - h) / 2
            gc.translateBy(x: 0, y: canvasSize.height)
            gc.scaleBy(x: 1, y: -1)
            gc.draw(image, in: CGRect(x: dx, y: -dy, width: w, height: h))
        }
        return scaled.cgImage
    }

    private func applyColorOverlay(to image: CGImage, color: UIColor, blendMode: CGBlendMode, opacity: CGFloat, canvasSize: CGSize) -> CGImage? {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let result = renderer.image { ctx in
            let gc = ctx.cgContext
            gc.translateBy(x: 0, y: canvasSize.height)
            gc.scaleBy(x: 1, y: -1)
            gc.draw(image, in: CGRect(origin: .zero, size: canvasSize))
            gc.scaleBy(x: 1, y: -1)
            gc.translateBy(x: 0, y: -canvasSize.height)
            gc.setBlendMode(blendMode)
            gc.setAlpha(opacity)
            gc.setFillColor(color.cgColor)
            gc.fill(CGRect(origin: .zero, size: canvasSize))
        }
        return result.cgImage
    }

    private func composeFinal(background: CGImage, titleText: String, titleColor: UIColor, titleFont: UIFont, params: TemplateParameters, context: RenderContext) -> UIImage? {
        let size = context.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gc = ctx.cgContext
            gc.translateBy(x: 0, y: size.height)
            gc.scaleBy(x: 1, y: -1)
            gc.draw(background, in: CGRect(origin: .zero, size: size))
            gc.scaleBy(x: 1, y: -1)
            gc.translateBy(x: 0, y: -size.height)

            guard !titleText.isEmpty else { return }

            let titleFontSize = calculateTitleFontSize(for: titleText, font: titleFont, canvasSize: size)
            let scaledFont = titleFont.withSize(titleFontSize)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = -titleFontSize * 0.1

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
                x: size.width * 0.4,
                y: size.height * 0.1,
                width: size.width * 0.55,
                height: size.height * 0.8
            )
            attrString.draw(in: textRect)
        }
    }

    private func calculateTitleFontSize(for text: String, font: UIFont, canvasSize: CGSize) -> CGFloat {
        let lines = text.components(separatedBy: "\n")
        let maxWidth = canvasSize.width * 0.55
        let maxHeight = canvasSize.height * 0.8
        var fontSize: CGFloat = 600
        let testFont = font.withSize(fontSize)
        let longestLine = lines.max(by: { $0.count < $1.count }) ?? text
        let testSize = (longestLine as NSString).size(withAttributes: [.font: testFont])
        let widthScale = maxWidth / testSize.width
        let heightScale = maxHeight / (testSize.height * CGFloat(lines.count))
        fontSize *= min(widthScale, heightScale)
        return min(fontSize, 600)
    }
}
