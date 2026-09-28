//
//  FetchProductPageUseCase.swift
//  E-Marketing
//

import Foundation

protocol FetchProductPageUseCaseProtocol: Sendable {
    func loadFirstPage() async throws -> ProductListPage
    func loadNextPage(after loaded: [Product], skip: Int) async throws -> ProductListPage
}

struct FetchProductPageUseCase: FetchProductPageUseCaseProtocol {
    private let repository: ProductRepositoryProtocol
    private let pagination: ProductPagination

    init(repository: ProductRepositoryProtocol, pageSize: Int = 20) {
        self.repository = repository
        self.pagination = ProductPagination(pageSize: pageSize)
    }

    func loadFirstPage() async throws -> ProductListPage {
        let request = pagination.firstPageRequest()
        let page = try await repository.fetchProducts(limit: request.limit, skip: request.skip)
        return pagination.applyingFirstPage(page, requestedSkip: request.skip)
    }

    func loadNextPage(after loaded: [Product], skip: Int) async throws -> ProductListPage {
        guard let request = pagination.nextPageRequest(skip: skip) else {
            return ProductListPage(products: loaded, hasMore: false, nextSkip: skip)
        }
        let page = try await repository.fetchProducts(limit: request.limit, skip: request.skip)
        return pagination.applyingNextPage(page, to: loaded, requestedSkip: request.skip)
    }
}
