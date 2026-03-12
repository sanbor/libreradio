import SwiftUI

struct CountryListView: View {
    @ObservedObject var vm: BrowseViewModel
    @State private var searchText = ""

    var filteredCountries: [Country] {
        if searchText.isEmpty { return vm.countries }
        return vm.countries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if vm.isLoading && vm.countries.isEmpty {
                LoadingView()
            } else if let error = vm.error, vm.countries.isEmpty {
                ErrorView(error: error) {
                    Task { await vm.loadCountries() }
                }
            } else {
                List(filteredCountries) { country in
                    NavigationLink {
                        StationListView(filter: .country(country.iso3166 ?? country.name))
                    } label: {
                        HStack {
                            Text(country.flag)
                                .font(.title2)
                                .frame(width: 40)

                            Text(country.name)
                                .font(.body)

                            Spacer()

                            Text(country.stationcount.formatted())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search countries")
            }
        }
        .navigationTitle("Countries")
        .task { if vm.countries.isEmpty { await vm.loadCountries() } }
    }
}
