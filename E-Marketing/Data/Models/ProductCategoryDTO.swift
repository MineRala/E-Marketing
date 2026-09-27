//
//  ProductCategoryDTO.swift
//  E-Marketing
//

import Foundation

struct ProductCategoryDTO: Decodable {
    let slug: String
    let name: String
    let url: String

    var category: ProductCategory {
        ProductCategory(slug: slug, name: name, url: url)
    }
}
