import XCTest
@testable import Jab

class UrlTests: XCTestCase {

    func testUrl() throws {
        let jab = Jab()
        let url = try jab.url(string: "http://httpbin.org", queryParams: nil)
        XCTAssertEqual(url.absoluteString, "http://httpbin.org")
    }

    func testEmptyUrl() throws {
        let jab = Jab()
        let url = try jab.url(string: "", queryParams: nil)
        XCTAssertEqual(url.absoluteString, "")
    }

    func testBadUrl() throws {
        let jab = Jab()
        do {
            _ = try jab.url(string: "bad url", queryParams: nil)
            XCTFail()
        } catch JabError.invalidRequest {
            // Pass
        } catch {
            XCTFail()
        }
    }

    func testUrlWithParam() throws {
        let jab = Jab()
        let url = try jab.url(string: "http://httpbin.org", queryParams: ["q": "Jab"])
        XCTAssertEqual(url.absoluteString, "http://httpbin.org?q=Jab")
    }

    func testUrlWithParams() throws {
        let jab = Jab()
        let params = [
            "aaaa": "1",
            "bbbb": "string",
            "cccc": "2.2"
        ]
        let url = try jab.url(string: "http://httpbin.org", queryParams: params)
        XCTAssertTrue(url.absoluteString.contains("aaaa=1") )
        XCTAssertTrue(url.absoluteString.contains("bbbb=string"))
        XCTAssertTrue(url.absoluteString.contains("cccc=2.2"))
    }

    func testUrlWithEmptyParams() throws {
        let jab = Jab()
        let params = [
            "aaaa": "1",
            "bbbb": "string",
            "cccc": ""
        ]
        let url = try jab.url(string: "http://httpbin.org", queryParams: params)
        XCTAssertTrue(url.absoluteString.contains("aaaa=1"))
        XCTAssertTrue(url.absoluteString.contains("bbbb=string"))
        XCTAssertTrue(url.absoluteString.contains("cccc"))
    }

    func testUrlWithInlineParams() throws {
        let jab = Jab()
        let url = try jab.url(string: "http://httpbin.org?aaaa=1&bbbb=string&cccc=2.2",
                              queryParams: nil)
        XCTAssertTrue(url.absoluteString.contains("aaaa=1"))
        XCTAssertTrue(url.absoluteString.contains("bbbb=string"))
        XCTAssertTrue(url.absoluteString.contains("cccc=2.2"))
    }

    func testUrlWithBothInlineAndQueryParams() throws {
        let jab = Jab()
        let params = [
            "aaaa": "1",
            "bbbb": "string",
            "cccc": "2.2"
        ]
        let url = try jab.url(string: "http://httpbin.org?aaaa=1", queryParams: params)
        XCTAssertTrue(url.absoluteString.contains("aaaa=1"))
        XCTAssertEqual(url.absoluteString.components(separatedBy: "aaaa=1").count, 3)
        XCTAssertTrue(url.absoluteString.contains("bbbb=string"))
        XCTAssertTrue(url.absoluteString.contains("cccc=2.2"))
    }

    static var allTests : [(String, (UrlTests) -> () throws -> Void)] {
        return [
            ("testUrl", testUrl),
            ("testEmptyUrl", testEmptyUrl),
            ("testBadUrl", testBadUrl),
            ("testUrlWithParam", testUrlWithParam),
            ("testUrlWithParams", testUrlWithParams),
            ("testUrlWithEmptyParams", testUrlWithEmptyParams),
            ("testUrlWithInlineParams", testUrlWithInlineParams),
            ("testUrlWithBothInlineAndQueryParams", testUrlWithBothInlineAndQueryParams),
        ]
    }
}
