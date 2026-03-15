import AppIntents

@available(iOS 17.0, *)
struct TogglePlaybackIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle Playback"

    @MainActor
    func perform() async throws -> some IntentResult {
        RadioPlaybackAction.togglePlayPause?()
        return .result()
    }
}
