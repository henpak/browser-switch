import XCTest
@testable import BrowserSwitchCore

final class ProfileColorTests: XCTestCase {
    func testSignedARGB() {
        // 0xFF336699 stored as signed Int32
        XCTAssertEqual(ProfileColor(skColor: Int64(Int32(bitPattern: 0xFF33_6699))),
                       ProfileColor(red: 0x33, green: 0x66, blue: 0x99))
    }

    func testUnsignedARGB() {
        XCTAssertEqual(ProfileColor(skColor: 0xFF33_6699), ProfileColor(red: 0x33, green: 0x66, blue: 0x99))
    }

    func testZeroIsBlack() {
        XCTAssertEqual(ProfileColor(skColor: 0), ProfileColor(red: 0, green: 0, blue: 0))
    }

    func testOutOfRange() {
        XCTAssertNil(ProfileColor(skColor: Int64(UInt32.max) + 1))
        XCTAssertNil(ProfileColor(skColor: Int64(Int32.min) - 1))
    }
}
