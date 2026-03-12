import Foundation

@MainActor
final class BrowseViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var languages: [Language] = []
    @Published var tags: [Tag] = []
    @Published var isLoading = false
    @Published var error: AppError?

    private let service: RadioBrowserService

    init(service: RadioBrowserService = .shared) {
        self.service = service
    }

    func loadCountries() async {
        await load { [weak self] in
            self?.countries = try await RadioBrowserService.shared.fetchCountries()
        }
    }

    func loadLanguages() async {
        await load { [weak self] in
            self?.languages = try await RadioBrowserService.shared.fetchLanguages()
        }
    }

    func loadTags() async {
        await load { [weak self] in
            self?.tags = try await RadioBrowserService.shared.fetchTags()
        }
    }

    private func load(_ operation: @escaping () async throws -> Void) async {
        isLoading = true
        error = nil
        do {
            try await operation()
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .networkUnavailable
        }
        isLoading = false
    }
}
