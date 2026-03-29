import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    CountryListView()
                } label: {
                    Label("Countries", systemImage: "globe")
                }

                NavigationLink {
                    LanguageListView()
                } label: {
                    Label("Languages", systemImage: "character.bubble")
                }

                NavigationLink {
                    TagListView()
                } label: {
                    Label("Tags", systemImage: "tag")
                }
            }
            .navigationTitle("Browse")
        }
        .environmentObject(viewModel)
    }
}
