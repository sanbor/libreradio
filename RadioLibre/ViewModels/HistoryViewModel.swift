import Foundation
import SwiftData

@MainActor
final class HistoryViewModel: ObservableObject {

    func clearAll(context: ModelContext) {
        let descriptor = FetchDescriptor<HistoryEntry>()
        if let all = try? context.fetch(descriptor) {
            for entry in all {
                context.delete(entry)
            }
        }
    }

    func relativeTime(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
