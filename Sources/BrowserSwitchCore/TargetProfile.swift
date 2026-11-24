/// The target profile as stored by BrowserSwitch. The directory identifies the profile; the name is
/// only kept to explain a missing profile to the user.
public struct StoredTarget: Equatable, Sendable {
    public let directory: String
    public let name: String

    public init(directory: String, name: String) {
        self.directory = directory
        self.name = name
    }

    public init(_ profile: BraveProfile) {
        self.init(directory: profile.directory, name: profile.name)
    }
}

public enum TargetResolution: Equatable, Sendable {
    /// Links go to this profile.
    case profile(BraveProfile)
    /// The stored target no longer exists in Brave. No other profile is substituted.
    case missing(StoredTarget)
    /// Brave has no profiles at all.
    case none
}

public enum TargetResolver {
    /// Resolves which profile links go to.
    ///
    /// - With a stored target: that profile if it still exists, otherwise `.missing`.
    /// - Without one: Brave's last used profile, else `Default`, else the first profile, else `.none`.
    public static func resolve(stored: StoredTarget?, snapshot: BraveProfileSnapshot) -> TargetResolution {
        if let stored {
            if let profile = snapshot.profile(directory: stored.directory) {
                return .profile(profile)
            }
            return .missing(stored)
        }
        if let lastUsed = snapshot.lastUsedDirectory, let profile = snapshot.profile(directory: lastUsed) {
            return .profile(profile)
        }
        if let profile = snapshot.profile(directory: "Default") ?? snapshot.profiles.first {
            return .profile(profile)
        }
        return .none
    }
}
