import SwiftUI

struct DynamicInputFieldView: View {
    let field: TemplateInputField
    @Binding var inputs: TemplateInputs
    var focusedField: FocusState<String?>.Binding
    var onChanged: () -> Void

    var body: some View {
        switch field.fieldType {
        case .text(let multiline, let maxLength, let placeholder):
            TextFieldInput(
                field: field,
                multiline: multiline,
                maxLength: maxLength,
                placeholder: placeholder,
                inputs: $inputs,
                focusedField: focusedField,
                onChanged: onChanged
            )
        case .color(let palette):
            ColorFieldInput(
                field: field,
                palette: palette,
                inputs: $inputs,
                onChanged: onChanged
            )
        case .font:
            FontFieldInput(
                field: field,
                inputs: $inputs,
                onChanged: onChanged
            )
        }
    }
}

// MARK: - Text input

private struct TextFieldInput: View {
    let field: TemplateInputField
    let multiline: Bool
    let maxLength: Int
    let placeholder: String
    @Binding var inputs: TemplateInputs
    var focusedField: FocusState<String?>.Binding
    var onChanged: () -> Void

    private var text: Binding<String> {
        Binding(
            get: { inputs.string(for: field.id) },
            set: {
                var v = $0
                if v.count > maxLength { v = String(v.prefix(maxLength)) }
                inputs.set(.string(v), for: field.id)
                onChanged()
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(field.label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if multiline {
                TextEditor(text: text)
                    .frame(minHeight: 100)
                    .padding(4)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .focused(focusedField, equals: field.id)
                    .overlay(alignment: .topLeading) {
                        if text.wrappedValue.isEmpty {
                            Text(placeholder)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
            } else {
                TextField(placeholder, text: text)
                    .textFieldStyle(.roundedBorder)
                    .focused(focusedField, equals: field.id)
                    .submitLabel(.next)
            }

            if !text.wrappedValue.isEmpty {
                Text("\(text.wrappedValue.count)/\(maxLength)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Color picker with palette

private struct ColorFieldInput: View {
    let field: TemplateInputField
    let palette: [ColorPreset]
    @Binding var inputs: TemplateInputs
    var onChanged: () -> Void

    @State private var showCustomPicker = false

    private var selectedColor: Binding<Color> {
        Binding(
            get: { Color(uiColor: inputs.color(for: field.id)) },
            set: {
                inputs.set(.color(UIColor($0)), for: field.id)
                onChanged()
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(field.label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(palette) { preset in
                        Button {
                            inputs.set(.color(preset.uiColor), for: field.id)
                            onChanged()
                        } label: {
                            Circle()
                                .fill(Color(uiColor: preset.uiColor))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Circle()
                                        .strokeBorder(.primary.opacity(0.2), lineWidth: 1)
                                }
                                .overlay {
                                    if inputs.color(for: field.id).hexString == preset.hex {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                            .shadow(radius: 2)
                                    }
                                }
                        }
                        .accessibilityLabel(preset.label)
                    }

                    // Custom color picker
                    ColorPicker("", selection: selectedColor)
                        .labelsHidden()
                        .frame(width: 36, height: 36)
                }
            }
        }
    }
}

// MARK: - Font picker

private struct FontFieldInput: View {
    let field: TemplateInputField
    @Binding var inputs: TemplateInputs
    var onChanged: () -> Void

    @State private var showFontPicker = false

    private var currentFontName: String {
        inputs.font(for: field.id, default: .systemFont(ofSize: 16)).fontName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(field.label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showFontPicker = true
            } label: {
                HStack {
                    Text(displayName(for: currentFontName))
                        .font(.body)
                    Spacer()
                    Image(systemName: "textformat")
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showFontPicker) {
                FontPickerSheet(
                    selectedFontName: currentFontName,
                    onSelect: { fontName in
                        if let font = UIFont(name: fontName, size: 200) {
                            inputs.set(.font(font), for: field.id)
                            onChanged()
                        }
                    }
                )
            }
        }
    }

    private func displayName(for postScriptName: String) -> String {
        if let font = UIFont(name: postScriptName, size: 12) {
            return "\(font.familyName) \(font.fontName.replacingOccurrences(of: font.familyName, with: "").replacingOccurrences(of: "-", with: " "))".trimmingCharacters(in: .whitespaces)
        }
        return postScriptName
    }
}

// MARK: - Font picker sheet

struct FontPickerSheet: View {
    let selectedFontName: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var fontFamilies: [String] {
        let families = UIFont.familyNames.sorted()
        if searchText.isEmpty { return families }
        return families.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(fontFamilies, id: \.self) { family in
                    FontFamilyRow(
                        family: family,
                        selectedFontName: selectedFontName,
                        onSelect: { fontName in
                            onSelect(fontName)
                            dismiss()
                        }
                    )
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "Search fonts"))
            .navigationTitle(String(localized: "Choose Font"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - Font family row (extracted for ForEach compatibility)

private struct FontFamilyRow: View {
    let family: String
    let selectedFontName: String
    let onSelect: (String) -> Void

    var body: some View {
        let fonts = UIFont.fontNames(forFamilyName: family)
        if fonts.count == 1, let fontName = fonts.first {
            fontButton(fontName: fontName, displayName: family, size: 18)
        } else {
            DisclosureGroup {
                ForEach(fonts, id: \.self) { fontName in
                    let styleName = fontName
                        .replacingOccurrences(of: family, with: "")
                        .replacingOccurrences(of: "-", with: " ")
                        .trimmingCharacters(in: .whitespaces)
                    fontButton(fontName: fontName, displayName: styleName.isEmpty ? fontName : styleName, size: 16)
                }
            } label: {
                HStack {
                    Text("Aa")
                        .font(Font(UIFont(name: fonts.first ?? family, size: 18) ?? .systemFont(ofSize: 18)))
                        .frame(width: 40)
                    Text(family)
                }
            }
        }
    }

    private func fontButton(fontName: String, displayName: String, size: CGFloat) -> some View {
        Button {
            onSelect(fontName)
        } label: {
            HStack {
                Text("Aa")
                    .font(Font(UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)))
                    .frame(width: 40)
                Text(displayName)
                Spacer()
                if fontName == selectedFontName {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
