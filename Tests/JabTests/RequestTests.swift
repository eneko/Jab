import XCTest
@testable import Jab

class RequestTests: XCTestCase {

    func testNilRequest() {
        let jab = Jab()
        XCTAssertNil(jab.request)
    }

    func testNotNilRequest() throws {
        let jab = Jab()
        try jab.makeRequest(method: .get, url: "", queryParams: nil)
        XCTAssertNotNil(jab.request)
        XCTAssertEqual(jab.request?.httpMethod, "GET")
    }

    func testUpdateRequestHeaders() throws {
        let headers = ["User-Agent": "XCTest"]
        let jab = Jab()
        try jab.makeRequest(method: .get, url: "http://httpbin.org/get", queryParams: nil)
        jab.set(headers: headers)
        XCTAssertEqual(jab.request?.allHTTPHeaderFields?["User-Agent"], "XCTest")
    }

    func testNoRequest() {
        let jab = Jab()
        do {
            try jab.send {}
            XCTFail()
        } catch JabError.invalidRequest {
            // Pass
        } catch {
            XCTFail()
        }
    }

    static var allTests : [(String, (RequestTests) -> () throws -> Void)] {
        return [
            ("testNilRequest", testNilRequest),
            ("testNotNilRequest", testNotNilRequest),
            ("testUpdateRequestHeaders", testUpdateRequestHeaders),
        ]
    }
}
