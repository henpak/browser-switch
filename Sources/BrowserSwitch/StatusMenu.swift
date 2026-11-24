#if canImport(AppKit)
import AppKit
import BrowserSwitchCore

/// The menu bar icon and its menu: choose the target profile, default browser status, quit.
/// The menu is rebuilt every time it opens, so new, renamed or deleted Brave profiles show up
/// without restarting the app.
@MainActor
final class StatusMenu: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    private let profileSource: BraveProfileSource
    private let targetStore: TargetStore

    init(profileSource: BraveProfileSource, targetStore: TargetStore) {
        self.profileSource = profileSource
        self.targetStore = targetStore
        super.init()

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "arrow.triangle.branch", accessibilityDescription: "BrowserSwitch")
            image?.isTemplate = true
            button.image = image
            button.toolTip = "BrowserSwitch"
        }
        menu.autoenablesItems = false
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuild()
    }

    private func rebuild() {
        menu.removeAllItems()
        menu.addItem(disabledItem("Alle Links öffnen in:"))

        switch profileSource.load() {
        case .failure(.notFound):
            menu.addItem(disabledItem("Brave nicht gefunden"))
        case .failure(.unreadable):
            menu.addItem(disabledItem("Brave-Profile nicht lesbar"))
        case .success(let snapshot):
            let resolution = TargetResolver.resolve(stored: targetStore.target, snapshot: snapshot)
            if case .missing(let target) = resolution {
                menu.addItem(disabledItem("Zielprofil fehlt: \(target.name)"))
            }
            if snapshot.profiles.isEmpty {
                menu.addItem(disabledItem("Keine Brave-Profile"))
            }
            for profile in snapshot.profiles {
                let item = NSMenuItem(title: profile.name, action: #selector(selectProfile(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = profile.directory
                item.image = Self.dot(profile.color)
                if case .profile(let target) = resolution, target.directory == profile.directory {
                    item.state = .on
                }
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())
        if DefaultBrowser.isDefault {
            let item = disabledItem("Ist Standardbrowser")
            item.state = .on
            menu.addItem(item)
        } else {
            let item = NSMenuItem(title: "Als Standardbrowser festlegen …", action: #selector(makeDefault), keyEquivalent: "")
            item.target = self
            menu.addItem(item)
        }

        menu.addItem(.separator())
        let quit = NSMenuItem(title: "BrowserSwitch beenden", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)
    }

    @objc private func selectProfile(_ sender: NSMenuItem) {
        guard let directory = sender.representedObject as? String,
              case .success(let snapshot) = profileSource.load(),
              let profile = snapshot.profile(directory: directory) else { return }
        targetStore.target = StoredTarget(profile)
        Log.event("target profile set to \(profile.directory)")
    }

    @objc private func makeDefault() {
        DefaultBrowser.makeDefault()
    }

    private func disabledItem(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private static func dot(_ color: ProfileColor) -> NSImage {
        let nsColor = NSColor(
            srgbRed: CGFloat(color.red) / 255, green: CGFloat(color.green) / 255,
            blue: CGFloat(color.blue) / 255, alpha: 1
        )
        return NSImage(size: NSSize(width: 12, height: 12), flipped: false) { rect in
            nsColor.setFill()
            NSBezierPath(ovalIn: rect.insetBy(dx: 1, dy: 1)).fill()
            return true
        }
    }
}
#endif
