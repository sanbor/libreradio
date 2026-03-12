import SwiftUI

struct BrowseView: View {
    @StateObject private var vm = BrowseViewModel()

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    CountryListView(vm: vm)
                } label: {
                    Label("Countries", systemImage: "globe")
                }

                NavigationLink {
                    LanguageListView(vm: vm)
                } label: {
                    Label("Languages", systemImage: "text.bubble")
                }

                NavigationLink {
                    TagListView(vm: vm)
                } label: {
                    Label("Tags & Genres", systemImage: "tag")
                }
            }
            .navigationTitle("Browse")
        }
    }
}
