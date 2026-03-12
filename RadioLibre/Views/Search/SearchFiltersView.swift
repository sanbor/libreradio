import SwiftUI

struct SearchFiltersView: View {
    @ObservedObject var vm: SearchViewModel

    private let codecs = ["MP3", "AAC", "OGG", "FLAC", "AAC+"]
    private let bitrates = [64, 128, 192, 256, 320]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Codec filter
                Menu {
                    Button("Any Codec") { vm.filterCodec = nil }
                    ForEach(codecs, id: \.self) { codec in
                        Button(codec) { vm.filterCodec = codec }
                    }
                } label: {
                    TagChipView(
                        tag: vm.filterCodec.map { "Codec: \($0)" } ?? "Codec",
                        isSelected: vm.filterCodec != nil
                    )
                }

                // Min bitrate filter
                Menu {
                    Button("Any Bitrate") { vm.filterBitrateMin = nil }
                    ForEach(bitrates, id: \.self) { bitrate in
                        Button("\(bitrate)+ kbps") { vm.filterBitrateMin = bitrate }
                    }
                } label: {
                    TagChipView(
                        tag: vm.filterBitrateMin.map { "\($0)+ kbps" } ?? "Bitrate",
                        isSelected: vm.filterBitrateMin != nil
                    )
                }

                if vm.filterCodec != nil || vm.filterLanguage != nil ||
                   vm.filterCountrycode != nil || vm.filterBitrateMin != nil {
                    Button("Clear") {
                        vm.clearFilters()
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
        }
    }
}
