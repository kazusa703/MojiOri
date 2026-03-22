import CoreImage
import UIKit

/// Renders large bold text with retro halftone dot overlay and offset shadow
final class RetroHalftoneRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .retroHalftone
    private let filterChain = FilterChain()

    func render(inputs: TemplateInputs, context: RenderContext) async -> UIImage? {
        let titleText = inputs.string(for: "titleText")
        guard !titleText.isEmpty else { return nil }

        let params = templateType.defaultParameters
        let shadowColor = inputs.color(for: "textureColor", default: params.textureTextColor)
        let bgColor = inputs.color(for: "bgColor", default: params.backgroundColor)
        let titleFont = inputs.font(for: "titleFont", default: params.titleFont)

        let size = context.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let gc = ctx.cgContext
            gc.setFillColor(bgColor.cgColor)
            gc.fill(CGRect(origin: .zero, size: size))

            let text = titleText.uppercased()
            let fontSize = calculateFontSize(text: text, font: titleFont, maxWidth: size.width * 0.85, maxHeight: size.height * 0.5)
            let font = titleFont.withSize(fontSize)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = -fontSize * 0.15

            // Shadow text
            let shadowAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: shadowColor,
                .paragraphStyle: paragraphStyle,
            ]

            let shadowOffset: CGFloat = fontSize * 0.06
            let textRect = CGRect(x: size.width * 0.075, y: size.height * 0.25, width: size.width * 0.85, height: size.height * 0.5)
            let shadowRect = textRect.offsetBy(dx: shadowOffset, dy: shadowOffset)
            NSAttributedString(string: text, attributes: shadowAttributes).draw(in: shadowRect)

            // Main text
            let mainAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: params.titleTextColor,
                .paragraphStyle: paragraphStyle,
            ]
            NSAttributedString(string: text, attributes: mainAttributes).draw(in: textRect)

            // Halftone dots
            drawHalftonePattern(context: gc, size: size, dotSize: fontSize * 0.035)

            // Lines
            gc.setStrokeColor(params.titleTextColor.cgColor)
            gc.setLineWidth(context.scaled(2))
            gc.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.2))
            gc.addLine(to: CGPoint(x: size.width * 0.9, y: size.height * 0.2))
            gc.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.78))
            gc.addLine(to: CGPoint(x: size.width * 0.9, y: size.height * 0.78))
            gc.strokePath()
        }
    }

    private func drawHalftonePattern(context: CGContext, size: CGSize, dotSize: CGFloat) {
        context.setFillColor(UIColor.black.withAlphaComponent(0.06).cgColor)
        let spacing = dotSize * 3
        var y: CGFloat = 0
        var row = 0
        while y < size.height {
            var x: CGFloat = row % 2 == 0 ? 0 : spacing / 2
            while x < size.width {
                context.fillEllipse(in: CGRect(x: x - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize))
                x += spacing
            }
            y += spacing * 0.866
            row += 1
        }
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
