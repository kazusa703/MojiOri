import SwiftUI

struct TextInputFieldView: View {
    let field: TemplateInputField
    @Binding var text: String
    var focusedField: FocusState<String?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(field.label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if field.isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 100)
                    .padding(4)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .focused(focusedField, equals: field.id)
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(field.placeholder)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
            } else {
                TextField(field.placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
                    .focused(focusedField, equals: field.id)
                    .submitLabel(.next)
            }

            if !text.isEmpty {
                Text("\(text.count)/\(field.maxLength)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .onChange(of: text) {
            if text.count > field.maxLength {
                text = String(text.prefix(field.maxLength))
            }
        }
    }
}
