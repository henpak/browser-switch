import Foundation
import XCTest
@testable import BrowserSwitchCore

final class LocalStateParserTests: XCTestCase {
    private func parse(_ json: String) throws -> BraveProfileSnapshot {
        try LocalStateParser.parse(Data(json.utf8))
    }

    func testThreeProfilesInBraveOrder() throws {
        let snapshot = try parse("""
        { "profile": {
            "info_cache": {
              "Profile 2": { "name": "Kunde",  "profile_highlight_color": -16744448 },
              "Default":   { "name": "Privat",         "profile_highlight_color": -65536 },
              "Profile 1": { "name": "Arbeit", "profile_highlight_color": -16776961 }
            },
            "profiles_order": ["Default", "Profile 1", "Profile 2"],
            "last_used": "Profile 1"
        } }
        """)
        XCTAssertEqual(snapshot.profiles.map(\.name), ["Privat", "Arbeit", "Kunde"])
        XCTAssertEqual(snapshot.profiles.map(\.directory), ["Default", "Profile 1", "Profile 2"])
        XCTAssertEqual(snapshot.profiles[0].color, ProfileColor(red: 255, green: 0, blue: 0))
        XCTAssertEqual(snapshot.profiles[1].color, ProfileColor(red: 0, green: 0, blue: 255))
        XCTAssertEqual(snapshot.profiles[2].color, ProfileColor(red: 0, green: 128, blue: 0))
        XCTAssertEqual(snapshot.lastUsedDirectory, "Profile 1")
    }

    func testWithoutProfilesOrderSortsDefaultThenNumerically() throws {
        let snapshot = try parse("""
        { "profile": { "info_cache": {
            "Profile 10": { "name": "Zehn" },
            "Profile 2":  { "name": "Zwei" },
            "Default":    { "name": "Standard" },
            "Guest":      { "name": "Gast" }
        } } }
        """)
        XCTAssertEqual(snapshot.profiles.map(\.directory), ["Default", "Profile 2", "Profile 10", "Guest"])
        XCTAssertNil(snapshot.lastUsedDirectory)
    }

    func testProfilesMissingFromOrderComeLast() throws {
        let snapshot = try parse("""
        { "profile": {
            "info_cache": { "Default": {"name": "A"}, "Profile 1": {"name": "B"}, "Profile 3": {"name": "C"} },
            "profiles_order": ["Profile 1", "Default"]
        } }
        """)
        XCTAssertEqual(snapshot.profiles.map(\.directory), ["Profile 1", "Default", "Profile 3"])
    }

    func testFallbackColorAndName() throws {
        let snapshot = try parse("""
        { "profile": { "info_cache": {
            "Default":   { "name": "Privat", "default_avatar_fill_color": -1 },
            "Profile 1": { "name": "  " },
            "Profile 2": { "name": "Kaputt", "profile_highlight_color": "rot" }
        } } }
        """)
        XCTAssertEqual(snapshot.profiles[0].color, ProfileColor(red: 255, green: 255, blue: 255))
        XCTAssertEqual(snapshot.profiles[1].name, "Profile 1")
        XCTAssertEqual(snapshot.profiles[1].color, .gray)
        XCTAssertEqual(snapshot.profiles[2].color, .gray)
    }

    func testMissingProfileSectionGivesEmptyList() throws {
        let snapshot = try parse(#"{ "browser": {} }"#)
        XCTAssertEqual(snapshot, BraveProfileSnapshot(profiles: [], lastUsedDirectory: nil))
    }

    func testInvalidJSONThrows() {
        XCTAssertThrowsError(try parse("{ not json")) { error in
            XCTAssertEqual(error as? LocalStateParserError, .invalidJSON)
        }
        XCTAssertThrowsError(try parse("[1, 2]"))
    }
}
