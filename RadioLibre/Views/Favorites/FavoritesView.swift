import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteStation.sortOrder) private var favorites: [FavoriteStation]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var playerVM: PlayerViewModel
    @EnvironmentObject private var favoritesVM: FavoritesViewModel

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites",
                        systemImage: "heart.slash",
                        description: Text("Swipe right on any station to add it to your favorites.")
                    )
                } else {
                    List {
                        ForEach(favorites) { favorite in
                            let dto = favorite.toDTO()
                            StationRowView(station: dto)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let favorite = favorites[index]
                                favoritesVM.removeFavorite(uuid: favorite.stationuuid, context: modelContext)
                            }
                        }
                        .onMove { source, destination in
                            favoritesVM.moveFavorites(from: source, to: destination, favorites: favorites, context: modelContext)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}
