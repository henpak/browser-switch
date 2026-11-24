import XCTest
@testable import BrowserSwitchCore

final class TargetResolverTests: XCTestCase {
    private let privat = BraveProfile(directory: "Default", name: "Privat", color: .gray)
    private let arbeit = BraveProfile(directory: "Profile 1", name: "Arbeit", color: .gray)
    private let kunde = BraveProfile(directory: "Profile 2", name: "Kunde", color: .gray)

    private func snapshot(_ profiles: [BraveProfile], lastUsed: String? = nil) -> BraveProfileSnapshot {
        BraveProfileSnapshot(profiles: profiles, lastUsedDirectory: lastUsed)
    }

    func testStoredTargetExists() {
        let result = TargetResolver.resolve(stored: StoredTarget(arbeit), snapshot: snapshot([privat, arbeit], lastUsed: "Default"))
        XCTAssertEqual(result, .profile(arbeit))
    }

    func testStoredTargetRenamedStillMatchesByDirectory() {
        let renamed = BraveProfile(directory: "Profile 1", name: "Arbeit GmbH", color: .gray)
        let result = TargetResolver.resolve(stored: StoredTarget(arbeit), snapshot: snapshot([privat, renamed]))
        XCTAssertEqual(result, .profile(renamed))
    }

    func testStoredTargetMissingIsNotReplaced() {
        let result = TargetResolver.resolve(stored: StoredTarget(arbeit), snapshot: snapshot([privat, kunde], lastUsed: "Default"))
        XCTAssertEqual(result, .missing(StoredTarget(directory: "Profile 1", name: "Arbeit")))
    }

    func testNothingStoredUsesLastUsed() {
        let result = TargetResolver.resolve(stored: nil, snapshot: snapshot([privat, arbeit, kunde], lastUsed: "Profile 2"))
        XCTAssertEqual(result, .profile(kunde))
    }

    func testNothingStoredLastUsedGoneFallsBackToDefault() {
        let result = TargetResolver.resolve(stored: nil, snapshot: snapshot([arbeit, privat], lastUsed: "Profile 9"))
        XCTAssertEqual(result, .profile(privat))
    }

    func testNothingStoredNoDefaultUsesFirst() {
        let result = TargetResolver.resolve(stored: nil, snapshot: snapshot([arbeit, kunde]))
        XCTAssertEqual(result, .profile(arbeit))
    }

    func testNoProfiles() {
        XCTAssertEqual(TargetResolver.resolve(stored: nil, snapshot: snapshot([])), .none)
    }
}
