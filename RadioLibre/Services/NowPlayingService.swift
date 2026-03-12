import Foundation
import MediaPlayer
import UIKit

@MainActor
final class NowPlayingService {
    static let shared = NowPlayingService()

    private weak var audioService: AudioPlayerService?
    private var commandCenterConfigured = false

    private init() {}

    func configure(audioService: AudioPlayerService) {
        self.audioService = audioService
        guard !commandCenterConfigured else { return }
        commandCenterConfigured = true
        setupRemoteCommands()
    }

    func updateNowPlaying(station: StationDTO, isPlaying: Bool) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: station.name,
            MPMediaItemPropertyArtist: station.country ?? "",
            MPMediaItemPropertyAlbumTitle: station.tagList.prefix(3).joined(separator: ", "),
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        // Load artwork asynchronously
        if let faviconURL = station.faviconURL {
            Task {
                if let image = await ImageCacheService.shared.image(for: faviconURL) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    info[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                }
            }
        }
    }

    func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Remote Command Center

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            self?.audioService?.resume()
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            self?.audioService?.pause()
            return .success
        }

        center.stopCommand.addTarget { [weak self] _ in
            self?.audioService?.stop()
            return .success
        }

        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.audioService?.togglePlayPause()
            return .success
        }

        // Disable scrubbing (live stream)
        center.changePlaybackPositionCommand.isEnabled = false
        center.skipForwardCommand.isEnabled = false
        center.skipBackwardCommand.isEnabled = false

        // Next/previous through favorites (optional — disabled for now)
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
    }
}
