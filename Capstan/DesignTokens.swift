import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #D3E4E0
    static let bg = Color(red: 0.827451, green: 0.894118, blue: 0.878431)
    static let bgHex = "#D3E4E0"
    /// #EAF0EF
    static let surface = Color(red: 0.917647, green: 0.941176, blue: 0.937255)
    static let surfaceHex = "#EAF0EF"
    /// #0F241F
    static let ink = Color(red: 0.058824, green: 0.141176, blue: 0.121569)
    static let inkHex = "#0F241F"
    /// #218D71
    static let accent = Color(red: 0.129412, green: 0.552941, blue: 0.443137)
    static let accentHex = "#218D71"
    /// #4A645D
    static let muted = Color(red: 0.290196, green: 0.392157, blue: 0.364706)
    static let mutedHex = "#4A645D"
    static let fontFamily = "Helvetica Neue"
}
