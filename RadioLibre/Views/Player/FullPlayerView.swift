import SwiftUI
import SwiftData

struct FullPlayerView: View {
    @EnvironmentObject private var playerVM: PlayerViewModel
    @EnvironmentObject private var favoritesVM: FavoritesViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDetail = false

    var station: StationDTO? { playerVM.currentStation }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 24) {
                    // Artwork
                    FaviconImageView(urlString: station?.favicon, size: 160)
                        .shadow(radius: 8)

                    // Station info
                    if let station {
                        VStack(spacing: 4) {
                            Text(station.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 4) {
                                if let country = station.countrycode {
                                    Text(country.countryFlag)
                                }
                                if let lang = station.language, !lang.isEmpty {
                                    Text(lang.capitalized)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.subheadline)
                        }

                        // Controls
                        PlayerControlsView()

                        // Action buttons
                        HStack(spacing: 32) {
                            Button {
                                favoritesVM.toggleFavorite(station: station, context: modelContext)
                            } label: {
                                let isFav = favoritesVM.isFavorite(uuid: station.stationuuid, context: modelContext)
                                VStack(spacing: 4) {
                                    Image(systemName: isFav ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundStyle(isFav ? .red : .primary)
                                    Text("Favorite")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Button {
                                Task { _ = try? await playerVM.vote(station: station) }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "hand.thumbsup")
                                        .font(.title2)
                                    Text("Vote")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Button {
                                showDetail = true
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "info.circle")
                                        .font(.title2)
                                    Text("Info")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .foregroundStyle(.primary)

                        // Tags
                        if !station.tagList.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(station.tagList.prefix(8), id: \.self) { tag in
                                        TagChipView(tag: tag)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Technical info
                        VStack(spacing: 4) {
                            if let codec = station.codec, let bitrate = station.bitrate {
                                Text("Codec: \(codec)  ·  Bitrate: \(bitrate) kbps")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if station.isOnline {
                                Text("✅ Online")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showDetail) {
            if let station {
                StationDetailView(station: station)
            }
        }
    }
}
