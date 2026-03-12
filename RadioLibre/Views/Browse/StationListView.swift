import SwiftUI

struct StationListView: View {
    @StateObject private var vm: StationListViewModel

    init(filter: StationListViewModel.Filter, title: String? = nil) {
        _vm = StateObject(wrappedValue: StationListViewModel(filter: filter))
    }

    var body: some View {
        Group {
            if vm.isLoading && vm.stations.isEmpty {
                LoadingView()
            } else if let error = vm.error, vm.stations.isEmpty {
                ErrorView(error: error) {
                    Task { await vm.load() }
                }
            } else if vm.stations.isEmpty {
                ContentUnavailableView("No Stations", systemImage: "radio", description: Text("No stations found."))
            } else {
                List {
                    ForEach(vm.stations) { station in
                        StationRowView(station: station)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .onAppear {
                                if station == vm.stations.last {
                                    Task { await vm.loadMore() }
                                }
                            }
                    }

                    if vm.isLoadingMore {
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
        .navigationTitle(vm.title)
        .task { await vm.load() }
    }
}
