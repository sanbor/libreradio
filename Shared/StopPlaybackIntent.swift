import AppIntents

@available(iOS 17.0, *)
struct StopPlaybackIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Playback"

    @MainActor
    func perform() async throws -> some IntentResult {
        RadioPlaybackAction.stop?()
        return .result()
    }
}
