import Foundation
import XCTest
@testable import BrowserSwitchCore

final class BraveProfileSourceTests: XCTestCase {
    private var dir: URL!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: dir)
    }

    func testDefaultPath() {
        let url = BraveProfileSource.defaultLocalStateURL(home: URL(fileURLWithPath: "/Users/alice"))
        XCTAssertEqual(url.path, "/Users/alice/Library/Application Support/BraveSoftware/Brave-Browser/Local State")
    }

    func testNotFound() {
        let source = BraveProfileSource(localStateURL: dir.appendingPathComponent("Local State"))
        XCTAssertEqual(source.load(retryDelay: 0), .failure(.notFound))
    }

    func testUnreadable() throws {
        let file = dir.appendingPathComponent("Local State")
        try Data("{ broken".utf8).write(to: file)
        XCTAssertEqual(BraveProfileSource(localStateURL: file).load(retryDelay: 0), .failure(.unreadable))
    }

    func testLoads() throws {
        let file = dir.appendingPathComponent("Local State")
        try Data(#"{"profile":{"info_cache":{"Default":{"name":"Privat"}},"last_used":"Default"}}"#.utf8).write(to: file)
        let result = BraveProfileSource(localStateURL: file).load(retryDelay: 0)
        XCTAssertEqual(try result.get().profiles.map(\.name), ["Privat"])
    }

    func testReadsChangesWithoutRestart() throws {
        let file = dir.appendingPathComponent("Local State")
        let source = BraveProfileSource(localStateURL: file)
        try Data(#"{"profile":{"info_cache":{"Default":{"name":"Privat"}}}}"#.utf8).write(to: file)
        XCTAssertEqual(try source.load(retryDelay: 0).get().profiles.count, 1)
        try Data(#"{"profile":{"info_cache":{"Default":{"name":"Privat"},"Profile 1":{"name":"Test"}}}}"#.utf8).write(to: file)
        XCTAssertEqual(try source.load(retryDelay: 0).get().profiles.map(\.name), ["Privat", "Test"])
    }
}
