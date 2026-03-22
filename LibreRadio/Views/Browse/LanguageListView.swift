import SwiftUI

struct LanguageListView: View {
    @StateObject private var viewModel = BrowseViewModel()

    var body: some View {
        Group {
            if viewModel.isLoadingLanguages && viewModel.languages.isEmpty {
                LoadingView(message: "Loading languages...")
            } else if let error = viewModel.languagesError, viewModel.languages.isEmpty {
                ErrorView(error: error) {
                    await viewModel.loadLanguages()
                }
            } else {
                languageList
            }
        }
        .navigationTitle("Languages")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker("Sort", selection: $viewModel.languagesSortOrder) {
                    ForEach(BrowseSortOrder.allCases, id: \.self) { order in
                        Text(order.label).tag(order)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }
        }
        .task { await viewModel.loadLanguages() }
    }

    private var sectionedLanguages: [(letter: String, languages: [Language])] {
        let grouped = Dictionary(grouping: viewModel.sortedLanguages) { language in
            languageSectionKey(for: language.name)
        }
        return grouped.sorted { lhs, rhs in
            if lhs.key == "#" { return false }
            if rhs.key == "#" { return true }
            return lhs.key < rhs.key
        }
        .map { (letter: $0.key, languages: $0.value) }
    }

    private var languageList: some View {
        Group {
            if viewModel.languagesSortOrder == .alphabetical {
                alphabeticalList
            } else {
                flatList
            }
        }
    }

    private var alphabeticalList: some View {
        let sections = sectionedLanguages
        let letters = sections.map(\.letter)

        return ScrollViewReader { proxy in
            List {
                ForEach(sections, id: \.letter) { section in
                    Section {
                        ForEach(section.languages) { language in
                            languageRow(language)
                        }
                    } header: {
                        Text(section.letter)
                    }
                    .id(section.letter)
                }

                Color.clear
                    .frame(height: LayoutConstants.listBottomPadding)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .trailing, spacing: 0) {
                AlphabetIndexView(letters: letters) { letter in
                    withAnimation {
                        proxy.scrollTo(letter, anchor: .top)
                    }
                }
            }
        }
    }

    private var flatList: some View {
        List {
            ForEach(viewModel.sortedLanguages) { language in
                languageRow(language)
            }

            Color.clear
                .frame(height: LayoutConstants.listBottomPadding)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private func languageRow(_ language: Language) -> some View {
        NavigationLink {
            StationListView(filter: .language(language.name), title: language.name.capitalized)
        } label: {
            HStack {
                Text(language.name.capitalized)
                Spacer()
                Text("\(language.stationcount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

func languageSectionKey(for name: String) -> String {
    let folded = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    guard let first = folded.first, first.isASCII && first.isLetter else { return "#" }
    return String(first).uppercased()
}
