//
//  UITestingProductRepository.swift
//  E-Marketing
//

import Foundation

final class UITestingProductRepository: ProductRepositoryProtocol, Sendable {

    func fetchProducts(limit: Int, skip: Int) async throws -> ProductPage {
        if let error = UITestingForcedError.current {
            throw error
        }

        if ProcessInfo.processInfo.arguments.contains("--ui-testing-paged-products") {
            return pagedProducts(limit: limit, skip: skip)
        }

        guard skip == 0 else {
            return ProductPage(products: [], total: 1, skip: skip, limit: limit)
        }

        return ProductPage(
            products: [
                Product(
                    id: 1,
                    title: "Essence Mascara",
                    price: 9.99,
                    thumbnail: "",
                    category: "beauty"
                )
            ],
            total: 1,
            skip: 0,
            limit: limit
        )
    }

    private func pagedProducts(limit: Int, skip: Int) -> ProductPage {
        if skip == 0 {
            let products = (1...18).map { index in
                Product(
                    id: index,
                    title: "Catalog Item \(index)",
                    price: 1,
                    thumbnail: "",
                    category: "beauty"
                )
            }
            return ProductPage(products: products, total: 19, skip: 0, limit: limit)
        }

        return ProductPage(
            products: [
                Product(
                    id: 19,
                    title: "Second Page Serum",
                    price: 12,
                    thumbnail: "",
                    category: "beauty"
                )
            ],
            total: 19,
            skip: skip,
            limit: limit
        )
    }
}

enum UITestingForcedError {
    static var current: AppError? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "--ui-testing-status"),
              arguments.indices.contains(arguments.index(after: flag)) else {
            return nil
        }

        switch arguments[arguments.index(after: flag)] {
        case "403":
            return .forbidden
        case "404":
            return .notFound
        case "429":
            return .rateLimited
        case "500":
            return .server
        default:
            return nil
        }
    }
}
