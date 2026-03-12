import SwiftUI
import AVKit

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = .label
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
