import AppIntents
import ActivityKit

@available(iOS 17.0, *)
struct StopPlaybackIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Playback"

    @MainActor
    func perform() async throws -> some IntentResult {
        for activity in Activity<RadioActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        RadioPlaybackAction.stop?()
        return .result()
    }
}
