import SwiftUI

struct PlayerControlsView: View {
    @EnvironmentObject private var playerVM: PlayerViewModel
    @EnvironmentObject private var favoritesVM: FavoritesViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Transport controls
            HStack(spacing: 40) {
                Button {
                    Task { await playerVM.playPreviousFavorite() }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .disabled(favoritesVM.favorites.isEmpty)

                Button {
                    playerVM.togglePlayPause()
                } label: {
                    Group {
                        if playerVM.isLoading {
                            ProgressView()
                                .controlSize(.large)
                        } else {
                            Image(systemName: playerVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 52))
                        }
                    }
                    .frame(width: 56, height: 56)
                }

                Button {
                    Task { await playerVM.playNextFavorite() }
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .disabled(favoritesVM.favorites.isEmpty)
            }
            .foregroundStyle(.primary)

            // Volume
            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(
                    value: Binding(
                        get: { playerVM.audioService.volume },
                        set: { playerVM.audioService.volume = $0 }
                    ),
                    in: 0...1
                )
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            AirPlayButton()
                .frame(width: 36, height: 36)
        }
    }
}
