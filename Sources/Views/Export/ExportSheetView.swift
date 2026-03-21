import SwiftUI
import SwiftData
import StoreKit

struct ExportSheetView: View {
    let viewModel: EditorViewModel
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @State private var exportImage: UIImage?
    @State private var isExporting = false
    @State private var showShareSheet = false
    @State private var saveResult: SaveResult?
    @State private var selectedSize: ExportSize = .square
    @State private var showInterstitialPlaceholder = false
    @AppStorage("exportSuccessCount") private var exportSuccessCount = 0

    enum SaveResult {
        case success
        case failure(String)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let exportImage {
                    Image(uiImage: exportImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                } else if isExporting {
                    Spacer()
                    ProgressView(String(localized: "Generating..."))
                    Spacer()
                } else if let previewImage = viewModel.previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }

                // Size picker
                Picker(String(localized: "Size"), selection: $selectedSize) {
                    ForEach(ExportSize.allCases) { size in
                        Text(size.displayName).tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedSize) {
                    Task { await regenerate() }
                }

                if exportImage != nil {
                    HStack(spacing: 16) {
                        Button {
                            saveToPhotos()
                        } label: {
                            Label(String(localized: "Save to Photos"), systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Button {
                            showShareSheet = true
                        } label: {
                            Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }

                if let saveResult {
                    switch saveResult {
                    case .success:
                        Label(String(localized: "Saved!"), systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    case .failure(let message):
                        Label(message, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }

                Spacer()
            }
            .animation(.easeInOut, value: saveResult != nil)
            .navigationTitle(String(localized: "Export"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let exportImage {
                    ShareSheet(items: [exportImage])
                }
            }
        }
        .task {
            // Show interstitial ad before generating (free users, every 3rd export)
            if AdService.shouldShowInterstitial() {
                showInterstitialPlaceholder = true
                try? await Task.sleep(for: .seconds(1))
                showInterstitialPlaceholder = false
            }
            await regenerate()
        }
        .overlay {
            if showInterstitialPlaceholder {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            Text("Ad")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 300, height: 250)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
            }
        }
    }

    private func regenerate() async {
        isExporting = true
        exportImage = await viewModel.generateFullResolution(exportSize: selectedSize)
        isExporting = false

        if exportImage != nil {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Save to history
            let history = ArtworkHistory(
                templateType: viewModel.templateType,
                inputTexts: viewModel.inputTexts
            )
            history.thumbnailData = viewModel.previewImage?.jpegData(compressionQuality: 0.7)
            modelContext.insert(history)
        }
    }

    private func saveToPhotos() {
        guard let image = exportImage else { return }
        ExportService.saveToPhotos(image: image) { success, error in
            if success {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                saveResult = .success
                exportSuccessCount += 1
                // Request review after 3rd and 10th successful export
                if exportSuccessCount == 3 || exportSuccessCount == 10 {
                    requestReview()
                }
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                saveResult = .failure(error?.localizedDescription ?? String(localized: "Failed to save"))
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
