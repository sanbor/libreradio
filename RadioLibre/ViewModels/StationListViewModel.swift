import Foundation

@MainActor
final class StationListViewModel: ObservableObject {
    enum Filter {
        case country(String)
        case language(String)
        case tag(String)
    }

    let filter: Filter
    let title: String

    @Published var stations: [StationDTO] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: AppError?
    @Published var hasMore = true

    private var currentOffset = 0
    private let pageSize = 100
    private var isLoadingMoreInProgress = false

    init(filter: Filter) {
        self.filter = filter
        switch filter {
        case .country(let code): self.title = code
        case .language(let lang): self.title = lang.capitalized
        case .tag(let tag): self.title = tag.capitalized
        }
    }

    func load() async {
        isLoading = true
        error = nil
        currentOffset = 0
        hasMore = true

        do {
            stations = try await fetchPage(offset: 0)
            hasMore = stations.count == pageSize
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .networkUnavailable
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoadingMoreInProgress, !isLoading else { return }
        isLoadingMoreInProgress = true
        isLoadingMore = true
        let nextOffset = currentOffset + pageSize

        do {
            let page = try await fetchPage(offset: nextOffset)
            stations.append(contentsOf: page)
            hasMore = page.count == pageSize
            currentOffset = nextOffset
        } catch {
            // Silently fail on pagination errors
        }

        isLoadingMore = false
        isLoadingMoreInProgress = false
    }

    // MARK: - Private

    private func fetchPage(offset: Int) async throws -> [StationDTO] {
        switch filter {
        case .country(let code):
            return try await RadioBrowserService.shared.fetchStationsByCountry(code, limit: pageSize, offset: offset)
        case .language(let lang):
            return try await RadioBrowserService.shared.fetchStationsByLanguage(lang, limit: pageSize, offset: offset)
        case .tag(let tag):
            return try await RadioBrowserService.shared.fetchStationsByTag(tag, limit: pageSize, offset: offset)
        }
    }
}
