import Foundation
import SystemConfiguration

open class Jab {

    public static var userAgent: String?
    public static var connectionTimeout = 30.0
    public static var completionTimeout = 60.0

    public var request: URLRequest?
    public var response: HTTPURLResponse?
    public var responseData: Data?
    public var responseError: Error?

    public init() {}

    public func send(method: JabVerb, url: String, queryParams: [String: String]? = nil,
                     payload: Any? = nil, headers: [String: String]? = nil) throws -> Any? {
        guard isNetworkReachable else {
            throw JabError.offline
        }

        try makeRequest(method: method, url: url, queryParams: queryParams)
        set(headers: headers)
        try set(payload: payload)

        let semaphore = DispatchSemaphore(value: 0)
        try send {
            semaphore.signal()
        }
        while semaphore.wait(timeout: DispatchTime.now()) == .timedOut {
            let intervalDate = Date(timeIntervalSinceNow: 0.01) // 10 milliseconds
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: intervalDate)
        }

        return try parseResponse()
    }

    func send(complete: @escaping () -> Void) throws {
        guard let request = self.request else {
            throw JabError.invalidRequest
        }
        let session = makeSession()
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            self?.responseData = data
            self?.response = response as? HTTPURLResponse
            self?.responseError = error
            complete()
        }
        task.resume()
    }

    func makeRequest(method: JabVerb, url: String, queryParams: [String: String]?) throws {
        let url = try self.url(string: url, queryParams: queryParams)
        request = URLRequest(url: url)
        request?.httpMethod = method.rawValue
    }

    func set(headers: [String: String]?) {
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        if let headers = headers {
            for (headerName, headerValue) in headers {
                request?.setValue(headerValue, forHTTPHeaderField: headerName)
            }
        }
    }

    func set(payload: Any?) throws {
        if let payload = payload {
            request?.httpBody = try serialize(object: payload)
        }
    }

    func url(string: String, queryParams: [String: String]?) throws -> URL {
        guard var components = URLComponents(string: string) else {
            throw JabError.invalidRequest
        }
        if let params = queryParams {
            if components.queryItems == nil {
                components.queryItems = []
            }
            for (key, value) in params {
                let item = URLQueryItem(name: key, value: value)
                components.queryItems?.append(item)
            }
        }
        guard let url = components.url else {
            throw JabError.invalidRequest
        }
        return url
    }

    func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Jab.connectionTimeout
        config.timeoutIntervalForResource = Jab.completionTimeout
        if let userAgent = Jab.userAgent {
            config.httpAdditionalHeaders = ["User-Agent": userAgent]
        }
        return URLSession(configuration: config)
    }

    func parseResponse() throws -> Any? {
        if let error = responseError {
            throw JabError.requestFailed(error: error)
        }
        if response == nil {
            throw JabError.noResponse
        }
        guard let data = responseData, data.count > 0 else {
            return nil
        }
        return try deserialize(data: data)
    }

    func deserialize(data: Data) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        } catch {
            throw JabError.deserialization
        }
    }

    func serialize(object: Any) throws -> Data {
        guard JSONSerialization.isValidJSONObject(object) else {
            throw JabError.serialization
        }
        do {
            return try JSONSerialization.data(withJSONObject: object, options: [])
        } catch {
            throw JabError.serialization
        }
    }

}

// MARK: Reachability

extension Jab {

    public var isNetworkReachable: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        guard let reachability = defaultRouteReachability else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        SCNetworkReachabilityGetFlags(reachability, &flags)
        if flags.isEmpty {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return isReachable && !needsConnection
    }

}

// MARK: HTTP Verbs

public enum JabVerb: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

extension Jab {

    public func get(url: String, queryParams: [String: String]? = nil,
                    headers: [String: String]? = nil) throws -> Any? {
        return try send(method: .get, url: url, queryParams: queryParams, headers: headers)
    }

    public func post(url: String, queryParams: [String: String]? = nil,
                     payload: Any?, headers: [String: String]? = nil) throws -> Any? {
        return try send(method: .post, url: url, queryParams: queryParams, payload: payload,
                        headers: headers)
    }

    public func patch(url: String, queryParams: [String: String]? = nil,
                      payload: Any?, headers: [String: String]? = nil) throws -> Any? {
        return try send(method: .patch, url: url, queryParams: queryParams, payload: payload,
                        headers: headers)
    }

    public func put(url: String, queryParams: [String: String]? = nil,
                    payload: Any?, headers: [String: String]? = nil) throws -> Any? {
        return try send(method: .put, url: url, queryParams: queryParams, payload: payload,
                        headers: headers)
    }

    public func delete(url: String, queryParams: [String: String]? = nil,
                       payload: Any?, headers: [String: String]? = nil) throws -> Any? {
        return try send(method: .delete, url: url, queryParams: queryParams, payload: payload,
                        headers: headers)
    }

    public func head(url: String, queryParams: [String: String]? = nil,
                     headers: [String: String]? = nil) throws -> Any? {
        return try send(method: .head, url: url, queryParams: queryParams, headers: headers)
    }

}

// MARK: Errors

public enum JabError: Error {
    case offline
    case invalidRequest
    case serialization
    case deserialization
    case noResponse
    case requestFailed(error: Error)
}

