import SwiftUI

struct GalleryView: View {
    private let templates = TemplateType.allCases

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(templates) { template in
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
