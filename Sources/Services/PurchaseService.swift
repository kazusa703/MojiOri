import StoreKit
import SwiftUI

@Observable
final class PurchaseService {
    static let shared = PurchaseService()

    private static let proProductID = "com.imaiissatsu.mojiori.pro"

    var isPro = false
    var isPurchasing = false
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
        defer { isPurchasing = false }

        do {
            let products = try await Product.products(for: [Self.proProductID])
            guard let product = products.first else { return }
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPro = true
                await transaction.finish()
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            // Purchase failed
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await checkCurrentEntitlements()
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
