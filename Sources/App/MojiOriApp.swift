import SwiftUI
import SwiftData

@main
struct MojiOriApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ArtworkHistory.self])
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GalleryView()
            }
            .tabItem {
                Label("Gallery", systemImage: "square.grid.2x2")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}
