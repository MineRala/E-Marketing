//
//  Product.swift
//  E-Marketing
//

import Foundation

struct ProductPage: Equatable, Sendable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Product: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let price: Double
    let thumbnail: String
    let category: String
}
