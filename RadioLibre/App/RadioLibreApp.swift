import SwiftUI
import SwiftData

@main
struct RadioLibreApp: App {
    @StateObject private var playerVM = PlayerViewModel(audioService: .shared)
    @StateObject private var favoritesVM = FavoritesViewModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(playerVM)
                .environmentObject(favoritesVM)
                .modelContainer(for: [FavoriteStation.self, HistoryEntry.self])
                .task {
                    await ServerDiscoveryService.shared.resolveIfNeeded()
                    NowPlayingService.shared.configure(audioService: .shared)
                }
        }
    }
}
