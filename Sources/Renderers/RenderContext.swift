import UIKit
import CoreImage

/// Shared rendering context for consistent behavior across templates
struct RenderContext {
    let size: CGSize
    let ciContext: CIContext

    /// Scale factor relative to full resolution (1500px base)
    var k: CGFloat { min(size.width, size.height) / 1500.0 }

    /// Scale a value proportionally to canvas size
    func scaled(_ value: CGFloat) -> CGFloat {
        value * k
    }

    /// Font size proportional to canvas width
    func fontSize(_ basePt: CGFloat) -> CGFloat {
        basePt * (size.width / 1500.0)
    }

    /// Shared CIContext for consistent color management
    static let shared = CIContext(options: [
        .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
        .outputColorSpace: CGColorSpaceCreateDeviceRGB(),
    ])

    init(size: CGSize) {
        self.size = size
        self.ciContext = Self.shared
    }

    func toCGImage(_ ciImage: CIImage) -> CGImage? {
        ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
}
