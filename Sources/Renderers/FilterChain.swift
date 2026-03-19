import CoreImage
import UIKit

final class FilterChain: Sendable {
    private nonisolated(unsafe) let ciContext = CIContext()

    func applyGaussianBlur(to image: CIImage, radius: Double) -> CIImage {
        image.applyingGaussianBlur(sigma: radius)
            .cropped(to: image.extent)
    }

    func applySpherize(to image: CIImage, center: CGPoint, radius: Double, scale: Double) -> CIImage {
        guard let filter = CIFilter(name: "CIBumpDistortion") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    func applyHueAdjust(to image: CIImage, angle: Double) -> CIImage {
        guard let filter = CIFilter(name: "CIHueAdjust") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(angle * .pi / 180.0, forKey: kCIInputAngleKey)
        return filter.outputImage ?? image
    }

    func applyColorControls(to image: CIImage, saturation: Double, brightness: Double) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(saturation, forKey: kCIInputSaturationKey)
        filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        return filter.outputImage ?? image
    }

    func applyInvert(to image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIColorInvert") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage ?? image
    }

    func applyHighlightShadow(to image: CIImage, highlightAmount: Double = 0.0, shadowAmount: Double = 0.0) -> CIImage {
        guard let filter = CIFilter(name: "CIHighlightShadowAdjust") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(highlightAmount, forKey: "inputHighlightAmount")
        filter.setValue(shadowAmount, forKey: "inputShadowAmount")
        return filter.outputImage ?? image
    }

    func toCGImage(_ ciImage: CIImage) -> CGImage? {
        ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
}
