import SwiftUI

struct TagListView: View {
    @ObservedObject var vm: BrowseViewModel
    @State private var searchText = ""

    var filteredTags: [Tag] {
        if searchText.isEmpty { return vm.tags }
        return vm.tags.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if vm.isLoading && vm.tags.isEmpty {
                LoadingView()
            } else if let error = vm.error, vm.tags.isEmpty {
                ErrorView(error: error) {
                    Task { await vm.loadTags() }
                }
            } else {
                List(filteredTags) { tag in
                    NavigationLink {
                        StationListView(filter: .tag(tag.name))
                    } label: {
                        HStack {
                            Text(tag.name.capitalized)
                                .font(.body)

                            Spacer()

                            Text(tag.stationcount.formatted())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search tags")
            }
        }
        .navigationTitle("Tags")
        .task { if vm.tags.isEmpty { await vm.loadTags() } }
    }
}
