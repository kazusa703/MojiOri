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

        // Step 1-2: Create pattern tile with blur
        let patternFont = UIFont(name: "TimesNewRomanPSMT", size: 61) ?? .systemFont(ofSize: 61)
        guard let patternImage = patternTiler.generatePattern(
            text: patternText,
            font: patternFont,
            textColor: params.textureTextColor,
            tileSize: CGSize(width: 300, height: 72),
            canvasSize: size,
            scale: 15
        ) else { return nil }

        // Step 3: Apply gaussian blur
        var ciImage = CIImage(cgImage: patternImage)
        ciImage = filterChain.applyGaussianBlur(to: ciImage, radius: 4.0)

        // Step 4-7: Apply spherize distortion
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        ciImage = filterChain.applySpherize(
            to: ciImage,
            center: center,
            radius: Double(min(size.width, size.height)) * 0.45,
            scale: Double(params.spherizeAmount)
        )

        // Step 8: Invert colors
        ciImage = filterChain.applyInvert(to: ciImage)

        // Step 9-10: Apply hue and saturation
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

            // Apply gradient overlay (colorBurn)
            context.setBlendMode(.colorBurn)
            context.setAlpha(params.gradientOpacity)
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor.black.cgColor, UIColor.darkGray.cgColor] as CFArray,
                locations: [0.0, 1.0]
            )!
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: size.height),
                end: CGPoint(x: size.width, y: 0),
                options: []
            )

            // Reset transform for text
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -size.height)

            // Draw title text
            guard !titleText.isEmpty else { return }
            let titleFont = UIFont(name: "TimesNewRomanPSMT", size: 120) ?? .systemFont(ofSize: 120)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: params.titleTextColor,
                .paragraphStyle: paragraphStyle,
                .kern: -10,
            ]

            let attrString = NSAttributedString(string: titleText, attributes: attributes)
            let textRect = CGRect(
                x: size.width * 0.1,
                y: size.height * 0.3,
                width: size.width * 0.8,
                height: size.height * 0.4
            )
            attrString.draw(in: textRect)
        }
    }
}
