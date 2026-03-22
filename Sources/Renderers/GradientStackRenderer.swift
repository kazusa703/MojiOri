import UIKit

/// Renders the same text stacked with color gradient offset — creates a 3D extruded look
final class GradientStackRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .gradientStack

    func render(inputs: TemplateInputs, context: RenderContext) async -> UIImage? {
        let titleText = inputs.string(for: "titleText")
        guard !titleText.isEmpty else { return nil }

        let bgColor = inputs.color(for: "bgColor", default: UIColor(hex: "141420"))
        let accentColor = inputs.color(for: "accentColor", default: UIColor(hex: "1A33CC"))
        let titleFont = inputs.font(for: "titleFont", default: UIFont(name: "HelveticaNeue-CondensedBlack", size: 200) ?? .systemFont(ofSize: 200, weight: .black))

        let size = context.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let gc = ctx.cgContext
            gc.setFillColor(bgColor.cgColor)
            gc.fill(CGRect(origin: .zero, size: size))

            let text = titleText.uppercased()
            let fontSize = calculateFontSize(text: text, font: titleFont, maxWidth: size.width * 0.8, maxHeight: size.height * 0.35)
            let font = titleFont.withSize(fontSize)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let textRect = CGRect(x: size.width * 0.1, y: size.height * 0.3, width: size.width * 0.8, height: size.height * 0.4)

            // Build gradient from accent color
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            accentColor.getRed(&r, green: &g, blue: &b, alpha: nil)

            let gradientColors: [UIColor] = [
                accentColor,
                UIColor(red: min(r + 0.2, 1), green: g * 0.5, blue: max(b - 0.1, 0), alpha: 1),
                UIColor(red: min(r + 0.4, 1), green: max(g - 0.1, 0), blue: max(b - 0.3, 0), alpha: 1),
                UIColor(red: min(r + 0.6, 1), green: min(g + 0.2, 1), blue: max(b - 0.5, 0), alpha: 1),
                UIColor(red: min(r + 0.7, 1), green: min(g + 0.5, 1), blue: max(b - 0.3, 0), alpha: 1),
                UIColor(red: min(r + 0.8, 1), green: min(g + 0.8, 1), blue: max(b + 0.1, 1), alpha: 1),
            ]

            let layerCount = 30
            let maxOffset = fontSize * 0.25

            for i in 0 ..< layerCount {
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

            // Front white layer
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
        return UIColor(red: r1 + (r2 - r1) * fraction, green: g1 + (g2 - g1) * fraction, blue: b1 + (b2 - b1) * fraction, alpha: 1.0)
    }

    private func calculateFontSize(text: String, font: UIFont, maxWidth: CGFloat, maxHeight: CGFloat) -> CGFloat {
        var fontSize: CGFloat = 400
        let testFont = font.withSize(fontSize)
        let testSize = (text as NSString).size(withAttributes: [.font: testFont])
        let scale = min(maxWidth / testSize.width, maxHeight / testSize.height)
        fontSize *= scale
        return min(fontSize, 500)
    }
}
