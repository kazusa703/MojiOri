import UIKit
import CoreImage

/// Renders large bold text with retro halftone dot overlay and offset shadow
final class RetroHalftoneRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .retroHalftone
    private let filterChain = FilterChain()

    func render(inputs: [String: String], size: CGSize) async -> UIImage? {
        let titleText = inputs["titleText"] ?? ""
        guard !titleText.isEmpty else { return nil }

        let params = templateType.defaultParameters
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            // Fill cream background
            context.setFillColor(params.backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: size))

            let text = titleText.uppercased()
            let fontSize = calculateFontSize(text: text, maxWidth: size.width * 0.85, maxHeight: size.height * 0.5)
            let font = UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)
                ?? .systemFont(ofSize: fontSize, weight: .black)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = -fontSize * 0.15

            // Draw offset shadow (red, shifted)
            let shadowAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: params.textureTextColor,
                .paragraphStyle: paragraphStyle,
            ]

            let shadowOffset: CGFloat = fontSize * 0.06
            let textRect = CGRect(
                x: size.width * 0.075,
                y: size.height * 0.25,
                width: size.width * 0.85,
                height: size.height * 0.5
            )

            let shadowRect = textRect.offsetBy(dx: shadowOffset, dy: shadowOffset)
            NSAttributedString(string: text, attributes: shadowAttributes).draw(in: shadowRect)

            // Draw main text (dark)
            let mainAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: params.titleTextColor,
                .paragraphStyle: paragraphStyle,
            ]
            NSAttributedString(string: text, attributes: mainAttributes).draw(in: textRect)

            // Draw halftone dot pattern overlay
            drawHalftonePattern(context: context, size: size, dotSize: fontSize * 0.035)

            // Draw decorative lines
            context.setStrokeColor(params.titleTextColor.cgColor)
            context.setLineWidth(2)
            let lineY1 = size.height * 0.2
            let lineY2 = size.height * 0.78
            context.move(to: CGPoint(x: size.width * 0.1, y: lineY1))
            context.addLine(to: CGPoint(x: size.width * 0.9, y: lineY1))
            context.move(to: CGPoint(x: size.width * 0.1, y: lineY2))
            context.addLine(to: CGPoint(x: size.width * 0.9, y: lineY2))
            context.strokePath()
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
            y += spacing * 0.866 // hex grid
            row += 1
        }
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
