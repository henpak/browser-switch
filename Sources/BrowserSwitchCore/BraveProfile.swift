/// A Brave browser profile as listed in Brave's `Local State`.
public struct BraveProfile: Equatable, Sendable {
    /// Stable identifier: the profile's directory name, e.g. `Default` or `Profile 1`.
    public let directory: String
    /// Display name as shown in Brave, e.g. `Arbeit`. Can change when the user renames the profile.
    public let name: String
    /// Profile color, or a neutral gray if Brave stores none.
    public let color: ProfileColor

    public init(directory: String, name: String, color: ProfileColor) {
        self.directory = directory
        self.name = name
        self.color = color
    }
}

/// Everything BrowserSwitch reads from Brave's `Local State` at one point in time.
public struct BraveProfileSnapshot: Equatable, Sendable {
    /// Profiles in Brave's order.
    public let profiles: [BraveProfile]
    /// Directory of the profile Brave used last, if known.
    public let lastUsedDirectory: String?

    public init(profiles: [BraveProfile], lastUsedDirectory: String?) {
        self.profiles = profiles
        self.lastUsedDirectory = lastUsedDirectory
    }

    public func profile(directory: String) -> BraveProfile? {
        profiles.first { $0.directory == directory }
    }
}
