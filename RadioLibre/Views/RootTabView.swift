import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var playerVM: PlayerViewModel

    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "antenna.radiowaves.left.and.right") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            BrowseView()
                .tabItem { Label("Browse", systemImage: "list.bullet") }

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "heart.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
        }
        .safeAreaInset(edge: .bottom) {
            if playerVM.currentStation != nil {
                MiniPlayerView()
                    .background(.ultraThinMaterial)
            }
        }
    }
}
