//
//  CatalogRepositoryTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class CatalogRepositoryTests: XCTestCase {

    private let categoriesJSON = """
    [
      {
        "slug": "beauty",
        "name": "Beauty",
        "url": "https://dummyjson.com/products/category/beauty"
      }
    ]
    """

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testFetchCategoriesSendsBearerAndDecodes() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/products/categories")
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Bearer access-token"
            )
            return MockHTTP.response(url: request.url!, status: 200, json: self.categoriesJSON)
        }

        let keychain = InMemoryKeychainStore()
        try keychain.save("access-token", forKey: AuthStorageKey.accessToken)
        let client = APIClient(
            interceptor: AuthRequestInterceptor(keychain: keychain),
            session: MockHTTP.session(),
            onUnauthorized: {}
        )
        let sut = CatalogRepository(apiClient: client)

        let categories = try await sut.fetchCategories()

        XCTAssertEqual(categories.map(\.name), ["Beauty"])
    }

    func testMalformedCategoriesMapToDecoding() async {
        MockURLProtocol.handler = { request in
            MockHTTP.response(url: request.url!, status: 200, json: #"{"not":"categories"}"#)
        }

        let client = APIClient(
            interceptor: PassthroughInterceptor(),
            session: MockHTTP.session(),
            onUnauthorized: {}
        )
        let sut = CatalogRepository(apiClient: client)

        do {
            _ = try await sut.fetchCategories()
            XCTFail("Expected decoding")
        } catch let error as AppError {
            XCTAssertEqual(error, .decoding)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
