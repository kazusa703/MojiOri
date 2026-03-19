import SwiftUI

@Observable
final class EditorViewModel {
    var templateType: TemplateType
    var inputTexts: [String: String] = [:]
    var previewImage: UIImage?
    var isRendering = false
    var showExportSheet = false

    private var previewTask: Task<Void, Never>?

    init(templateType: TemplateType) {
        self.templateType = templateType
        for field in templateType.inputFields {
            inputTexts[field.id] = ""
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
        let templateRenderer = renderer(for: templateType)
        return await templateRenderer.render(inputs: inputTexts, size: exportSize.cgSize)
    }

    var hasInput: Bool {
        inputTexts.values.contains(where: { !$0.isEmpty })
    }
}

enum ExportSize: String, CaseIterable, Identifiable {
    case square        // 1500x1500
    case instagramStory // 1080x1920
    case twitterHeader // 1500x500
    case facebookCover // 1640x924

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
