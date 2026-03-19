import SwiftUI

struct PreviewImageView: View {
    let image: UIImage?
    let isRendering: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .aspectRatio(1, contentMode: .fit)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if isRendering {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("Preview will appear here", comment: "Placeholder text")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}
