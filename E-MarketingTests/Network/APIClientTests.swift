//
//  APIClientTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class APIClientTests: XCTestCase {

    private final class UnauthorizedCounter: @unchecked Sendable {
        var value = 0
        func increment() { value += 1 }
    }

    private var unauthorizedCounter: UnauthorizedCounter!

    override func setUp() {
        super.setUp()
        unauthorizedCounter = UnauthorizedCounter()
        MockURLProtocol.reset()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testSuccessfulJSONResponse() async throws {
        MockURLProtocol.handler = { request in
            MockHTTP.response(url: request.url!, status: 200, json: LoginResponse.loginJSON)
        }

        let client = makeClient()
        let response: LoginResponse = try await client.request(
            URLRequest(url: APIEndpoint.login),
            authenticated: false
        )

        XCTAssertEqual(response.username, "emilys")
        XCTAssertEqual(response.accessToken, "access-token")
        XCTAssertEqual(unauthorizedCounter.value, 0)
        XCTAssertEqual(response.description.contains("access-token"), false)
    }

    func testUnauthorizedOnProtectedRequestNotifiesSession() async {
        MockURLProtocol.handler = { request in
            MockHTTP.response(url: request.url!, status: 401, json: #"{"message":"invalid"}"#)
        }

        let client = makeClient()

        do {
            let _: LoginResponse = try await client.request(
                URLRequest(url: APIEndpoint.products),
                authenticated: true
            )
            XCTFail("Expected unauthorized")
        } catch let error as AppError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        XCTAssertEqual(unauthorizedCounter.value, 1)
    }

    func testMissingTokenDoesNotReachTheNetwork() async {
        let client = APIClient(
            interceptor: RejectingInterceptor(),
            session: MockHTTP.session(),
            onUnauthorized: { [unauthorizedCounter] in
                unauthorizedCounter?.increment()
            }
        )
        MockURLProtocol.handler = { request in
            XCTFail("Protected request left the device")
            return MockHTTP.response(url: request.url!, status: 200, json: "{}")
        }

        do {
            let _: LoginResponse = try await client.request(URLRequest(url: APIEndpoint.products))
            XCTFail("Expected unauthorized")
        } catch let error as AppError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        XCTAssertEqual(unauthorizedCounter.value, 1)
    }

    func testLogin401DoesNotNotifySession() async {
        MockURLProtocol.handler = { request in
            MockHTTP.response(url: request.url!, status: 401, json: #"{"message":"invalid"}"#)
        }

        let client = makeClient()

        do {
            let _: LoginResponse = try await client.request(
                URLRequest(url: APIEndpoint.login),
                authenticated: false
            )
            XCTFail("Expected invalid credentials")
        } catch let error as AppError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        XCTAssertEqual(unauthorizedCounter.value, 0)
    }

    func testTimeoutMapsToTimeoutError() async {
        MockURLProtocol.error = URLError(.timedOut)
        let client = makeClient()

        do {
            let _: LoginResponse = try await client.request(
                URLRequest(url: APIEndpoint.login),
                authenticated: false
            )
            XCTFail("Expected timeout")
        } catch let error as AppError {
            XCTAssertEqual(error, .timeout)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testMalformedJSONMapsToDecoding() async {
        MockURLProtocol.handler = { request in
            MockHTTP.response(url: request.url!, status: 200, json: #"{"not":"login"}"#)
        }

        let client = makeClient()

        do {
            let _: LoginResponse = try await client.request(
                URLRequest(url: APIEndpoint.login),
                authenticated: false
            )
            XCTFail("Expected decoding")
        } catch let error as AppError {
            XCTAssertEqual(error, .decoding)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testForbiddenNotFoundAndServerDoNotEndSession() async {
        let cases: [(Int, AppError)] = [
            (403, .forbidden),
            (404, .notFound),
            (500, .server)
        ]

        for (status, expected) in cases {
            MockURLProtocol.handler = { request in
                MockHTTP.response(url: request.url!, status: status, json: "{}")
            }

            let client = makeClient()

            do {
                let _: LoginResponse = try await client.request(
                    URLRequest(url: APIEndpoint.products)
                )
                XCTFail("Expected \(expected)")
            } catch let error as AppError {
                XCTAssertEqual(error, expected)
            } catch {
                XCTFail("Unexpected error \(error)")
            }
        }

        XCTAssertEqual(unauthorizedCounter.value, 0)
    }

    func testConnectionLostMapsToNetwork() async {
        MockURLProtocol.error = URLError(.networkConnectionLost)
        let client = makeClient()

        do {
            let _: LoginResponse = try await client.request(
                URLRequest(url: APIEndpoint.login),
                authenticated: false
            )
            XCTFail("Expected network")
        } catch let error as AppError {
            XCTAssertEqual(error, .network)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testRateLimitedStatus() async {
        MockURLProtocol.handler = { request in
            MockHTTP.response(url: request.url!, status: 429, json: "{}")
        }

        let client = makeClient()

        do {
            let _: LoginResponse = try await client.request(
                URLRequest(url: APIEndpoint.products)
            )
            XCTFail("Expected rate limited")
        } catch let error as AppError {
            XCTAssertEqual(error, .rateLimited)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    private struct RejectingInterceptor: RequestInterceptor {
        func adapt(_ request: URLRequest) throws -> URLRequest {
            throw AppError.unauthorized
        }
    }

    private func makeClient() -> APIClient {
        APIClient(
            interceptor: PassthroughInterceptor(),
            session: MockHTTP.session(),
            onUnauthorized: { [unauthorizedCounter] in
                unauthorizedCounter?.increment()
            }
        )
    }
}
