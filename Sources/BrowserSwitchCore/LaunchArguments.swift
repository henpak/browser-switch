import Foundation

public enum LaunchArgumentsError: Error, Equatable {
    case unsupportedScheme(String?)
    case emptyProfileDirectory
}

/// Builds the command line arguments that make Brave open a URL in a specific profile.
public enum LaunchArguments {
    /// URL schemes BrowserSwitch accepts and forwards.
    public static let supportedSchemes: Set<String> = ["http", "https", "file"]

    public static func isSupported(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        return supportedSchemes.contains(scheme)
    }

    /// `["--profile-directory=<directory>", "<url>"]`
    ///
    /// The URL always starts with its scheme, so Brave can never mistake it for a switch.
    public static func arguments(profileDirectory: String, url: URL) throws -> [String] {
        guard isSupported(url) else { throw LaunchArgumentsError.unsupportedScheme(url.scheme) }
        guard !profileDirectory.isEmpty else { throw LaunchArgumentsError.emptyProfileDirectory }
        return ["--profile-directory=\(profileDirectory)", url.absoluteString]
    }
}
