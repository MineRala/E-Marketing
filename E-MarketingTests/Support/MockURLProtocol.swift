//
//  MockURLProtocol.swift
//  E-MarketingTests
//

import Foundation

final class MockURLProtocol: URLProtocol {

    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var error: Error?

    static func reset() {
        handler = nil
        error = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        guard let handler = MockURLProtocol.handler else {
            client?.urlProtocol(
                self,
                didFailWithError: URLError(.unknown)
            )
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

enum MockHTTP {
    static func response(
        url: URL,
        status: Int,
        json: String
    ) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (response, Data(json.utf8))
    }

    static func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}
