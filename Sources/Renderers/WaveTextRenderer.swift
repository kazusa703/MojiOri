import CoreText
import UIKit

/// Renders text repeated in sine-wave rows with rainbow color cycling
final class WaveTextRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .waveText

    func render(inputs: TemplateInputs, context: RenderContext) async -> UIImage? {
        let titleText = inputs.string(for: "titleText")
        guard !titleText.isEmpty else { return nil }

        let bgColor = inputs.color(for: "bgColor", default: UIColor(hex: "0D0D28"))
        let titleFont = inputs.font(for: "titleFont", default: UIFont(name: "HelveticaNeue-CondensedBlack", size: 80) ?? .systemFont(ofSize: 80, weight: .black))

        let size = context.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let gc = ctx.cgContext
            gc.setFillColor(bgColor.cgColor)
            gc.fill(CGRect(origin: .zero, size: size))

            let text = titleText.uppercased()
            let rowCount = 20
            let fontSize = size.height / CGFloat(rowCount) * 0.9
            let font = titleFont.withSize(fontSize)

            for row in 0 ..< rowCount {
                let progress = CGFloat(row) / CGFloat(rowCount)
                let baseY = progress * size.height
                let hue = progress
                let color = UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.9)

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                ]

                let charSize = ("W" as NSString).size(withAttributes: attributes)
                let repeatedText = String(repeating: text + " ", count: 10)
                var x: CGFloat = -charSize.width * 2

                for (i, char) in repeatedText.enumerated() {
                    let wavePhase = CGFloat(row) * 0.5 + CGFloat(i) * 0.15
                    let waveOffset = sin(wavePhase) * fontSize * 0.4
                    let y = baseY + waveOffset

                    (String(char) as NSString).draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
                    x += charSize.width * 0.65
                    if x > size.width + charSize.width { break }
                }
            }
        }
    }
}
