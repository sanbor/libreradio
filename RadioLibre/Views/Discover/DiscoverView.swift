import SwiftUI

struct DiscoverView: View {
    @StateObject private var vm = DiscoverViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.topByClicks.isEmpty {
                    LoadingView()
                } else if let error = vm.error, vm.topByClicks.isEmpty {
                    ErrorView(error: error) {
                        Task { await vm.load() }
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            if !vm.localStations.isEmpty {
                                StationCarouselView(
                                    title: "Local Stations",
                                    stations: vm.localStations
                                )
                            }

                            if !vm.topByClicks.isEmpty {
                                StationCarouselView(
                                    title: "Top Stations",
                                    stations: vm.topByClicks
                                )
                            }

                            if !vm.topByVotes.isEmpty {
                                StationCarouselView(
                                    title: "Most Voted",
                                    stations: vm.topByVotes
                                )
                            }

                            if !vm.recentlyChanged.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Recently Changed")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)

                                    ForEach(vm.recentlyChanged.prefix(10)) { station in
                                        StationRowView(station: station)
                                            .padding(.horizontal)
                                    }
                                }
                            }

                            if !vm.currentlyPlaying.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Now Playing")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)

                                    ForEach(vm.currentlyPlaying.prefix(10)) { station in
                                        StationRowView(station: station)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable { await vm.refresh() }
                }
            }
            .navigationTitle("Discover")
        }
        .task { await vm.load() }
    }
}
