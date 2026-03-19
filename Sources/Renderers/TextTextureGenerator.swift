import UIKit
import CoreText

final class TextTextureGenerator: Sendable {
    /// Generate a texture image by tiling text across the canvas
    func generateTexture(
        text: String,
        font: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor,
        canvasSize: CGSize,
        lineSpacing: CGFloat = 11.5
    ) -> CGImage? {
        guard !text.isEmpty else { return nil }

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { ctx in
            let context = ctx.cgContext

            // Fill background
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: canvasSize))

            // Set up text attributes
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.alignment = .left

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle,
            ]

            // Calculate single line height
            let sampleSize = (text as NSString).size(withAttributes: attributes)
            let lineHeight = sampleSize.height + lineSpacing

            // Tile text across the canvas
            var y: CGFloat = 0
            while y < canvasSize.height {
                var x: CGFloat = 0
                while x < canvasSize.width {
                    let drawText = text + " "
                    (drawText as NSString).draw(
                        at: CGPoint(x: x, y: y),
                        withAttributes: attributes
                    )
                    x += sampleSize.width + font.pointSize
                }
                y += lineHeight
            }
        }
        return image.cgImage
    }
}
