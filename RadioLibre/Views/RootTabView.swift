import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var playerVM: PlayerViewModel

    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "antenna.radiowaves.left.and.right")
                }
        }
        .safeAreaInset(edge: .bottom) {
            MiniPlayerView()
        }
    }
}
