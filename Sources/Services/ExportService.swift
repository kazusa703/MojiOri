import UIKit
import Photos

enum ExportService {
    static func saveToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        let settings = PurchaseService.shared
        let imageData: Data?

        switch settings.exportFormat {
        case .png:
            imageData = image.pngData()
        case .jpeg:
            imageData = image.jpegData(compressionQuality: 0.95)
        }

        guard let data = imageData, let finalImage = UIImage(data: data) else {
            completion(false, nil)
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAsset(from: finalImage)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
}
