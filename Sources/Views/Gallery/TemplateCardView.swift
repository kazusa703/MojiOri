import SwiftUI

struct TemplateCardView: View {
    let template: TemplateType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Preview placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardGradient)
                    .aspectRatio(1, contentMode: .fit)

                VStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 40))
                        .foregroundStyle(.white)

                    Text(template.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }

            Text(templateDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
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
