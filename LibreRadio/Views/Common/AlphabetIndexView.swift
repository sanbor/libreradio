import SwiftUI

struct AlphabetIndexView: View {
    let letters: [String]
    var isLoading: Bool = false
    let onSelect: (String) -> Void

    private static let letterHeight: CGFloat = 16
    private static let verticalPadding: CGFloat = 4

    var body: some View {
        VStack(spacing: 0) {
            ForEach(letters, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isLoading ? Color.secondary : Color.blue)
                    .frame(width: Self.letterHeight, height: Self.letterHeight)
                    .accessibilityLabel(letter)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint("Jump to section \(letter)")
                    .accessibilityAction { onSelect(letter) }
            }
        }
        .padding(.vertical, Self.verticalPadding)
        .padding(.leading, 12).padding(.trailing, 6)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    if let index = Self.letterIndex(forY: value.location.y, letterCount: letters.count) {
                        onSelect(letters[index])
                    }
                }
        )
    }

    /// Calculates the letter index for a given Y coordinate within the alphabet index.
    /// Each letter occupies exactly `letterHeight` points, starting after `verticalPadding`.
    /// Values in the bottom padding area clamp to the last valid index.
    /// Values entirely outside the view's total height return nil.
    static func letterIndex(forY y: CGFloat, letterCount: Int) -> Int? {
        guard letterCount > 0 else { return nil }
        let totalHeight = CGFloat(letterCount) * letterHeight + verticalPadding * 2
        guard y < totalHeight else { return nil }
        let adjustedY = y - verticalPadding
        guard adjustedY >= 0 else { return nil }
        return min(Int(adjustedY / letterHeight), letterCount - 1)
    }
}
