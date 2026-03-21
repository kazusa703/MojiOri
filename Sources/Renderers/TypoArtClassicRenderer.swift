import UIKit
import CoreImage

final class TypoArtClassicRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .typoArtClassic
    private let textureGenerator = TextTextureGenerator()
    private let compositor = LayerCompositor()
    private let filterChain = FilterChain()

    func render(inputs: [String: String], size: CGSize) async -> UIImage? {
        let backgroundText = inputs["backgroundText"] ?? ""
        let titleText = inputs["titleText"] ?? ""
        let params = templateType.defaultParameters

        guard !backgroundText.isEmpty else { return nil }

        // Step 1: Generate background texture with white text
        guard let textureImage = textureGenerator.generateTexture(
            text: backgroundText,
            font: params.textureFont,
            textColor: .white,
            backgroundColor: params.backgroundColor,
            canvasSize: size,
            lineSpacing: 11.5
        ) else { return nil }

        // Step 2: Scale texture 125%
        let scaledTexture = scaleImage(textureImage, by: 1.25, canvasSize: size)

        // Step 3-4: Apply lighting effect (highlight/shadow)
        let ciTexture = CIImage(cgImage: scaledTexture ?? textureImage)
        let litTexture = filterChain.applyHighlightShadow(to: ciTexture, highlightAmount: 0.2)

        // Step 5: Apply color overlay with blend mode
        guard let litCGImage = filterChain.toCGImage(litTexture) else { return nil }

        // Create colored version
        let coloredTexture = applyColorOverlay(
            to: litCGImage,
            color: params.textureTextColor,
            blendMode: params.blendMode,
            opacity: params.textureOpacity,
            canvasSize: size
        )

        // Step 6: Offset texture slightly left
        let offsetTexture = coloredTexture ?? litCGImage

        // Step 7-8: Draw title text and compose
        let finalImage = composeFinal(
            background: offsetTexture,
            titleText: titleText,
            params: params,
            canvasSize: size
        )

        return finalImage
    }

    private func scaleImage(_ image: CGImage, by scale: CGFloat, canvasSize: CGSize) -> CGImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        let scaled = renderer.image { ctx in
            let context = ctx.cgContext
            context.setFillColor(UIColor.black.cgColor)
            context.fill(CGRect(origin: .zero, size: canvasSize))

            let scaledWidth = canvasSize.width * scale
            let scaledHeight = canvasSize.height * scale
            let offsetX = (canvasSize.width - scaledWidth) / 2
            let offsetY = (canvasSize.height - scaledHeight) / 2

            context.translateBy(x: 0, y: canvasSize.height)
            context.scaleBy(x: 1, y: -1)
            context.draw(image, in: CGRect(x: offsetX, y: -offsetY, width: scaledWidth, height: scaledHeight))
        }
        return scaled.cgImage
    }

    private func applyColorOverlay(to image: CGImage, color: UIColor, blendMode: CGBlendMode, opacity: CGFloat, canvasSize: CGSize) -> CGImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        let result = renderer.image { ctx in
            let context = ctx.cgContext

            // Draw base image
            context.translateBy(x: 0, y: canvasSize.height)
            context.scaleBy(x: 1, y: -1)
            context.draw(image, in: CGRect(origin: .zero, size: canvasSize))

            // Apply color overlay with blend mode
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -canvasSize.height)
            context.setBlendMode(blendMode)
            context.setAlpha(opacity)
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: canvasSize))
        }
        return result.cgImage
    }

    private func composeFinal(background: CGImage, titleText: String, params: TemplateParameters, canvasSize: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        return renderer.image { ctx in
            let context = ctx.cgContext

            // Draw background
            context.translateBy(x: 0, y: canvasSize.height)
            context.scaleBy(x: 1, y: -1)
            context.draw(background, in: CGRect(origin: .zero, size: canvasSize))

            // Reset transform for text drawing
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -canvasSize.height)

            // Draw title text with drop shadow
            guard !titleText.isEmpty else { return }

            let titleFontSize = calculateTitleFontSize(for: titleText, canvasSize: canvasSize)
            let titleFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: titleFontSize)
                ?? .systemFont(ofSize: titleFontSize, weight: .black)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = -titleFontSize * 0.1

            // Shadow
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
                x: canvasSize.width * 0.4,
                y: canvasSize.height * 0.1,
                width: canvasSize.width * 0.55,
                height: canvasSize.height * 0.8
            )
            attrString.draw(in: textRect)
        }
    }

    private func calculateTitleFontSize(for text: String, canvasSize: CGSize) -> CGFloat {
        let lines = text.components(separatedBy: "\n")
        let maxWidth = canvasSize.width * 0.55
        let maxHeight = canvasSize.height * 0.8

        // Start with a large size and scale down
        var fontSize: CGFloat = 600
        let font = UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)
            ?? .systemFont(ofSize: fontSize, weight: .black)

        let longestLine = lines.max(by: { $0.count < $1.count }) ?? text
        let testSize = (longestLine as NSString).size(withAttributes: [.font: font])

        let widthScale = maxWidth / testSize.width
        let heightScale = maxHeight / (testSize.height * CGFloat(lines.count))

        fontSize *= min(widthScale, heightScale)
        return min(fontSize, 600)
    }
}
