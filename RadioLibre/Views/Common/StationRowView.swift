import SwiftUI
import SwiftData

struct StationRowView: View {
    let station: StationDTO
    @EnvironmentObject private var playerVM: PlayerViewModel
    @EnvironmentObject private var favoritesVM: FavoritesViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            FaviconImageView(urlString: station.favicon, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(station.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if let tags = station.tagList.prefix(3).joined(separator: ", "), !tags.isEmpty {
                        Text(tags)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let codec = station.codec, !codec.isEmpty {
                    Text(codec)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Text(station.bitrateLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            playerVM.play(station: station, context: modelContext)
        }
        .swipeActions(edge: .leading) {
            Button {
                favoritesVM.toggleFavorite(station: station, context: modelContext)
            } label: {
                Image(systemName: favoritesVM.isFavorite(uuid: station.stationuuid, context: modelContext) ? "heart.slash.fill" : "heart.fill")
            }
            .tint(favoritesVM.isFavorite(uuid: station.stationuuid, context: modelContext) ? .gray : .red)
        }
        .contextMenu {
            Button {
                playerVM.play(station: station, context: modelContext)
            } label: {
                Label("Play", systemImage: "play.fill")
            }

            Button {
                favoritesVM.toggleFavorite(station: station, context: modelContext)
            } label: {
                let isFav = favoritesVM.isFavorite(uuid: station.stationuuid, context: modelContext)
                Label(isFav ? "Remove Favorite" : "Add to Favorites", systemImage: isFav ? "heart.slash.fill" : "heart.fill")
            }

            Button {
                Task {
                    _ = try? await playerVM.vote(station: station)
                }
            } label: {
                Label("Vote", systemImage: "hand.thumbsup.fill")
            }

            Divider()

            if let url = station.streamURL {
                Button {
                    UIPasteboard.general.url = url
                } label: {
                    Label("Copy Stream URL", systemImage: "doc.on.clipboard")
                }
            }

            if let streamURL = station.streamURL {
                ShareLink(item: streamURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }

            if let homepageURL = station.homepageURL {
                Button {
                    UIApplication.shared.open(homepageURL)
                } label: {
                    Label("Visit Website", systemImage: "safari")
                }
            }
        }
    }
}
