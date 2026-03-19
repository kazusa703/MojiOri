import SwiftUI
import SwiftData

struct EditorView: View {
    @State private var viewModel: EditorViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDiscardAlert = false

    init(templateType: TemplateType) {
        _viewModel = State(initialValue: EditorViewModel(templateType: templateType))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Preview
                PreviewImageView(image: viewModel.previewImage, isRendering: viewModel.isRendering)

                // Input fields
                ForEach(viewModel.templateType.inputFields) { field in
                    TextInputFieldView(
                        field: field,
                        text: Binding(
                            get: { viewModel.inputTexts[field.id] ?? "" },
                            set: { viewModel.inputTexts[field.id] = $0 }
                        )
                    )
                }

                // Generate button
                Button {
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
        .navigationTitle(viewModel.templateType.displayName)
        .toolbar {
            if viewModel.previewImage != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ExportSheetView(viewModel: viewModel, modelContext: modelContext)
        }
        .navigationBarBackButtonHidden(viewModel.hasInput)
        .toolbar {
            if viewModel.hasInput {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDiscardAlert = true
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
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
