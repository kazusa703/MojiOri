import UIKit

final class PatternTiler: Sendable {
    /// Generate a pattern image by tiling text
    func generatePattern(
        text: String,
        font: UIFont,
        textColor: UIColor,
        tileSize: CGSize,
        canvasSize: CGSize,
        scale: CGFloat = 15
    ) -> CGImage? {
        guard !text.isEmpty else { return nil }

        // Create a single tile
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
        ]
        let textSize = (text as NSString).size(withAttributes: attributes)
        let tileDimension = CGSize(
            width: max(textSize.width + 10, tileSize.width),
            height: max(textSize.height + 5, tileSize.height)
        )

        let tileFormat = UIGraphicsImageRendererFormat()
        tileFormat.scale = 1
        let tileRenderer = UIGraphicsImageRenderer(size: tileDimension, format: tileFormat)
        let tileImage = tileRenderer.image { _ in
            (text as NSString).draw(at: CGPoint(x: 5, y: 2), withAttributes: attributes)
        }
        guard let tileCGImage = tileImage.cgImage else { return nil }

        // Tile across canvas
        let scaledTileWidth = tileDimension.width / scale
        let scaledTileHeight = tileDimension.height / scale
        let canvasFormat = UIGraphicsImageRendererFormat()
        canvasFormat.scale = 1
        let canvasRenderer = UIGraphicsImageRenderer(size: canvasSize, format: canvasFormat)
        let patternImage = canvasRenderer.image { ctx in
            let context = ctx.cgContext
            context.setFillColor(UIColor.black.cgColor)
            context.fill(CGRect(origin: .zero, size: canvasSize))

            var y: CGFloat = 0
            while y < canvasSize.height {
                var x: CGFloat = 0
                while x < canvasSize.width {
                    let drawRect = CGRect(x: x, y: y, width: scaledTileWidth, height: scaledTileHeight)
                    context.saveGState()
                    context.translateBy(x: drawRect.origin.x, y: drawRect.origin.y + drawRect.height)
                    context.scaleBy(x: 1, y: -1)
                    context.draw(tileCGImage, in: CGRect(origin: .zero, size: drawRect.size))
                    context.restoreGState()
                    x += scaledTileWidth
                }
                y += scaledTileHeight
            }
        }
        return patternImage.cgImage
    }
}
