import SwiftUI

struct GalleryView: View {
    private let viewModel = GalleryViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.templates) { template in
                    NavigationLink(value: template) {
                        TemplateCardView(template: template)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            BannerAdView()
        }
        .navigationTitle(String(localized: "Gallery"))
        .navigationDestination(for: TemplateType.self) { template in
            EditorView(templateType: template)
        }
    }
}
