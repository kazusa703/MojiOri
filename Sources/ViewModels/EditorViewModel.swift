import SwiftUI

@Observable
final class EditorViewModel {
    var templateType: TemplateType
    var inputs = TemplateInputs()
    var previewImage: UIImage?
    var isRendering = false
    var showExportSheet = false

    // Legacy compatibility
    var inputTexts: [String: String] {
        get { inputs.textValues }
        set {
            for (key, value) in newValue {
                inputs.set(.string(value), for: key)
            }
        }
    }

    private var previewTask: Task<Void, Never>?

    init(templateType: TemplateType) {
        self.templateType = templateType
        // Initialize text fields with empty strings
        for field in templateType.inputFields {
            if case .text = field.fieldType {
                inputs.set(.string(""), for: field.id)
            }
        }
        // Initialize color fields with first palette color or default
        for field in templateType.inputFields {
            if case .color(let palette) = field.fieldType, let first = palette.first {
                inputs.set(.color(first.uiColor), for: field.id)
            }
        }
        // Initialize font fields with template default
        for field in templateType.inputFields {
            if case .font = field.fieldType {
                inputs.set(.font(templateType.defaultParameters.titleFont), for: field.id)
            }
        }
    }

    /// Debounced real-time preview (low resolution)
    func schedulePreviewUpdate() {
        previewTask?.cancel()
        guard hasInput else {
            previewImage = nil
            return
        }
        previewTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await generatePreview(lowRes: true)
        }
    }

    func generatePreview(lowRes: Bool = false) async {
        isRendering = true
        let templateRenderer = renderer(for: templateType)
        let size = lowRes ? CGSize(width: 375, height: 375) : CGSize(width: 750, height: 750)
        let image = await templateRenderer.render(inputs: inputTexts, size: size)
        guard !Task.isCancelled else {
            isRendering = false
            return
        }
        isRendering = false
        previewImage = image
    }

    func generateFullResolution(exportSize: ExportSize = .square) async -> UIImage? {
        let qualityScale = PurchaseService.shared.exportScale
        let baseSize = exportSize.cgSize
        let targetSize = CGSize(width: baseSize.width * CGFloat(qualityScale), height: baseSize.height * CGFloat(qualityScale))
        let templateRenderer = renderer(for: templateType)
        guard let rendered = await templateRenderer.render(inputs: inputTexts, size: targetSize) else { return nil }
        return normalizeToPixels(rendered, size: targetSize)
    }

    /// Flatten UIImage to 1x scale so pixel count matches the requested size
    private func normalizeToPixels(_ image: UIImage, size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    var hasInput: Bool {
        inputs.hasInput
    }
}

enum ExportSize: String, CaseIterable, Identifiable {
    case square
    case instagramStory
    case twitterHeader
    case facebookCover

    var id: String { rawValue }

    var cgSize: CGSize {
        switch self {
        case .square: CGSize(width: 1500, height: 1500)
        case .instagramStory: CGSize(width: 1080, height: 1920)
        case .twitterHeader: CGSize(width: 1500, height: 500)
        case .facebookCover: CGSize(width: 1640, height: 924)
        }
    }

    var displayName: String {
        switch self {
        case .square: "1:1 (1500×1500)"
        case .instagramStory: "Story (1080×1920)"
        case .twitterHeader: "X Header (1500×500)"
        case .facebookCover: "FB Cover (1640×924)"
        }
    }
}
