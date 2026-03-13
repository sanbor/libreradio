import MediaPlayer
import UIKit

@MainActor
final class NowPlayingService {
    static let shared = NowPlayingService()

    private weak var audioService: AudioPlayerService?

    init() {
        setupRemoteCommands()
    }

    func setAudioService(_ service: AudioPlayerService) {
        self.audioService = service
    }

    // MARK: - Now Playing Info

    func updateNowPlaying(station: StationDTO, isPlaying: Bool) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = station.name
        info[MPMediaItemPropertyArtist] = station.country ?? ""
        info[MPMediaItemPropertyAlbumTitle] = station.tagList.prefix(3).joined(separator: ", ")
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        // Load artwork asynchronously
        if let faviconURL = station.faviconURL {
            Task {
                await loadArtwork(from: faviconURL, for: station)
            }
        }
    }

    func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Remote Commands

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.playCommand.addTarget { [weak self] _ in
            self?.audioService?.resume()
            return .success
        }

        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { [weak self] _ in
            self?.audioService?.pause()
            return .success
        }

        center.stopCommand.isEnabled = true
        center.stopCommand.addTarget { [weak self] _ in
            self?.audioService?.stop()
            return .success
        }

        center.togglePlayPauseCommand.isEnabled = true
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.audioService?.togglePlayPause()
            return .success
        }

        // Next/Previous track — wired in Phase 4 (favorites)
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
    }

    // MARK: - Artwork

    private func loadArtwork(from url: URL, for station: StationDTO) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }

            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }

            // Update existing info with artwork
            if var info = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                info[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            }
        } catch {
            // Artwork is best-effort — ignore failures
        }
    }
}
