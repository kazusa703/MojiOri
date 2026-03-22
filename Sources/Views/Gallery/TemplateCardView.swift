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
        var sampleInputs = TemplateInputs()
        for (key, value) in self.sampleInputs {
            sampleInputs.set(.string(value), for: key)
        }
        let templateRenderer = renderer(for: template)
        let context = RenderContext(size: CGSize(width: 300, height: 300))
        let image = await templateRenderer.render(inputs: sampleInputs, context: context)
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
        case .waveText:
            ["titleText": "WAVE"]
        case .retroHalftone:
            ["titleText": "RETRO"]
        case .gradientStack:
            ["titleText": "STACK"]
        }
    }

    private var iconName: String {
        switch template {
        case .typoArtClassic: "textformat"
        case .typoArtNeon: "sparkles"
        case .logoPatternSphere: "circle.grid.3x3.fill"
        case .waveText: "water.waves"
        case .retroHalftone: "circle.dotted"
        case .gradientStack: "square.3.layers.3d"
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
        case .waveText:
            LinearGradient(
                colors: [.purple.opacity(0.7), .blue.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .retroHalftone:
            LinearGradient(
                colors: [.orange.opacity(0.7), .red.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .gradientStack:
            LinearGradient(
                colors: [.pink.opacity(0.7), .indigo.opacity(0.5)],
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
        case .waveText:
            String(localized: "Text flowing in rainbow sine waves")
        case .retroHalftone:
            String(localized: "Bold retro text with halftone dot pattern")
        case .gradientStack:
            String(localized: "3D stacked text with color gradient")
        }
    }
}
