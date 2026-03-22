import CoreImage
import UIKit

struct RenderContext: Sendable {
    let size: CGSize

    /// Scale factor relative to full resolution (1500px base)
    var k: CGFloat {
        min(size.width, size.height) / 1500.0
    }

    /// Scale a value proportionally to canvas size
    func scaled(_ value: CGFloat) -> CGFloat {
        value * k
    }

    /// Font size proportional to canvas width
    func fontSize(_ basePt: CGFloat) -> CGFloat {
        basePt * (size.width / 1500.0)
    }

    /// Shared CIContext for consistent color management
    nonisolated(unsafe) static let ciContext = CIContext(options: [
        .useSoftwareRenderer: false,
    ])

    func toCGImage(_ ciImage: CIImage) -> CGImage? {
        Self.ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
}
