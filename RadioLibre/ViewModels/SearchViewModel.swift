import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = "" {
        didSet { onQueryChanged() }
    }
    @Published var results: [StationDTO] = []
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var error: AppError?

    // Filters
    @Published var filterCountrycode: String?
    @Published var filterLanguage: String?
    @Published var filterCodec: String?
    @Published var filterBitrateMin: Int?

    // Pagination
    private var currentOffset = 0
    private let pageSize = 50
    @Published var hasMore = true

    private var searchTask: Task<Void, Never>?
    private let service: RadioBrowserService

    init(service: RadioBrowserService = .shared) {
        self.service = service
    }

    func onQueryChanged() {
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            hasSearched = false
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)  // 400ms debounce
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    func performSearch() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        error = nil
        currentOffset = 0
        hasMore = true

        do {
            let fetched = try await service.searchStations(
                name: query,
                countrycode: filterCountrycode,
                language: filterLanguage,
                codec: filterCodec,
                bitrateMin: filterBitrateMin,
                limit: pageSize,
                offset: 0
            )
            results = fetched
            hasSearched = true
            hasMore = fetched.count == pageSize
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .networkUnavailable
        }

        isSearching = false
    }

    func loadMore() async {
        guard hasMore, !isSearching else { return }
        isSearching = true
        currentOffset += pageSize

        do {
            let fetched = try await service.searchStations(
                name: query,
                countrycode: filterCountrycode,
                language: filterLanguage,
                codec: filterCodec,
                bitrateMin: filterBitrateMin,
                limit: pageSize,
                offset: currentOffset
            )
            results.append(contentsOf: fetched)
            hasMore = fetched.count == pageSize
        } catch {
            currentOffset -= pageSize  // roll back on failure
        }

        isSearching = false
    }

    func clearFilters() {
        filterCountrycode = nil
        filterLanguage = nil
        filterCodec = nil
        filterBitrateMin = nil
        Task { await performSearch() }
    }
}
