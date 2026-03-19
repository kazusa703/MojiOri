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

    enum SaveResult {
        case success
        case failure(String)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let exportImage {
                    Image(uiImage: exportImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                } else if isExporting {
                    Spacer()
                    ProgressView(String(localized: "Generating..."))
                    Spacer()
                } else if let previewImage = viewModel.previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
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
                    case .failure(let message):
                        Label(message, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }

                Spacer()
            }
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
            await generateFullRes()
        }
    }

    private func generateFullRes() async {
        isExporting = true
        exportImage = await viewModel.generateFullResolution()
        isExporting = false

        // Save to history
        if exportImage != nil {
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
                saveResult = .success
                // Request review after successful export
                requestReview()
            } else {
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
