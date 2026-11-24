import Foundation
import XCTest
@testable import BrowserSwitchCore

final class LaunchArgumentsTests: XCTestCase {
    func testHTTPS() throws {
        let url = URL(string: "https://contoso.sharepoint.com/sites/HR/Doc.aspx?x=1#top")!
        XCTAssertEqual(try LaunchArguments.arguments(profileDirectory: "Profile 1", url: url),
                       ["--profile-directory=Profile 1", "https://contoso.sharepoint.com/sites/HR/Doc.aspx?x=1#top"])
    }

    func testDirectoryWithSpacesStaysOneArgument() throws {
        let args = try LaunchArguments.arguments(profileDirectory: "Profile 12", url: URL(string: "http://example.com")!)
        XCTAssertEqual(args.count, 2)
        XCTAssertEqual(args[0], "--profile-directory=Profile 12")
    }

    func testFileURL() throws {
        let url = URL(fileURLWithPath: "/tmp/test page.html")
        let args = try LaunchArguments.arguments(profileDirectory: "Default", url: url)
        XCTAssertEqual(args[1], "file:///tmp/test%20page.html")
    }

    func testUppercaseSchemeAccepted() {
        XCTAssertTrue(LaunchArguments.isSupported(URL(string: "HTTPS://example.com")!))
    }

    func testRejectsOtherSchemes() {
        for string in ["mailto:a@b.de", "ftp://example.com", "javascript:alert(1)"] {
            XCTAssertThrowsError(try LaunchArguments.arguments(profileDirectory: "Default", url: URL(string: string)!))
        }
    }

    func testRejectsEmptyDirectory() {
        XCTAssertThrowsError(try LaunchArguments.arguments(profileDirectory: "", url: URL(string: "https://a.de")!)) {
            XCTAssertEqual($0 as? LaunchArgumentsError, .emptyProfileDirectory)
        }
    }
}
