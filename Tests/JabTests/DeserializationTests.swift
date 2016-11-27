import XCTest
@testable import Jab

class DeserializationTests: XCTestCase {

    func testNoResponse() throws {
        let jab = Jab()
        do {
            _ = try jab.parseResponse()
            XCTFail()
        } catch JabError.noResponse {
            // Pass
        } catch {
            XCTFail()
        }
    }

    func testNoResponseWithData() {
        let jab = Jab()
        jab.responseData = Data()
        do {
            _ = try jab.parseResponse()
            XCTFail()
        } catch JabError.noResponse {
            // Pass
        } catch {
            XCTFail()
        }
    }

    func testResponseWithNoData() throws {
        let jab = Jab()
        jab.response = HTTPURLResponse(url: URL(string: "http://httpbin.org")!,
                                       statusCode: 200, httpVersion: nil, headerFields: nil)
        _ = try jab.parseResponse()
    }

    func testResponseWithInvalidJSON() {
        let jab = Jab()
        jab.response = HTTPURLResponse(url: URL(string: "http://httpbin.org")!,
                                       statusCode: 200, httpVersion: nil, headerFields: nil)
        jab.responseData = Data(bytes: [0,1,2,3,4])
        do {
            _ = try jab.parseResponse()
            XCTFail()
        } catch JabError.deserialization {
            // Pass
        } catch {
            XCTFail()
        }
    }

    static var allTests : [(String, (DeserializationTests) -> () throws -> Void)] {
        return [
            ("testNoResponse", testNoResponse),
            ("testNoResponseWithData", testNoResponseWithData),
            ("testResponseWithNoData", testResponseWithNoData),
            ("testResponseWithInvalidJSON", testResponseWithInvalidJSON),
        ]
    }

}
