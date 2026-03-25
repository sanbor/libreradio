import SwiftUI

@main
struct LibreRadioApp: App {
    @StateObject private var playerVM = PlayerViewModel.shared
    @StateObject private var favoritesVM = FavoritesViewModel()
    @StateObject private var networkMonitor = NetworkMonitorService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(playerVM)
                .environmentObject(favoritesVM)
                .environmentObject(networkMonitor)
                .task {
                    RadioPlaybackAction.togglePlayPause = { AudioPlayerService.shared.togglePlayPause() }
                    RadioPlaybackAction.stop = { AudioPlayerService.shared.stop() }
                    NowPlayingService.shared.setAudioService(playerVM.audioService)
                    NowPlayingService.shared.setPlayerViewModel(playerVM)
                    NowPlayingService.shared.setFavoritesViewModel(favoritesVM)
                    LiveActivityService.shared.endOrphanedActivities()
                    if case .idle = AudioPlayerService.shared.state {
                        WidgetDataService.shared.clear()
                    }
                    await ServerDiscoveryService.shared.resolveIfNeeded()
                    await favoritesVM.load()
                }
        }
    }
}
