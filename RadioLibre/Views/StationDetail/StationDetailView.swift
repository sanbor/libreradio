import SwiftUI

struct StationDetailView: View {
    let station: StationDTO
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Station") {
                    LabeledContent("Name", value: station.name)
                    if let country = station.country {
                        LabeledContent("Country", value: "\(station.countryFlag) \(country)")
                    }
                    if let state = station.state, !state.isEmpty {
                        LabeledContent("State", value: state)
                    }
                    if let language = station.language, !language.isEmpty {
                        LabeledContent("Language", value: language)
                    }
                }

                Section("Stream") {
                    if let codec = station.codec {
                        LabeledContent("Codec", value: codec)
                    }
                    if let bitrate = station.bitrate, bitrate > 0 {
                        LabeledContent("Bitrate", value: "\(bitrate) kbps")
                    }
                    LabeledContent("HLS", value: station.isHLS ? "Yes" : "No")
                    LabeledContent("Online", value: station.isOnline ? "✅ Yes" : "❌ No")

                    if let url = station.streamURL {
                        LabeledContent("Stream URL") {
                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }

                if !station.tagList.isEmpty {
                    Section("Tags") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(station.tagList, id: \.self) { tag in
                                    TagChipView(tag: tag)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Statistics") {
                    if let votes = station.votes {
                        LabeledContent("Votes", value: votes.formatted())
                    }
                    if let clicks = station.clickcount {
                        LabeledContent("Clicks (24h)", value: clicks.formatted())
                    }
                    if let trend = station.clicktrend {
                        LabeledContent("Click Trend", value: (trend >= 0 ? "+" : "") + trend.formatted())
                    }
                }

                if let homepageURL = station.homepageURL {
                    Section("Links") {
                        Link("Visit Website", destination: homepageURL)
                    }
                }
            }
            .navigationTitle("Station Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
