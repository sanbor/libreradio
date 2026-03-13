import SwiftUI

@main
struct RadioLibreApp: App {
    @StateObject private var playerVM = PlayerViewModel(audioService: .shared)

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(playerVM)
                .task {
                    NowPlayingService.shared.setAudioService(playerVM.audioService)
                    await ServerDiscoveryService.shared.resolveIfNeeded()
                }
        }
    }
}
