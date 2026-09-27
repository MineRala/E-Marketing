//
//  ProductDTO.swift
//  E-Marketing
//

import Foundation

struct ProductPageDTO: Decodable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int

    var page: ProductPage {
        ProductPage(
            products: products.map(\.product),
            total: total,
            skip: skip,
            limit: limit
        )
    }
}

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let price: Double
    let thumbnail: String
    let category: String

    var product: Product {
        Product(
            id: id,
            title: title,
            price: price,
            thumbnail: thumbnail,
            category: category
        )
    }
}
