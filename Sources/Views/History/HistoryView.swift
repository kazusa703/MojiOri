import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \ArtworkHistory.createdAt, order: .reverse)
    private var artworks: [ArtworkHistory]
    @Environment(\.modelContext) private var modelContext
    @State private var showFavoritesOnly = false

    private var filteredArtworks: [ArtworkHistory] {
        if showFavoritesOnly {
            artworks.filter(\.isFavorite)
        } else {
            artworks
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        Group {
            if artworks.isEmpty {
                ContentUnavailableView(
                    String(localized: "No Artworks Yet"),
                    systemImage: "photo.artframe",
                    description: Text("Create your first artwork from the Gallery tab")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredArtworks) { artwork in
                            HistoryItemView(artwork: artwork)
                                .contextMenu {
                                    Button {
                                        artwork.isFavorite.toggle()
                                    } label: {
                                        Label(
                                            artwork.isFavorite ? String(localized: "Unfavorite") : String(localized: "Favorite"),
                                            systemImage: artwork.isFavorite ? "heart.slash" : "heart"
                                        )
                                    }
                                    Button(role: .destructive) {
                                        modelContext.delete(artwork)
                                    } label: {
                                        Label(String(localized: "Delete"), systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            BannerAdView()
        }
        .navigationTitle(String(localized: "History"))
        .toolbar {
            if !artworks.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFavoritesOnly.toggle()
                    } label: {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                    }
                    .accessibilityLabel(String(localized: "Filter favorites"))
                }
            }
        }
    }
}
