import CoreImage
import UIKit

final class LogoPatternSphereRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .logoPatternSphere
    private let patternTiler = PatternTiler()
    private let filterChain = FilterChain()

    func render(inputs: TemplateInputs, context: RenderContext) async -> UIImage? {
        let patternText = inputs.string(for: "patternText")
        let titleText = inputs.string(for: "titleText")
        let params = templateType.defaultParameters

        let accentColor = inputs.color(for: "accentColor", default: UIColor(hex: "008080"))
        let titleFont = inputs.font(for: "titleFont", default: params.titleFont)

        guard !patternText.isEmpty else { return nil }

        let size = context.size

        // Step 1-2: Create pattern tile
        let fontSize = max(context.fontSize(61), 16)
        let patternFont = titleFont.withSize(fontSize)
        guard let patternImage = patternTiler.generatePattern(
            text: patternText,
            font: patternFont,
            textColor: UIColor(white: 0.8, alpha: 1.0),
            tileSize: CGSize(width: size.width / 3.5, height: fontSize * 1.5),
            canvasSize: size,
            scale: 1
        ) else { return nil }

        // Step 3: Blur proportional to size
        var ciImage = CIImage(cgImage: patternImage)
        let blurRadius = max(1.5 * context.k, 0.5)
        ciImage = filterChain.applyGaussianBlur(to: ciImage, radius: blurRadius)

        // Step 4-7: Spherize distortion (k-proportional)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let sphereRadius = Double(min(size.width, size.height)) * 0.45
        for _ in 0 ..< 3 {
            ciImage = filterChain.applySpherize(to: ciImage, center: center, radius: sphereRadius, scale: Double(params.spherizeAmount))
        }

        // Step 8: Invert
        ciImage = filterChain.applyInvert(to: ciImage)
        ciImage = filterChain.applyColorControls(to: ciImage, saturation: 0, brightness: -0.25)

        // Step 10: Apply accent color hue
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0
        accentColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: nil)
        ciImage = filterChain.applyHueAdjust(to: ciImage, angle: Double(hue * 360))
        ciImage = filterChain.applyColorControls(to: ciImage, saturation: Double(max(sat, 0.5)), brightness: 0)

        guard let finalCG = context.toCGImage(ciImage) else { return nil }

        // Compose with gradient and title
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gc = ctx.cgContext
            gc.translateBy(x: 0, y: size.height)
            gc.scaleBy(x: 1, y: -1)
            gc.draw(finalCG, in: CGRect(origin: .zero, size: size))

            // Radial gradient
            gc.setBlendMode(.colorBurn)
            gc.setAlpha(params.gradientOpacity)
            let colors = [
                UIColor(white: 0.15, alpha: 1.0).cgColor,
                UIColor(white: 0.35, alpha: 1.0).cgColor,
                UIColor(white: 0.15, alpha: 1.0).cgColor,
            ] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 0.5, 1.0])!
            gc.drawRadialGradient(gradient, startCenter: CGPoint(x: size.width / 2, y: size.height / 2), startRadius: 0, endCenter: CGPoint(x: size.width / 2, y: size.height / 2), endRadius: size.width * 0.7, options: .drawsAfterEndLocation)

            gc.scaleBy(x: 1, y: -1)
            gc.translateBy(x: 0, y: -size.height)

            guard !titleText.isEmpty else { return }

            let titleFontSize = context.fontSize(210)
            let scaledFont = titleFont.withSize(titleFontSize)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = -titleFontSize * 0.1

            let shadowBlur = context.scaled(12)
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.9)
            shadow.shadowBlurRadius = shadowBlur
            shadow.shadowOffset = CGSize(width: 0, height: shadowBlur * 0.3)

            let strokeAttributes: [NSAttributedString.Key: Any] = [
                .font: scaledFont,
                .foregroundColor: UIColor.black.withAlphaComponent(0.5),
                .strokeColor: UIColor.black.withAlphaComponent(0.5),
                .strokeWidth: -3.0,
                .paragraphStyle: paragraphStyle,
                .kern: -titleFontSize * 0.04,
            ]

            let textRect = CGRect(x: size.width * 0.05, y: size.height * 0.3, width: size.width * 0.9, height: size.height * 0.4)
            NSAttributedString(string: titleText.uppercased(), attributes: strokeAttributes).draw(in: textRect)

            let mainAttributes: [NSAttributedString.Key: Any] = [
                .font: scaledFont,
                .foregroundColor: params.titleTextColor,
                .paragraphStyle: paragraphStyle,
                .kern: -titleFontSize * 0.04,
                .shadow: shadow,
            ]
            NSAttributedString(string: titleText.uppercased(), attributes: mainAttributes).draw(in: textRect)
        }
    }
}
