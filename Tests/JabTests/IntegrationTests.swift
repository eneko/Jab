import XCTest

/// Integration tests import Jab module as an application would do to test access to public methods.
import Jab

class IntegrationTests: XCTestCase {

    let badUrl = "http://httpbinxxxxxxxxx.org/"
    let getUrl = "http://httpbin.org/get"
    let postUrl = "http://httpbin.org/post"
    let patchUrl = "http://httpbin.org/patch"
    let putUrl = "http://httpbin.org/put"
    let deleteUrl = "http://httpbin.org/delete"

    let params = ["jab": "is awesome ++ & cool"]
    let payload: [String: Any] = ["something": "to serialize", "with": 123, "and": true]

    func testCreate() {
        let jab = Jab()
        XCTAssertNil(jab.request)
        XCTAssertNil(jab.response)
        XCTAssertNil(jab.responseData)
        XCTAssertNil(jab.responseError)
    }

    func testBadUrl() {
        let jab = Jab()
        do {
            _ = try jab.send(method: .get, url: badUrl, queryParams: params)
            XCTFail()
        } catch JabError.requestFailed(let error) {
            XCTAssertTrue(error.localizedDescription.characters.count > 0)
        } catch JabError.deserialization {
            // Pass for Charles proxy testing
            XCTAssertEqual(jab.response?.statusCode, 503)
        } catch {
            XCTFail()
        }
    }

    func testGet() throws {
        let jab = Jab()
        let result = try jab.get(url: getUrl, queryParams: params) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertEqual(jab.request?.httpMethod, "GET")
        XCTAssertNotNil(result?["args"])
        XCTAssertEqual((result?["args"] as? [String: Any])?["jab"] as? String,
                       "is awesome    & cool")
    }

    func testPost() throws {
        let jab = Jab()
        let result = try jab.post(url: postUrl, queryParams: params,
                                  payload: payload) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertEqual(jab.request?.httpMethod, "POST")
        XCTAssertNotNil(result?["args"])
        XCTAssertEqual((result?["args"] as? [String: Any])?["jab"] as? String,
                       "is awesome    & cool")
        XCTAssertNotNil(result?["json"])
        XCTAssertEqual((result?["json"] as? [String: Any])?["something"] as? String, "to serialize")
        XCTAssertEqual((result?["json"] as? [String: Any])?["with"] as? Int, 123)
        XCTAssertEqual((result?["json"] as? [String: Any])?["and"] as? Bool, true)
    }

    func testPatch() throws {
        let jab = Jab()
        let result = try jab.patch(url: patchUrl, queryParams: params,
                                   payload: payload) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertEqual(jab.request?.httpMethod, "PATCH")
        XCTAssertNotNil(result?["args"])
        XCTAssertEqual((result?["args"] as? [String: Any])?["jab"] as? String,
                       "is awesome    & cool")
        XCTAssertNotNil(result?["json"])
        XCTAssertEqual((result?["json"] as? [String: Any])?["something"] as? String, "to serialize")
        XCTAssertEqual((result?["json"] as? [String: Any])?["with"] as? Int, 123)
        XCTAssertEqual((result?["json"] as? [String: Any])?["and"] as? Bool, true)
    }

    func testPut() throws {
        let jab = Jab()
        let result = try jab.put(url: putUrl, queryParams: params,
                                 payload: payload) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertEqual(jab.request?.httpMethod, "PUT")
        XCTAssertNotNil(result?["args"])
        XCTAssertEqual((result?["args"] as? [String: Any])?["jab"] as? String,
                       "is awesome    & cool")
        XCTAssertNotNil(result?["json"])
        XCTAssertEqual((result?["json"] as? [String: Any])?["something"] as? String, "to serialize")
        XCTAssertEqual((result?["json"] as? [String: Any])?["with"] as? Int, 123)
        XCTAssertEqual((result?["json"] as? [String: Any])?["and"] as? Bool, true)
    }

    func testDelete() throws {
        let jab = Jab()
        let result = try jab.delete(url: deleteUrl, queryParams: params,
                                    payload: payload) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertEqual(jab.request?.httpMethod, "DELETE")
        XCTAssertNotNil(result?["args"])
        XCTAssertEqual((result?["args"] as? [String: Any])?["jab"] as? String,
                       "is awesome    & cool")
        XCTAssertNotNil(result?["json"])
        XCTAssertEqual((result?["json"] as? [String: Any])?["something"] as? String, "to serialize")
        XCTAssertEqual((result?["json"] as? [String: Any])?["with"] as? Int, 123)
        XCTAssertEqual((result?["json"] as? [String: Any])?["and"] as? Bool, true)
    }

    func testHead() throws {
        let jab = Jab()
        let result = try jab.head(url: getUrl, queryParams: params) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertEqual(jab.request?.httpMethod, "HEAD")
        XCTAssertNil(result)
        XCTAssertEqual(jab.responseData?.count, 0)
    }

    func testHeaders() throws {
        let jab = Jab()
        let headers = ["Custom": "Header"]
        let result = try jab.send(method: .get, url: getUrl, queryParams: params,
                                  headers: headers) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertNotNil(result?["headers"])
        XCTAssertEqual((result?["headers"] as? [String: Any])?["Custom"] as? String, "Header")
    }

    func testUserAgent() throws {
        Jab.userAgent = "Awesome User Agent"
        let jab = Jab()
        let result = try jab.send(method: .get, url: getUrl, queryParams: params) as? [String: Any]
        shouldHaveResponse(jab: jab)
        XCTAssertNotNil(result?["headers"])
        XCTAssertEqual((result?["headers"] as? [String: Any])?["User-Agent"] as? String,
                       "Awesome User Agent")
    }

    // MARK: Test Helpers

    func shouldHaveResponse(jab: Jab) {
        XCTAssertNotNil(jab.request)
        XCTAssertNotNil(jab.response)
        XCTAssertEqual(jab.response?.statusCode, 200)
        XCTAssertNotNil(jab.responseData)
        XCTAssertNil(jab.responseError)
    }

    static var allTests : [(String, (IntegrationTests) -> () throws -> Void)] {
        return [
            ("testCreate", testCreate),
            ("testBadUrl", testBadUrl),
            ("testGet", testGet),
            ("testPost", testPost),
            ("testPatch", testPatch),
            ("testPut", testPut),
            ("testDelete", testDelete),
            ("testHead", testHead),
            ("testHeaders", testHeaders),
            ("testUserAgent", testUserAgent),
        ]
    }
}
