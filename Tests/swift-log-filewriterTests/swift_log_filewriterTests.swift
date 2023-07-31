import XCTest
@testable import swift_log_filewriter

final class swift_log_filewriterTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(swift_log_filewriter().text, "Hello, World!")
    }
}
