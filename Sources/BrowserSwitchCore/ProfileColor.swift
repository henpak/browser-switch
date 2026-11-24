/// An opaque RGB color of a Brave profile.
public struct ProfileColor: Equatable, Sendable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Fallback for profiles without a color.
    public static let gray = ProfileColor(red: 0x8E, green: 0x8E, blue: 0x93)

    /// Creates a color from a Chromium `SkColor` value as stored in `Local State`: a 32-bit ARGB
    /// integer, written to JSON as a *signed* number (e.g. `-16777216` for opaque black).
    /// Returns `nil` for values outside the 32-bit range. The alpha channel is ignored.
    public init?(skColor value: Int64) {
        guard value >= Int64(Int32.min), value <= Int64(UInt32.max) else { return nil }
        let argb = UInt32(truncatingIfNeeded: value)
        self.init(
            red: UInt8(truncatingIfNeeded: argb >> 16),
            green: UInt8(truncatingIfNeeded: argb >> 8),
            blue: UInt8(truncatingIfNeeded: argb)
        )
    }
}
