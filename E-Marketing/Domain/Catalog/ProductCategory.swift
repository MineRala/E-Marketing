//
//  ProductCategory.swift
//  E-Marketing
//

import Foundation

struct ProductCategory: Identifiable, Hashable, Equatable, Sendable {
    let slug: String
    let name: String
    let url: String

    var id: String { slug }
}
