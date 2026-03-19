import SwiftUI

@Observable
final class EditorViewModel {
    var templateType: TemplateType
    var inputTexts: [String: String] = [:]
    var previewImage: UIImage?
    var isRendering = false
    var showExportSheet = false

    init(templateType: TemplateType) {
        self.templateType = templateType
        for field in templateType.inputFields {
            inputTexts[field.id] = ""
        }
    }

    func generatePreview() async {
        isRendering = true
        let templateRenderer = renderer(for: templateType)
        let previewSize = CGSize(width: 750, height: 750)
        let image = await templateRenderer.render(inputs: inputTexts, size: previewSize)
        isRendering = false
        previewImage = image
    }

    func generateFullResolution() async -> UIImage? {
        let templateRenderer = renderer(for: templateType)
        let fullSize = CGSize(width: 1500, height: 1500)
        return await templateRenderer.render(inputs: inputTexts, size: fullSize)
    }

    var hasInput: Bool {
        inputTexts.values.contains(where: { !$0.isEmpty })
    }
}
