#if canImport(AppKit)
import AppKit

/// Modal messages for situations where a link cannot go to the target profile.
@MainActor
enum Alerts {
    /// Brave is not installed. Offers to copy the URL so the link is not lost.
    static func braveMissing(url: URL) {
        let alert = makeAlert(
            title: "Brave nicht gefunden",
            text: "BrowserSwitch leitet Links an Brave weiter, aber Brave ist auf diesem Mac nicht installiert.\n\n\(url.absoluteString)"
        )
        alert.addButton(withTitle: "URL kopieren")
        alert.addButton(withTitle: "Schließen")
        if alert.runModal() == .alertFirstButtonReturn {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(url.absoluteString, forType: .string)
        }
    }

    /// The target profile no longer exists. Returns true if the user wants to open the link in
    /// Brave without choosing a profile.
    static func profileMissing(name: String, url: URL) -> Bool {
        askOpenWithoutProfile(
            title: "Profil „\(name)“ gibt es nicht mehr",
            text: "Das Zielprofil wurde in Brave gelöscht. Wähle im Menü von BrowserSwitch ein anderes Profil.\n\n\(url.absoluteString)"
        )
    }

    /// Brave's profile list cannot be read. Returns true if the user wants to open the link in
    /// Brave without choosing a profile.
    static func profilesUnreadable(url: URL) -> Bool {
        askOpenWithoutProfile(
            title: "Brave-Profile nicht lesbar",
            text: "BrowserSwitch kann die Profilliste von Brave gerade nicht lesen.\n\n\(url.absoluteString)"
        )
    }

    private static func askOpenWithoutProfile(title: String, text: String) -> Bool {
        let alert = makeAlert(title: title, text: text)
        alert.addButton(withTitle: "In Brave öffnen (ohne Profilwahl)")
        alert.addButton(withTitle: "Abbrechen")
        return alert.runModal() == .alertFirstButtonReturn
    }

    private static func makeAlert(title: String, text: String) -> NSAlert {
        // A menu bar app is not active by default; bring the alert to the front.
        NSApp.activate()
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = text
        return alert
    }
}
#endif
