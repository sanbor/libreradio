import SwiftUI

struct AlphabetIndexView: View {
    let letters: [String]
    let onSelect: (String) -> Void

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let itemHeight: CGFloat = 16
            let totalHeight = CGFloat(letters.count) * itemHeight
            let availableHeight = geometry.size.height
            let needsScrolling = totalHeight > availableHeight

            VStack(spacing: 0) {
                ForEach(letters, id: \.self) { letter in
                    Text(letter)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.blue)
                        .frame(width: 16, height: itemHeight)
                }
            }
            .offset(y: needsScrolling ? scrollOffset : 0)
            .frame(width: 16, height: availableHeight, alignment: .top)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        guard !letters.isEmpty else { return }
                        let fraction = max(0, min(1, value.location.y / availableHeight))
                        let index = min(Int(fraction * CGFloat(letters.count)), letters.count - 1)
                        onSelect(letters[index])

                        if needsScrolling {
                            let targetY = CGFloat(index) * itemHeight
                            let maxOffset = -(totalHeight - availableHeight)
                            scrollOffset = max(maxOffset, min(0, -(targetY - availableHeight / 2 + itemHeight / 2)))
                        }
                    }
            )
        }
        .frame(width: 16)
        .padding(.vertical, 4)
        .padding(.leading, 12).padding(.trailing, 6)
    }
}
