#if canImport(AppKit)
import AppKit
import BrowserSwitchCore

@main
enum BrowserSwitchApp {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        // Menu bar only: no Dock icon, no main window (also set via LSUIElement in Info.plist,
        // this line makes `swift run` behave the same).
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) {
            app.run()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let profileSource = BraveProfileSource(
        localStateURL: BraveProfileSource.defaultLocalStateURL(home: FileManager.default.homeDirectoryForCurrentUser)
    )
    private let targetStore = TargetStore()
    private let launcher = BraveLauncher()
    private var statusMenu: StatusMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusMenu = StatusMenu(profileSource: profileSource, targetStore: targetStore)
    }

    /// macOS delivers links (http/https) and files (HTML) opened with BrowserSwitch here.
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            guard LaunchArguments.isSupported(url) else {
                Log.event("ignored unsupported URL scheme: \(url.scheme ?? "-")")
                continue
            }
            route(url)
        }
    }

    private func route(_ url: URL) {
        guard launcher.isBraveInstalled else {
            Alerts.braveMissing(url: url)
            return
        }

        switch profileSource.load() {
        case .failure(.notFound):
            // Brave is installed but has never been started: there are no profiles to choose from.
            launcher.openWithoutProfile(url)
        case .failure(.unreadable):
            if Alerts.profilesUnreadable(url: url) {
                launcher.openWithoutProfile(url)
            }
        case .success(let snapshot):
            switch TargetResolver.resolve(stored: targetStore.target, snapshot: snapshot) {
            case .profile(let profile):
                launcher.open(url, in: profile)
            case .missing(let target):
                if Alerts.profileMissing(name: target.name, url: url) {
                    launcher.openWithoutProfile(url)
                }
            case .none:
                launcher.openWithoutProfile(url)
            }
        }
    }
}

#else

@main
enum BrowserSwitchApp {
    static func main() {
        print("BrowserSwitch runs on macOS only.")
    }
}

#endif
