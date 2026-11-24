import Foundation

public enum BraveProfileSourceError: Error, Equatable {
    /// Brave's `Local State` does not exist (Brave not installed or never started).
    case notFound
    /// The file exists but cannot be read or parsed.
    case unreadable
}

/// Loads the current Brave profiles from disk. Reads only; never writes to Brave's files.
public struct BraveProfileSource: Sendable {
    public let localStateURL: URL

    public init(localStateURL: URL) {
        self.localStateURL = localStateURL
    }

    /// `~/Library/Application Support/BraveSoftware/Brave-Browser/Local State`
    public static func defaultLocalStateURL(home: URL) -> URL {
        home.appendingPathComponent("Library/Application Support/BraveSoftware/Brave-Browser/Local State")
    }

    /// Reads and parses `Local State`. A failed parse is retried once after a short pause, in case
    /// the file was caught mid-write.
    public func load(retryDelay: TimeInterval = 0.05) -> Result<BraveProfileSnapshot, BraveProfileSourceError> {
        guard FileManager.default.fileExists(atPath: localStateURL.path) else {
            return .failure(.notFound)
        }
        if let snapshot = readOnce() { return .success(snapshot) }
        Thread.sleep(forTimeInterval: retryDelay)
        if let snapshot = readOnce() { return .success(snapshot) }
        return .failure(.unreadable)
    }

    private func readOnce() -> BraveProfileSnapshot? {
        guard let data = try? Data(contentsOf: localStateURL) else { return nil }
        return try? LocalStateParser.parse(data)
    }
}
