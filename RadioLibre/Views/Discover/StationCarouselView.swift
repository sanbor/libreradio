import SwiftUI

struct StationCarouselView: View {
    let title: String
    let stations: [StationDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(stations) { station in
                        StationCardView(station: station)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
