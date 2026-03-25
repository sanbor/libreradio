import SwiftUI
import WidgetKit

struct RadioWidget: Widget {
    let kind = NowPlayingWidgetData.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NowPlayingTimelineProvider()) { entry in
            NowPlayingWidgetView(entry: entry)
        }
        .configurationDisplayName("Now Playing")
        .description("Shows the currently playing station.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline

struct NowPlayingTimelineProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: NowPlayingWidgetData.suiteName)

    func placeholder(in context: Context) -> NowPlayingWidgetEntry {
        NowPlayingWidgetEntry(
            date: .now,
            data: NowPlayingWidgetData(
                stationName: "Jazz FM",
                codec: "MP3",
                bitrateLabel: "128k",
                flagEmoji: "🇫🇷",
                countryLocation: "FR",
                isPlaying: true,
                isLoading: false,
                isBuffering: false,
                faviconData: nil
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NowPlayingWidgetEntry) -> Void) {
        completion(NowPlayingWidgetEntry(date: .now, data: readData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NowPlayingWidgetEntry>) -> Void) {
        let entry = NowPlayingWidgetEntry(date: .now, data: readData())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func readData() -> NowPlayingWidgetData? {
        guard let data = defaults?.data(forKey: NowPlayingWidgetData.userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(NowPlayingWidgetData.self, from: data)
    }
}

struct NowPlayingWidgetEntry: TimelineEntry {
    let date: Date
    let data: NowPlayingWidgetData?
}

// MARK: - Views

struct NowPlayingWidgetView: View {
    let entry: NowPlayingWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumContent
            default:
                smallContent
            }
        }
        .widgetBackground()
    }

    // MARK: - Small

    private var smallContent: some View {
        Group {
            if let data = entry.data {
                VStack(spacing: 6) {
                    faviconImage(data: data.faviconData, size: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text(data.stationName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    stateIcon(data: data)
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                idleSmall
            }
        }
    }

    private var idleSmall: some View {
        VStack(spacing: 8) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 36))
                .foregroundStyle(.cyan)

            Text("LibreRadio")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Medium

    private var mediumContent: some View {
        Group {
            if let data = entry.data {
                HStack(spacing: 12) {
                    faviconImage(data: data.faviconData, size: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.stationName)
                            .font(.headline)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            if let flag = data.flagEmoji {
                                Text(flag)
                            }
                            if let location = data.countryLocation {
                                Text(location)
                            }
                            if let codec = data.codec {
                                Text(codec)
                            }
                            Text(data.bitrateLabel)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    stateIcon(data: data)
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                idleMedium
            }
        }
    }

    private var idleMedium: some View {
        HStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 44))
                .foregroundStyle(.cyan)

            VStack(alignment: .leading, spacing: 4) {
                Text("LibreRadio")
                    .font(.headline)
                Text("Tap to start listening")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func faviconImage(data: Data?, size: CGFloat) -> some View {
        if let data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
        } else {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func stateIcon(data: NowPlayingWidgetData) -> some View {
        if data.isLoading || data.isBuffering {
            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
        } else if data.isPlaying {
            Image(systemName: "waveform")
                .foregroundStyle(.cyan)
        } else {
            Image(systemName: "pause.fill")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Background Compatibility

private extension View {
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(.fill.tertiary, for: .widget)
        } else {
            padding()
                .background(.ultraThinMaterial)
        }
    }
}
