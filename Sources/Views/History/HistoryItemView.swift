import SwiftUI

struct HistoryItemView: View {
    let artwork: ArtworkHistory

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let thumbnailData = artwork.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.tertiary)
                    }
            }

            if let template = artwork.template {
                Text(template.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(artwork.createdAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
