import Foundation

extension String {
    /// Converts an ISO 3166-1 alpha-2 country code to a flag emoji.
    /// e.g. "US" -> "🇺🇸", "DE" -> "🇩🇪"
    var countryFlag: String {
        let base: UInt32 = 127397  // Unicode regional indicator offset
        return uppercased().unicodeScalars.compactMap {
            Unicode.Scalar(base + $0.value)
        }.map {
            String($0)
        }.joined()
    }
}
