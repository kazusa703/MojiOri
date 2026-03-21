import UIKit

struct CompositeLayer {
    let image: CGImage
    let blendMode: CGBlendMode
    let opacity: CGFloat
    let offset: CGPoint

    init(image: CGImage, blendMode: CGBlendMode = .normal, opacity: CGFloat = 1.0, offset: CGPoint = .zero) {
        self.image = image
        self.blendMode = blendMode
        self.opacity = opacity
        self.offset = offset
    }
}

final class LayerCompositor: Sendable {
    /// Composite multiple layers with blend modes onto a canvas
    func composite(layers: [CompositeLayer], canvasSize: CGSize) -> CGImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        let image = renderer.image { ctx in
            let context = ctx.cgContext

            for layer in layers {
                context.saveGState()
                context.setBlendMode(layer.blendMode)
                context.setAlpha(layer.opacity)

                let rect = CGRect(
                    x: layer.offset.x,
                    y: layer.offset.y,
                    width: canvasSize.width,
                    height: canvasSize.height
                )

                // Flip for CGImage drawing
                context.translateBy(x: 0, y: canvasSize.height)
                context.scaleBy(x: 1, y: -1)

                context.draw(layer.image, in: CGRect(
                    x: rect.origin.x,
                    y: canvasSize.height - rect.origin.y - rect.height,
                    width: rect.width,
                    height: rect.height
                ))

                // Restore for next layer
                context.scaleBy(x: 1, y: -1)
                context.translateBy(x: 0, y: -canvasSize.height)
                context.restoreGState()
            }
        }
        return image.cgImage
    }
}
