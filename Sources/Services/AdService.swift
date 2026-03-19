import SwiftUI

// AdMob placeholder - real implementation requires Google Mobile Ads SDK
// Using placeholder UI until proper AdMob App ID is obtained

struct BannerAdView: View {
    var body: some View {
        if !PurchaseService.shared.isPro {
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 50)
                .overlay {
                    Text("Ad Space")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
        }
    }
}

enum AdService {
    private static var exportCount = 0

    /// Returns true if an interstitial should be shown
    static func shouldShowInterstitial() -> Bool {
        guard !PurchaseService.shared.isPro else { return false }
        exportCount += 1
        return exportCount % 3 == 0
    }
}
