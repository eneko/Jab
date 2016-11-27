import XCTest
@testable import Jab

class SerializationTests: XCTestCase {

    func testPayload() throws {
        let payload = ["Hello": "world"]
        let jab = Jab()
        try jab.makeRequest(method: .post, url: "", queryParams: nil)
        try jab.set(payload: payload)
        XCTAssertNotNil(jab.request?.httpBody)
    }

    func testInvalidPayload() throws {
        let payload = Data(bytes: [0, 1, 2, 3])
        let jab = Jab()
        try jab.makeRequest(method: .post, url: "", queryParams: nil)
        do {
            try jab.set(payload: payload)
            XCTFail()
        } catch JabError.serialization {
            XCTAssertNil(jab.request?.httpBody)
        } catch {
            XCTFail()
        }
    }

    static var allTests : [(String, (SerializationTests) -> () throws -> Void)] {
        return [
            ("testPayload", testPayload),
            ("testInvalidPayload", testInvalidPayload),
        ]
    }
}
