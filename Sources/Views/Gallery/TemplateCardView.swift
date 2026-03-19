import SwiftUI

struct TemplateCardView: View {
    let template: TemplateType
    @State private var sampleImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardGradient)
                    .aspectRatio(1, contentMode: .fit)

                if let sampleImage {
                    Image(uiImage: sampleImage)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.opacity)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: iconName)
                            .font(.largeTitle)
                            .foregroundStyle(.white)

                        Text(template.displayName)
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
            .animation(.easeIn(duration: 0.3), value: sampleImage != nil)

            Text(templateDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(template.displayName), \(templateDescription)")
        .accessibilityAddTraits(.isButton)
        .task {
            await generateSamplePreview()
        }
    }

    private func generateSamplePreview() async {
        let inputs = sampleInputs
        let templateRenderer = renderer(for: template)
        let image = await templateRenderer.render(inputs: inputs, size: CGSize(width: 300, height: 300))
        sampleImage = image
    }

    private var sampleInputs: [String: String] {
        switch template {
        case .typoArtClassic:
            ["backgroundText": "the Digital Typo as Art", "titleText": "the\nDigital\nTypo\nas\nArt"]
        case .typoArtNeon:
            ["backgroundText": "TypeArt TypoArt", "titleText": "type"]
        case .logoPatternSphere:
            ["patternText": "pattern logo", "titleText": "pattern\nlogo"]
        }
    }

    private var iconName: String {
        switch template {
        case .typoArtClassic: "textformat"
        case .typoArtNeon: "sparkles"
        case .logoPatternSphere: "circle.grid.3x3.fill"
        }
    }

    private var cardGradient: LinearGradient {
        switch template {
        case .typoArtClassic:
            LinearGradient(
                colors: [.red.opacity(0.8), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .typoArtNeon:
            LinearGradient(
                colors: [.green.opacity(0.7), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .logoPatternSphere:
            LinearGradient(
                colors: [.cyan.opacity(0.7), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var templateDescription: String {
        switch template {
        case .typoArtClassic:
            String(localized: "Classic typography art with red texture overlay")
        case .typoArtNeon:
            String(localized: "Neon-style glowing typography art")
        case .logoPatternSphere:
            String(localized: "Spherical pattern with 3D distortion effect")
        }
    }
}
