#if canImport(AppKit)
import Foundation
import BrowserSwitchCore

/// Persists the target profile in UserDefaults (directory = identity, name = for messages only).
@MainActor
final class TargetStore {
    private enum Key {
        static let directory = "targetProfileDirectory"
        static let name = "targetProfileName"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var target: StoredTarget? {
        get {
            guard let directory = defaults.string(forKey: Key.directory), !directory.isEmpty else { return nil }
            return StoredTarget(directory: directory, name: defaults.string(forKey: Key.name) ?? directory)
        }
        set {
            if let newValue {
                defaults.set(newValue.directory, forKey: Key.directory)
                defaults.set(newValue.name, forKey: Key.name)
            } else {
                defaults.removeObject(forKey: Key.directory)
                defaults.removeObject(forKey: Key.name)
            }
        }
    }
}
#endif
