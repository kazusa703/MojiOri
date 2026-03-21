import SwiftUI
import SwiftData

struct EditorView: View {
    @State private var viewModel: EditorViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDiscardAlert = false
    @FocusState private var focusedField: String?

    init(templateType: TemplateType) {
        _viewModel = State(initialValue: EditorViewModel(templateType: templateType))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Preview
                PreviewImageView(image: viewModel.previewImage, isRendering: viewModel.isRendering)

                // Dynamic input fields
                ForEach(viewModel.templateType.inputFields) { field in
                    DynamicInputFieldView(
                        field: field,
                        inputs: $viewModel.inputs,
                        focusedField: $focusedField,
                        onChanged: { viewModel.schedulePreviewUpdate() }
                    )
                }

                // Generate high-res button
                Button {
                    focusedField = nil
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    Task {
                        await viewModel.generatePreview()
                    }
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Generate", comment: "Button to generate artwork")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.hasInput ? Color.accentColor : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.hasInput || viewModel.isRendering)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(viewModel.templateType.displayName)
        .navigationBarBackButtonHidden(viewModel.hasInput)
        .toolbar {
            if viewModel.previewImage != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(String(localized: "Export"))
                }
            }
            if viewModel.hasInput {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDiscardAlert = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back", comment: "Navigation back button")
                        }
                    }
                    .accessibilityLabel(String(localized: "Back"))
                }
            }
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ExportSheetView(viewModel: viewModel, modelContext: modelContext)
        }
        .confirmationDialog(
            String(localized: "Discard changes?"),
            isPresented: $showDiscardAlert,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Discard"), role: .destructive) {
                dismiss()
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        }
    }
}
