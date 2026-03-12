import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()

    // MARK: - Playback state

    enum PlaybackState: Equatable {
        case idle
        case loading(station: StationDTO)
        case playing(station: StationDTO)
        case paused(station: StationDTO)
        case error(station: StationDTO, message: String)

        static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle): return true
            case (.loading(let a), .loading(let b)): return a.stationuuid == b.stationuuid
            case (.playing(let a), .playing(let b)): return a.stationuuid == b.stationuuid
            case (.paused(let a), .paused(let b)): return a.stationuuid == b.stationuuid
            case (.error(let a, let ma), .error(let b, let mb)): return a.stationuuid == b.stationuuid && ma == mb
            default: return false
            }
        }
    }

    @Published private(set) var state: PlaybackState = .idle
    @Published var volume: Float = 1.0 {
        didSet { player.volume = volume }
    }

    var currentStation: StationDTO? {
        switch state {
        case .loading(let s), .playing(let s), .paused(let s), .error(let s, _): return s
        case .idle: return nil
        }
    }

    var isPlaying: Bool {
        if case .playing = state { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    // MARK: - Private

    private let player = AVPlayer()
    private var timeControlObservation: NSKeyValueObservation?
    private var statusObservation: NSKeyValueObservation?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupAudioSession()
        setupInterruptionObserver()
        setupRouteChangeObserver()
        setupPlayerObservations()
    }

    // MARK: - Public API

    func play(station: StationDTO) {
        guard let url = station.streamURL else {
            state = .error(station: station, message: "Invalid stream URL")
            return
        }

        state = .loading(station: station)

        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
        player.volume = volume
        player.play()

        // Fire-and-forget click tracking
        Task.detached {
            await RadioBrowserService.shared.trackClick(stationuuid: station.stationuuid)
        }

        NowPlayingService.shared.updateNowPlaying(station: station, isPlaying: true)
    }

    func pause() {
        guard let station = currentStation else { return }
        player.pause()
        player.replaceCurrentItem(with: nil)
        state = .paused(station: station)
        NowPlayingService.shared.updateNowPlaying(station: station, isPlaying: false)
    }

    func resume() {
        guard case .paused(let station) = state else { return }
        play(station: station)
    }

    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        state = .idle
        NowPlayingService.shared.clearNowPlaying()
    }

    func togglePlayPause() {
        switch state {
        case .playing: pause()
        case .paused: resume()
        default: break
        }
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioPlayerService: Failed to configure audio session: \(error)")
        }
    }

    private func setupInterruptionObserver() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleInterruption(notification)
            }
            .store(in: &cancellables)
    }

    private func setupRouteChangeObserver() {
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleRouteChange(notification)
            }
            .store(in: &cancellables)
    }

    private func setupPlayerObservations() {
        timeControlObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.handleTimeControlStatusChange(player.timeControlStatus)
            }
        }
    }

    private func handleTimeControlStatusChange(_ status: AVPlayer.TimeControlStatus) {
        guard let station = currentStation else { return }
        switch status {
        case .waitingToPlayAtSpecifiedRate:
            state = .loading(station: station)
        case .playing:
            state = .playing(station: station)
            NowPlayingService.shared.updateNowPlaying(station: station, isPlaying: true)
        case .paused:
            // Only transition to paused if we're currently loading/playing (not when we explicitly stopped)
            if case .loading = state {
                // Could be buffering issue — check for errors
                if let error = player.currentItem?.error {
                    state = .error(station: station, message: error.localizedDescription)
                }
            }
        @unknown default:
            break
        }
    }

    private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            if case .playing = state {
                pause()
            }
        case .ended:
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                resume()
            }
        @unknown default:
            break
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        if reason == .oldDeviceUnavailable {
            // Headphones disconnected — pause
            if case .playing = state {
                pause()
            }
        }
    }
}
