import XCTest
@testable import BrowserSwitchCore

final class TargetResolverTests: XCTestCase {
    private let privat = BraveProfile(directory: "Default", name: "Privat", color: .gray)
    private let Arbeit = BraveProfile(directory: "Profile 1", name: "Arbeit", color: .gray)
    private let kunde = BraveProfile(directory: "Profile 2", name: "Kunde", color: .gray)

    private func snapshot(_ profiles: [BraveProfile], lastUsed: String? = nil) -> BraveProfileSnapshot {
        BraveProfileSnapshot(profiles: profiles, lastUsedDirectory: lastUsed)
    }

    func testStoredTargetExists() {
        let result = TargetResolver.resolve(stored: StoredTarget(Arbeit), snapshot: snapshot([privat, Arbeit], lastUsed: "Default"))
        XCTAssertEqual(result, .profile(Arbeit))
    }

    func testStoredTargetRenamedStillMatchesByDirectory() {
        let renamed = BraveProfile(directory: "Profile 1", name: "Arbeit GmbH", color: .gray)
        let result = TargetResolver.resolve(stored: StoredTarget(Arbeit), snapshot: snapshot([privat, renamed]))
        XCTAssertEqual(result, .profile(renamed))
    }

    func testStoredTargetMissingIsNotReplaced() {
        let result = TargetResolver.resolve(stored: StoredTarget(Arbeit), snapshot: snapshot([privat, kunde], lastUsed: "Default"))
        XCTAssertEqual(result, .missing(StoredTarget(directory: "Profile 1", name: "Arbeit")))
    }

    func testNothingStoredUsesLastUsed() {
        let result = TargetResolver.resolve(stored: nil, snapshot: snapshot([privat, Arbeit, kunde], lastUsed: "Profile 2"))
        XCTAssertEqual(result, .profile(kunde))
    }

    func testNothingStoredLastUsedGoneFallsBackToDefault() {
        let result = TargetResolver.resolve(stored: nil, snapshot: snapshot([Arbeit, privat], lastUsed: "Profile 9"))
        XCTAssertEqual(result, .profile(privat))
    }

    func testNothingStoredNoDefaultUsesFirst() {
        let result = TargetResolver.resolve(stored: nil, snapshot: snapshot([Arbeit, kunde]))
        XCTAssertEqual(result, .profile(Arbeit))
    }

    func testNoProfiles() {
        XCTAssertEqual(TargetResolver.resolve(stored: nil, snapshot: snapshot([])), .none)
    }
}
