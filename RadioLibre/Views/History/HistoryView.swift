import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \HistoryEntry.playedAt, order: .reverse) private var history: [HistoryEntry]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var playerVM: PlayerViewModel
    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if history.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock.slash",
                        description: Text("Stations you play will appear here.")
                    )
                } else {
                    List {
                        ForEach(history) { entry in
                            let dto = entry.toDTO()
                            HStack {
                                FaviconImageView(urlString: entry.faviconURL, size: 44)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .lineLimit(1)

                                    Text(vm.relativeTime(for: entry.playedAt))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if let codec = entry.codec {
                                    Text(codec)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                playerVM.play(station: dto, context: modelContext)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !history.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            vm.clearAll(context: modelContext)
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}
