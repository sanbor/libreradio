import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject private var playerVM: PlayerViewModel
    @State private var showFullPlayer = false

    var body: some View {
        if let station = playerVM.currentStation {
            HStack(spacing: 12) {
                FaviconImageView(urlString: station.favicon, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        if playerVM.isLoading {
                            ProgressView()
                                .controlSize(.mini)
                        }
                        if let codec = station.codec, let bitrate = station.bitrate, bitrate > 0 {
                            Text("\(codec) · \(bitrate)k")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button {
                    playerVM.togglePlayPause()
                } label: {
                    Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
                .disabled(playerVM.isLoading)

                Button {
                    playerVM.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                showFullPlayer = true
            }
            .sheet(isPresented: $showFullPlayer) {
                FullPlayerView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
