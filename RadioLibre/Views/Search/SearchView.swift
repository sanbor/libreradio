import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchFiltersView(vm: vm)
                    .padding(.vertical, 8)

                Group {
                    if !vm.hasSearched && !vm.isSearching {
                        ContentUnavailableView(
                            "Search Radio Stations",
                            systemImage: "magnifyingglass",
                            description: Text("Search by station name")
                        )
                    } else if vm.isSearching && vm.results.isEmpty {
                        LoadingView()
                    } else if vm.hasSearched && vm.results.isEmpty {
                        ContentUnavailableView.search(text: vm.query)
                    } else {
                        List {
                            ForEach(vm.results) { station in
                                StationRowView(station: station)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .onAppear {
                                        if station == vm.results.last {
                                            Task { await vm.loadMore() }
                                        }
                                    }
                            }

                            if vm.isSearching {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $vm.query, prompt: "Station name…")
        }
    }
}
