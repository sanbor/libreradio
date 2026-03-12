import Foundation
import SwiftData

@MainActor
final class FavoritesViewModel: ObservableObject {

    func addFavorite(station: StationDTO, context: ModelContext) {
        guard !isFavorite(uuid: station.stationuuid, context: context) else { return }

        // Get the current max sort order
        let descriptor = FetchDescriptor<FavoriteStation>(
            sortBy: [SortDescriptor(\.sortOrder, order: .reverse)]
        )
        let maxOrder = (try? context.fetch(descriptor).first?.sortOrder) ?? -1
        let favorite = FavoriteStation(from: station, sortOrder: maxOrder + 1)
        context.insert(favorite)

        // Auto-vote on favorite (RadioDroid behavior)
        Task.detached {
            _ = try? await RadioBrowserService.shared.vote(stationuuid: station.stationuuid)
        }
    }

    func removeFavorite(uuid: String, context: ModelContext) {
        let descriptor = FetchDescriptor<FavoriteStation>(
            predicate: #Predicate { $0.stationuuid == uuid }
        )
        if let favorite = try? context.fetch(descriptor).first {
            context.delete(favorite)
        }
    }

    func isFavorite(uuid: String, context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<FavoriteStation>(
            predicate: #Predicate { $0.stationuuid == uuid }
        )
        return (try? context.fetch(descriptor).isEmpty) == false
    }

    func toggleFavorite(station: StationDTO, context: ModelContext) {
        if isFavorite(uuid: station.stationuuid, context: context) {
            removeFavorite(uuid: station.stationuuid, context: context)
        } else {
            addFavorite(station: station, context: context)
        }
    }

    func moveFavorites(from source: IndexSet, to destination: Int, favorites: [FavoriteStation], context: ModelContext) {
        var reordered = favorites
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, favorite) in reordered.enumerated() {
            favorite.sortOrder = index
        }
    }

    func syncWithServer(favorites: [FavoriteStation], context: ModelContext) async {
        guard !favorites.isEmpty else { return }
        let uuids = favorites.map(\.stationuuid)
        guard let serverStations = try? await RadioBrowserService.shared.fetchStations(uuids: uuids) else { return }
        let existingUUIDs = Set(serverStations.map(\.stationuuid))

        for favorite in favorites {
            if !existingUUIDs.contains(favorite.stationuuid) {
                context.delete(favorite)
            }
        }
    }
}
