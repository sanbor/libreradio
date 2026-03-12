import Foundation
import SwiftData

@MainActor
final class PlayerViewModel: ObservableObject {
    let audioService: AudioPlayerService

    var currentStation: StationDTO? { audioService.currentStation }
    var isPlaying: Bool { audioService.isPlaying }
    var isLoading: Bool { audioService.isLoading }

    var errorMessage: String? {
        if case .error(_, let msg) = audioService.state { return msg }
        return nil
    }

    init(audioService: AudioPlayerService = .shared) {
        self.audioService = audioService
    }

    func play(station: StationDTO, context: ModelContext) {
        audioService.play(station: station)
        recordHistory(station: station, context: context)
    }

    func togglePlayPause() {
        audioService.togglePlayPause()
    }

    func stop() {
        audioService.stop()
    }

    func vote(station: StationDTO) async throws -> VoteResponse {
        try await RadioBrowserService.shared.vote(stationuuid: station.stationuuid)
    }

    // MARK: - History recording

    private func recordHistory(station: StationDTO, context: ModelContext) {
        let stationuuid = station.stationuuid
        let thirtyMinutesAgo = Date().addingTimeInterval(-1800)

        // Check for recent duplicate
        let descriptor = FetchDescriptor<HistoryEntry>(
            predicate: #Predicate { entry in
                entry.stationuuid == stationuuid && entry.playedAt > thirtyMinutesAgo
            }
        )
        if let existing = try? context.fetch(descriptor), let entry = existing.first {
            entry.playedAt = Date()
            return
        }

        // Insert new entry
        let entry = HistoryEntry(from: station)
        context.insert(entry)

        // Enforce 50-entry limit
        let allDescriptor = FetchDescriptor<HistoryEntry>(
            sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
        )
        if let all = try? context.fetch(allDescriptor), all.count > 50 {
            for old in all.dropFirst(50) {
                context.delete(old)
            }
        }
    }
}
