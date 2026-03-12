import SwiftUI

struct PlayerControlsView: View {
    @EnvironmentObject private var playerVM: PlayerViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Play/Pause button
            Button {
                playerVM.togglePlayPause()
            } label: {
                Group {
                    if playerVM.isLoading {
                        ProgressView()
                            .controlSize(.large)
                            .frame(width: 64, height: 64)
                    } else {
                        Image(systemName: playerVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .disabled(playerVM.isLoading)

            // Volume + AirPlay row
            HStack(spacing: 16) {
                Image(systemName: "speaker.fill")
                    .foregroundStyle(.secondary)

                Slider(value: Binding(
                    get: { Double(playerVM.audioService.volume) },
                    set: { playerVM.audioService.volume = Float($0) }
                ))

                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.secondary)

                AirPlayButton()
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal)
        }
    }
}
