// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BrowserSwitch",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "BrowserSwitch", targets: ["BrowserSwitch"]),
    ],
    targets: [
        // Pure, AppKit-free logic (Brave profiles, target resolution, launch arguments) – unit tested,
        // also on Linux.
        .target(name: "BrowserSwitchCore"),
        // The menu bar app itself (AppKit). Compiles to a stub on platforms without AppKit.
        .executableTarget(name: "BrowserSwitch", dependencies: ["BrowserSwitchCore"]),
        .testTarget(name: "BrowserSwitchCoreTests", dependencies: ["BrowserSwitchCore"]),
    ],
    swiftLanguageModes: [.v5]
)
