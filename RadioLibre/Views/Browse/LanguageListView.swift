import SwiftUI

struct LanguageListView: View {
    @ObservedObject var vm: BrowseViewModel
    @State private var searchText = ""

    var filteredLanguages: [Language] {
        if searchText.isEmpty { return vm.languages }
        return vm.languages.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if vm.isLoading && vm.languages.isEmpty {
                LoadingView()
            } else if let error = vm.error, vm.languages.isEmpty {
                ErrorView(error: error) {
                    Task { await vm.loadLanguages() }
                }
            } else {
                List(filteredLanguages) { language in
                    NavigationLink {
                        StationListView(filter: .language(language.name))
                    } label: {
                        HStack {
                            Text(language.name.capitalized)
                                .font(.body)

                            Spacer()

                            Text(language.stationcount.formatted())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search languages")
            }
        }
        .navigationTitle("Languages")
        .task { if vm.languages.isEmpty { await vm.loadLanguages() } }
    }
}
