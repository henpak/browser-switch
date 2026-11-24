#if canImport(AppKit)
import AppKit

/// Whether BrowserSwitch is the system's default web browser, and a way to make it so.
@MainActor
enum DefaultBrowser {
    static var isDefault: Bool {
        guard let probe = URL(string: "https://example.com"),
              let handler = NSWorkspace.shared.urlForApplication(toOpen: probe) else { return false }
        return Bundle(url: handler)?.bundleIdentifier == Bundle.main.bundleIdentifier
    }

    /// Asks macOS to make this app the handler for http and https. macOS shows its own
    /// confirmation dialog for each request.
    static func makeDefault() {
        let app = Bundle.main.bundleURL
        NSWorkspace.shared.setDefaultApplication(at: app, toOpenURLsWithScheme: "http") { error in
            if let error {
                Log.event("setting default for http failed: \(error.localizedDescription)")
                return
            }
            Task { @MainActor in
                NSWorkspace.shared.setDefaultApplication(at: app, toOpenURLsWithScheme: "https") { error in
                    if let error {
                        Log.event("setting default for https failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
#endif
