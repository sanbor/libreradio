import Foundation

enum RadioPlaybackAction {
    @MainActor static var togglePlayPause: (() -> Void)?
    @MainActor static var stop: (() -> Void)?
}
