#if canImport(AppKit)
import os

/// Diagnostic log, visible with `log stream --predicate 'subsystem == "io.github.henpak.browserswitch"'`.
/// Never logs full URLs.
enum Log {
    private static let logger = Logger(subsystem: "io.github.henpak.browserswitch", category: "app")

    static func event(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
}
#endif
