import SwiftUI
import UIKit

struct FaviconImageView: View {
    let urlString: String?
    let size: CGFloat

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "radio")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size * 0.2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
        .task(id: urlString) {
            guard let urlString, let url = URL(string: urlString) else {
                image = nil
                return
            }
            image = await ImageCacheService.shared.image(for: url)
        }
    }
}
