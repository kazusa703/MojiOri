import UIKit

/// Renders the same text stacked with color gradient offset — creates a 3D extruded look
final class GradientStackRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .gradientStack

    func render(inputs: [String: String], size: CGSize) async -> UIImage? {
        let titleText = inputs["titleText"] ?? ""
        guard !titleText.isEmpty else { return nil }

        let params = templateType.defaultParameters
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            // Fill dark background
            context.setFillColor(params.backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: size))

            let text = titleText.uppercased()
            let fontSize = calculateFontSize(text: text, maxWidth: size.width * 0.8, maxHeight: size.height * 0.35)
            let font = UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)
                ?? .systemFont(ofSize: fontSize, weight: .black)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let textRect = CGRect(
                x: size.width * 0.1,
                y: size.height * 0.3,
                width: size.width * 0.8,
                height: size.height * 0.4
            )

            // Gradient colors for stacking
            let gradientColors: [UIColor] = [
                UIColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 1.0),  // deep blue
                UIColor(red: 0.3, green: 0.1, blue: 0.7, alpha: 1.0),  // purple
                UIColor(red: 0.7, green: 0.1, blue: 0.5, alpha: 1.0),  // magenta
                UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0),  // red-orange
                UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1.0),  // orange
                UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0),  // yellow
            ]

            let layerCount = 30
            let maxOffset = fontSize * 0.25

            // Draw layers from back to front
            for i in 0..<layerCount {
                let progress = CGFloat(i) / CGFloat(layerCount - 1)
                let colorIndex = progress * CGFloat(gradientColors.count - 1)
                let lowerIndex = Int(colorIndex)
                let upperIndex = min(lowerIndex + 1, gradientColors.count - 1)
                let fraction = colorIndex - CGFloat(lowerIndex)

                let color = interpolateColor(gradientColors[lowerIndex], gradientColors[upperIndex], fraction: fraction)

                let offsetY = (1.0 - progress) * maxOffset
                let offsetRect = textRect.offsetBy(dx: 0, dy: offsetY)

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle,
                ]

                NSAttributedString(string: text, attributes: attributes).draw(in: offsetRect)
            }

            // Draw final front layer (white with slight glow)
            let glowAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle,
            ]
            NSAttributedString(string: text, attributes: glowAttributes).draw(in: textRect)
        }
    }

    private func interpolateColor(_ c1: UIColor, _ c2: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(
            red: r1 + (r2 - r1) * fraction,
            green: g1 + (g2 - g1) * fraction,
            blue: b1 + (b2 - b1) * fraction,
            alpha: 1.0
        )
    }

    private func calculateFontSize(text: String, maxWidth: CGFloat, maxHeight: CGFloat) -> CGFloat {
        var fontSize: CGFloat = 400
        let font = UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)
            ?? .systemFont(ofSize: fontSize, weight: .black)
        let testSize = (text as NSString).size(withAttributes: [.font: font])
        let scale = min(maxWidth / testSize.width, maxHeight / testSize.height)
        fontSize *= scale
        return min(fontSize, 500)
    }
}
