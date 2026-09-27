//
//  ProductRepositoryTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class ProductRepositoryTests: XCTestCase {

    private let productsJSON = """
    {
      "products": [
        {
          "id": 1,
          "title": "Essence Mascara",
          "price": 9.99,
          "thumbnail": "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp",
          "category": "beauty"
        }
      ],
      "total": 194,
      "skip": 0,
      "limit": 20
    }
    """

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testFetchProductsSendsBearerLimitAndSkip() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/auth/products")
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Bearer access-token"
            )
            let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems
            XCTAssertEqual(items?.first { $0.name == "limit" }?.value, "20")
            XCTAssertEqual(items?.first { $0.name == "skip" }?.value, "40")
            return MockHTTP.response(url: request.url!, status: 200, json: self.productsJSON)
        }

        let keychain = InMemoryKeychainStore()
        try keychain.save("access-token", forKey: AuthStorageKey.accessToken)
        let client = APIClient(
            interceptor: AuthRequestInterceptor(keychain: keychain),
            session: MockHTTP.session(),
            onUnauthorized: {}
        )
        let sut = ProductRepository(apiClient: client)

        let page = try await sut.fetchProducts(limit: 20, skip: 40)

        XCTAssertEqual(page.products.first?.title, "Essence Mascara")
        XCTAssertEqual(page.total, 194)
    }

    func testMalformedProductsMapToDecoding() async {
        MockURLProtocol.handler = { request in
            MockHTTP.response(url: request.url!, status: 200, json: #"{"products":"no"}"#)
        }

        let client = APIClient(
            interceptor: PassthroughInterceptor(),
            session: MockHTTP.session(),
            onUnauthorized: {}
        )
        let sut = ProductRepository(apiClient: client)

        do {
            _ = try await sut.fetchProducts(limit: 20, skip: 0)
            XCTFail("Expected decoding")
        } catch let error as AppError {
            XCTAssertEqual(error, .decoding)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
