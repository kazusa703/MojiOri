import SwiftUI
import StoreKit

struct SettingsView: View {
    private var purchaseService: PurchaseService { .shared }

    var body: some View {
        List {
            // Pro section
            Section {
                if purchaseService.isPro {
                    Label(String(localized: "Pro Unlocked"), systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else {
                    Button {
                        Task {
                            await purchaseService.purchasePro()
                        }
                    } label: {
                        HStack {
                            Label(String(localized: "Get Pro (¥480)"), systemImage: "star.fill")
                            Spacer()
                            if purchaseService.isPurchasing {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(purchaseService.isPurchasing)

                    Button(String(localized: "Restore Purchase")) {
                        Task {
                            await purchaseService.restorePurchases()
                        }
                    }
                }
            } header: {
                Text("Pro", comment: "Section header")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    if !purchaseService.isPro {
                        Text("One-time purchase of ¥480. Remove ads and unlock future templates.", comment: "Pro feature description with price")
                        HStack(spacing: 8) {
                            Link(String(localized: "Terms of Use"),
                                 destination: URL(string: "https://kazusa703.github.io/MojiOri/terms.html")!)
                            Text("·")
                            Link(String(localized: "Privacy Policy"),
                                 destination: URL(string: "https://kazusa703.github.io/MojiOri/privacy.html")!)
                        }
                        .font(.caption2)
                    }
                    if let error = purchaseService.purchaseError {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }

            // Export settings
            Section(String(localized: "Export")) {
                Picker(String(localized: "Format"), selection: Bindable(purchaseService).exportFormat) {
                    Text("PNG").tag(ExportFormat.png)
                    Text("JPEG").tag(ExportFormat.jpeg)
                }

                Picker(String(localized: "Quality"), selection: Bindable(purchaseService).exportScale) {
                    Text("1x (1500px)").tag(1)
                    Text("2x (3000px)").tag(2)
                    Text("3x (4500px)").tag(3)
                }
            }

            // About
            Section(String(localized: "About")) {
                LabeledContent(String(localized: "Version"), value: Bundle.main.appVersion)

                Link(String(localized: "Privacy Policy"),
                     destination: URL(string: "https://kazusa703.github.io/MojiOri/privacy.html")!)

                Link(String(localized: "Terms of Use"),
                     destination: URL(string: "https://kazusa703.github.io/MojiOri/terms.html")!)
            }
        }
        .navigationTitle(String(localized: "Settings"))
    }
}

enum ExportFormat: String {
    case png, jpeg
}

extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }
}
