//
//  ProductPagination.swift
//  E-Marketing
//

import Foundation

struct ProductListPage: Equatable, Sendable {
    let products: [Product]
    let hasMore: Bool
}

struct ProductPagination: Sendable {
    let pageSize: Int

    struct Request: Equatable, Sendable {
        let limit: Int
        let skip: Int
    }

    func firstPageRequest() -> Request {
        Request(limit: pageSize, skip: 0)
    }

    func nextPageRequest(loadedCount: Int) -> Request? {
        guard loadedCount > 0 else { return nil }
        return Request(limit: pageSize, skip: loadedCount)
    }

    func applyingFirstPage(_ page: ProductPage) -> ProductListPage {
        ProductListPage(
            products: page.products,
            hasMore: page.products.count < page.total
        )
    }

    func applyingNextPage(_ page: ProductPage, to existing: [Product]) -> ProductListPage {
        let knownIDs = Set(existing.map(\.id))
        let incoming = page.products.filter { !knownIDs.contains($0.id) }
        let products = existing + incoming
        return ProductListPage(
            products: products,
            hasMore: !incoming.isEmpty && products.count < page.total
        )
    }
}
