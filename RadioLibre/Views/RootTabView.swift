import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var playerVM: PlayerViewModel

    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "antenna.radiowaves.left.and.right")
                }

            RecentStationsView()
                .tabItem {
                    Label("Recent", systemImage: "clock")
                }
        }
        .safeAreaInset(edge: .bottom) {
            MiniPlayerView()
        }
    }
}
