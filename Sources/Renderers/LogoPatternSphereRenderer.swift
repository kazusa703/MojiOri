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

        // Scale factor relative to full res (1500px)
        let scaleFactor = size.width / 1500.0

        // Step 1-2: Create pattern tile
        let fontSize = max(size.width / 20, 16)
        let patternFont = UIFont(name: "TimesNewRomanPSMT", size: fontSize) ?? .systemFont(ofSize: fontSize)
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
        let blurRadius = max(1.5 * scaleFactor, 0.5)
        ciImage = filterChain.applyGaussianBlur(to: ciImage, radius: blurRadius)

        // Step 4-7: Spherize distortion
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let sphereRadius = Double(min(size.width, size.height)) * 0.45
        for _ in 0..<3 {
            ciImage = filterChain.applySpherize(
                to: ciImage,
                center: center,
                radius: sphereRadius,
                scale: Double(params.spherizeAmount)
            )
        }

        // Step 8: Invert colors
        ciImage = filterChain.applyInvert(to: ciImage)

        // Step 9: Darken to ensure contrast with white title
        ciImage = filterChain.applyColorControls(to: ciImage, saturation: 0, brightness: -0.25)

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

            // Apply radial gradient for depth
            context.setBlendMode(.colorBurn)
            context.setAlpha(params.gradientOpacity)
            let colors = [
                UIColor(white: 0.15, alpha: 1.0).cgColor,
                UIColor(white: 0.35, alpha: 1.0).cgColor,
                UIColor(white: 0.15, alpha: 1.0).cgColor,
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

            // Draw title text with stroke for visibility at any size
            guard !titleText.isEmpty else { return }
            let titleFontSize = size.width * 0.14
            let titleFont = UIFont(name: "TimesNewRomanPSMT", size: titleFontSize)
                ?? .systemFont(ofSize: titleFontSize, weight: .regular)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = -titleFontSize * 0.1

            let shadowBlur = max(size.width * 0.008, 2)
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.9)
            shadow.shadowBlurRadius = shadowBlur
            shadow.shadowOffset = CGSize(width: 0, height: shadowBlur * 0.3)

            // Draw text outline first for contrast
            let strokeAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black.withAlphaComponent(0.5),
                .strokeColor: UIColor.black.withAlphaComponent(0.5),
                .strokeWidth: -3.0,
                .paragraphStyle: paragraphStyle,
                .kern: -titleFontSize * 0.04,
            ]

            let textRect = CGRect(
                x: size.width * 0.05,
                y: size.height * 0.3,
                width: size.width * 0.9,
                height: size.height * 0.4
            )
            NSAttributedString(string: titleText.uppercased(), attributes: strokeAttributes).draw(in: textRect)

            // Draw main white text on top
            let mainAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: params.titleTextColor,
                .paragraphStyle: paragraphStyle,
                .kern: -titleFontSize * 0.04,
                .shadow: shadow,
            ]
            NSAttributedString(string: titleText.uppercased(), attributes: mainAttributes).draw(in: textRect)
        }
    }
}
