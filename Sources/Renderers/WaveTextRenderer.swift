import UIKit
import CoreText

/// Renders text repeated in sine-wave rows with rainbow color cycling
final class WaveTextRenderer: TemplateRenderer, @unchecked Sendable {
    let templateType: TemplateType = .waveText

    func render(inputs: [String: String], size: CGSize) async -> UIImage? {
        let titleText = inputs["titleText"] ?? ""
        guard !titleText.isEmpty else { return nil }

        let params = templateType.defaultParameters
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            // Fill background
            context.setFillColor(params.backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: size))

            let text = titleText.uppercased()
            let rowCount = 20
            let fontSize = size.height / CGFloat(rowCount) * 0.9
            let font = UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)
                ?? .systemFont(ofSize: fontSize, weight: .black)

            // Draw rows of text along sine waves
            for row in 0..<rowCount {
                let progress = CGFloat(row) / CGFloat(rowCount)
                let baseY = progress * size.height

                // Color cycling through hues
                let hue = progress
                let color = UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.9)

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                ]

                let charSize = ("W" as NSString).size(withAttributes: attributes)

                // Draw each character with wave offset
                let repeatedText = String(repeating: text + " ", count: 10)
                var x: CGFloat = -charSize.width * 2

                for (i, char) in repeatedText.enumerated() {
                    let wavePhase = CGFloat(row) * 0.5 + CGFloat(i) * 0.15
                    let waveOffset = sin(wavePhase) * fontSize * 0.4
                    let y = baseY + waveOffset

                    let charStr = String(char)
                    (charStr as NSString).draw(
                        at: CGPoint(x: x, y: y),
                        withAttributes: attributes
                    )
                    x += charSize.width * 0.65
                    if x > size.width + charSize.width { break }
                }
            }
        }
    }
}
