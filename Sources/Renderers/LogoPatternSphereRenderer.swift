import UIKit
import CoreImage

final class LogoPatternSphereRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .logoPatternSphere
    private let patternTiler = PatternTiler()
    private let filterChain = FilterChain()

    func render(inputs: [String: String], size: CGSize) async -> UIImage? {
        let patternText = inputs["patternText"] ?? ""
        let titleText = inputs["titleText"] ?? ""
        let params = templateType.defaultParameters

        guard !patternText.isEmpty else { return nil }

        // Step 1-2: Create pattern tile (larger scale so text is readable)
        let fontSize = max(size.width / 25, 20)
        let patternFont = UIFont(name: "TimesNewRomanPSMT", size: fontSize) ?? .systemFont(ofSize: fontSize)
        guard let patternImage = patternTiler.generatePattern(
            text: patternText,
            font: patternFont,
            textColor: UIColor(white: 0.85, alpha: 1.0),
            tileSize: CGSize(width: size.width / 4, height: fontSize * 1.4),
            canvasSize: size,
            scale: 1
        ) else { return nil }

        // Step 3: Light blur to soften edges (keep text readable)
        var ciImage = CIImage(cgImage: patternImage)
        ciImage = filterChain.applyGaussianBlur(to: ciImage, radius: 1.5)

        // Step 4-7: Spherize distortion (moderate)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let sphereRadius = Double(min(size.width, size.height)) * 0.45
        // Apply multiple passes for gradual 3D effect
        for _ in 0..<3 {
            ciImage = filterChain.applySpherize(
                to: ciImage,
                center: center,
                radius: sphereRadius,
                scale: Double(params.spherizeAmount)
            )
        }

        // Step 8: Invert colors (white text on black -> black text on white -> then colorize)
        ciImage = filterChain.applyInvert(to: ciImage)

        // Step 9: Adjust contrast to make text pop
        ciImage = filterChain.applyColorControls(to: ciImage, saturation: 0, brightness: -0.1)

        // Step 10: Apply hue and saturation for color
        ciImage = filterChain.applyHueAdjust(to: ciImage, angle: Double(params.hueShift))
        ciImage = filterChain.applyColorControls(to: ciImage, saturation: Double(params.saturation) / 100.0, brightness: 0)

        guard let finalCG = filterChain.toCGImage(ciImage) else { return nil }

        // Step 11: Compose with gradient and title
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let context = ctx.cgContext

            // Draw processed background
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)
            context.draw(finalCG, in: CGRect(origin: .zero, size: size))

            // Apply gradient overlay (colorBurn) for depth
            context.setBlendMode(.colorBurn)
            context.setAlpha(params.gradientOpacity)
            let colors = [
                UIColor(white: 0.1, alpha: 1.0).cgColor,
                UIColor(white: 0.4, alpha: 1.0).cgColor,
                UIColor(white: 0.1, alpha: 1.0).cgColor,
            ] as CFArray
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0.0, 0.5, 1.0]
            )!
            context.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                startRadius: 0,
                endCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                endRadius: size.width * 0.7,
                options: .drawsAfterEndLocation
            )

            // Reset transform for text
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -size.height)

            // Draw title text with shadow
            guard !titleText.isEmpty else { return }
            let titleFontSize = size.width * 0.12
            let titleFont = UIFont(name: "TimesNewRomanPSMT", size: titleFontSize)
                ?? .systemFont(ofSize: titleFontSize, weight: .regular)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = -titleFontSize * 0.15

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.8)
            shadow.shadowBlurRadius = 10
            shadow.shadowOffset = CGSize(width: 0, height: 3)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: params.titleTextColor,
                .paragraphStyle: paragraphStyle,
                .kern: -titleFontSize * 0.05,
                .shadow: shadow,
            ]

            let attrString = NSAttributedString(string: titleText.uppercased(), attributes: attributes)
            let textRect = CGRect(
                x: size.width * 0.05,
                y: size.height * 0.3,
                width: size.width * 0.9,
                height: size.height * 0.4
            )
            attrString.draw(in: textRect)
        }
    }
}
