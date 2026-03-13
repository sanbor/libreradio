import AVFoundation
import Foundation

@MainActor
final class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()

    // MARK: - Published State

    @Published private(set) var state: PlaybackState = .idle
    @Published var volume: Float = 1.0 {
        didSet { player.volume = volume }
    }

    enum PlaybackState: Equatable {
        case idle
        case loading(station: StationDTO)
        case playing(station: StationDTO)
        case paused(station: StationDTO)
        case error(station: StationDTO, message: String)

        static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading(let a), .loading(let b)):
                return a == b
            case (.playing(let a), .playing(let b)):
                return a == b
            case (.paused(let a), .paused(let b)):
                return a == b
            case (.error(let aStation, let aMsg), .error(let bStation, let bMsg)):
                return aStation == bStation && aMsg == bMsg
            default:
                return false
            }
        }
    }

    // MARK: - Computed Properties

    var currentStation: StationDTO? {
        switch state {
        case .idle: return nil
        case .loading(let station): return station
        case .playing(let station): return station
        case .paused(let station): return station
        case .error(let station, _): return station
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

    private let player: AVPlayer
    private var playerItemObservation: NSKeyValueObservation?
    private var timeControlObservation: NSKeyValueObservation?
    private let service: RadioBrowserService
    private let nowPlayingService: NowPlayingService

    // MARK: - Init

    init(
        player: AVPlayer = AVPlayer(),
        service: RadioBrowserService = .shared,
        nowPlayingService: NowPlayingService? = nil
    ) {
        self.player = player
        self.service = service
        self.nowPlayingService = nowPlayingService ?? NowPlayingService.shared
        player.volume = volume
        setupAudioSession()
        setupInterruptionObserver()
        setupRouteChangeObserver()
        observeTimeControlStatus()
    }

    // MARK: - Public API

    func play(station: StationDTO) {
        guard let streamURL = station.streamURL else {
            state = .error(station: station, message: AppError.streamURLInvalid.errorDescription ?? "Invalid stream URL")
            return
        }

        state = .loading(station: station)

        // Cancel any existing observations for the old item
        playerItemObservation?.invalidate()
        playerItemObservation = nil

        let asset = AVURLAsset(url: streamURL)
        let item = AVPlayerItem(asset: asset)

        observePlayerItemStatus(item: item, station: station)

        player.replaceCurrentItem(with: item)
        player.play()

        nowPlayingService.updateNowPlaying(station: station, isPlaying: true)

        // Fire-and-forget click tracking
        Task {
            await service.trackClick(stationuuid: station.stationuuid)
        }
    }

    func pause() {
        guard let station = currentStation else { return }
        player.pause()
        state = .paused(station: station)
        nowPlayingService.updateNowPlaying(station: station, isPlaying: false)
    }

    func resume() {
        guard let station = currentStation else { return }
        // For live radio, resume = reconnect to stream
        play(station: station)
    }

    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        playerItemObservation?.invalidate()
        playerItemObservation = nil
        state = .idle
        nowPlayingService.clearNowPlaying()
    }

    func togglePlayPause() {
        switch state {
        case .playing:
            pause()
        case .paused:
            resume()
        case .error:
            resume()
        default:
            break
        }
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: [.allowAirPlay, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            // Audio session errors will surface when playback is attempted
        }
    }

    // MARK: - Interruption Handling

    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            pause()
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resume()
                }
            }
        @unknown default:
            break
        }
    }

    // MARK: - Route Change Handling

    private func setupRouteChangeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        if reason == .oldDeviceUnavailable {
            pause()
        }
    }

    // MARK: - KVO Observations

    private func observeTimeControlStatus() {
        timeControlObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            Task { @MainActor [weak self] in
                guard let self, let station = self.currentStation else { return }
                switch player.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    self.state = .loading(station: station)
                case .playing:
                    self.state = .playing(station: station)
                    self.nowPlayingService.updateNowPlaying(station: station, isPlaying: true)
                case .paused:
                    // Only update if we're not already in idle or error state
                    if case .loading = self.state {
                        // Still loading, player briefly pauses — ignore
                    } else if case .error = self.state {
                        // Already errored — ignore
                    } else if case .idle = self.state {
                        // Already stopped — ignore
                    }
                @unknown default:
                    break
                }
            }
        }
    }

    private func observePlayerItemStatus(item: AVPlayerItem, station: StationDTO) {
        playerItemObservation = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch item.status {
                case .failed:
                    let message = item.error?.localizedDescription ?? "Playback failed"
                    self.state = .error(station: station, message: message)
                    self.nowPlayingService.updateNowPlaying(station: station, isPlaying: false)
                case .readyToPlay:
                    break // timeControlStatus handles the transition to playing
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
