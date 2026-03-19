import StoreKit
import SwiftUI

@Observable
final class PurchaseService {
    static let shared = PurchaseService()

    private static let proProductID = "com.imaiissatsu.mojiori.pro"

    var isPro = false
    var isPurchasing = false
    var purchaseError: String?
    var exportFormat: ExportFormat = .png
    var exportScale: Int = 1

    private var updateTask: Task<Void, Never>?

    private init() {
        updateTask = Task {
            await listenForTransactions()
        }
        Task {
            await checkCurrentEntitlements()
        }
    }

    func purchasePro() async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            let products = try await Product.products(for: [Self.proProductID])
            guard let product = products.first else {
                purchaseError = String(localized: "Product not found")
                return
            }
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPro = true
                await transaction.finish()
            case .pending:
                purchaseError = String(localized: "Purchase is pending approval")
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await checkCurrentEntitlements()
            if !isPro {
                purchaseError = String(localized: "No purchases to restore")
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func checkCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.proProductID {
                isPro = true
                return
            }
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.proProductID {
                isPro = true
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
