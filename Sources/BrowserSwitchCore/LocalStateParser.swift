import Foundation

public enum LocalStateParserError: Error, Equatable {
    /// The data is not a JSON object.
    case invalidJSON
}

/// Reads the profile list from the contents of Brave's `Local State` file.
///
/// Relevant structure (Chromium):
/// ```json
/// { "profile": {
///     "info_cache": { "Default": { "name": "Privat", "profile_highlight_color": -3355444 }, ... },
///     "profiles_order": ["Default", "Profile 1"],
///     "last_used": "Profile 1" } }
/// ```
/// Missing fields are tolerated; profiles without a name are listed under their directory name.
public enum LocalStateParser {
    public static func parse(_ data: Data) throws -> BraveProfileSnapshot {
        guard let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            throw LocalStateParserError.invalidJSON
        }
        let profileSection = root["profile"] as? [String: Any] ?? [:]
        let infoCache = profileSection["info_cache"] as? [String: Any] ?? [:]

        var profiles: [BraveProfile] = []
        for (directory, value) in infoCache {
            let info = value as? [String: Any] ?? [:]
            let rawName = (info["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let color = color(from: info["profile_highlight_color"])
                ?? color(from: info["default_avatar_fill_color"])
                ?? .gray
            profiles.append(BraveProfile(directory: directory, name: rawName.isEmpty ? directory : rawName, color: color))
        }

        let order = (profileSection["profiles_order"] as? [Any])?.compactMap { $0 as? String } ?? []
        profiles.sort { lhs, rhs in
            let l = order.firstIndex(of: lhs.directory) ?? Int.max
            let r = order.firstIndex(of: rhs.directory) ?? Int.max
            if l != r { return l < r }
            return directoryRank(lhs.directory) < directoryRank(rhs.directory)
        }

        let lastUsed = (profileSection["last_used"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        return BraveProfileSnapshot(profiles: profiles, lastUsedDirectory: lastUsed)
    }

    private static func color(from value: Any?) -> ProfileColor? {
        // JSONSerialization yields NSNumber; integral values bridge to Int64.
        guard let number = value as? NSNumber else { return nil }
        let double = number.doubleValue
        guard double.rounded() == double, abs(double) < 1e12 else { return nil }
        return ProfileColor(skColor: number.int64Value)
    }

    /// `Default` first, then `Profile N` by number, then everything else alphabetically.
    private static func directoryRank(_ directory: String) -> (Int, Int, String) {
        if directory == "Default" { return (0, 0, directory) }
        if directory.hasPrefix("Profile "), let n = Int(directory.dropFirst("Profile ".count)) {
            return (1, n, directory)
        }
        return (2, 0, directory)
    }
}
