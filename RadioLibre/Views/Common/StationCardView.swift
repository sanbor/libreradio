import SwiftUI
import SwiftData

struct StationCardView: View {
    let station: StationDTO
    @EnvironmentObject private var playerVM: PlayerViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Button {
            playerVM.play(station: station, context: modelContext)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                FaviconImageView(urlString: station.favicon, size: 80)

                Text(station.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)

                if let tag = station.tagList.first {
                    Text(tag)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
    }
}
