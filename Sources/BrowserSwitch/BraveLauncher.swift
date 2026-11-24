#if canImport(AppKit)
import AppKit
import BrowserSwitchCore

/// Hands URLs to Brave, optionally in a specific profile.
@MainActor
final class BraveLauncher {
    static let bundleIdentifier = "com.brave.Browser"

    private var braveAppURL: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: Self.bundleIdentifier)
    }

    var isBraveInstalled: Bool { braveAppURL != nil }

    /// Opens `url` in `profile`.
    ///
    /// Starts a *new* Brave process with `--profile-directory`. If Brave is already running, that
    /// process hands its command line to the running instance (Chromium process singleton) and
    /// exits; the running instance opens the URL in the requested profile. Same as
    /// `open -na "Brave Browser" --args --profile-directory=<dir> <url>`.
    func open(_ url: URL, in profile: BraveProfile) {
        guard let app = braveAppURL else { return }
        let arguments: [String]
        do {
            arguments = try LaunchArguments.arguments(profileDirectory: profile.directory, url: url)
        } catch {
            Log.event("cannot build launch arguments: \(error)")
            return
        }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        configuration.arguments = arguments
        configuration.activates = true
        Log.event("open in profile \(profile.directory)")
        NSWorkspace.shared.openApplication(at: app, configuration: configuration) { _, error in
            if let error {
                Log.event("launching Brave failed: \(error.localizedDescription)")
            }
        }
    }

    /// Opens `url` in Brave without choosing a profile (Brave uses its last active profile).
    func openWithoutProfile(_ url: URL) {
        guard let app = braveAppURL else { return }
        Log.event("open without profile")
        NSWorkspace.shared.open([url], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration()) { _, error in
            if let error {
                Log.event("opening in Brave failed: \(error.localizedDescription)")
            }
        }
    }
}
#endif
