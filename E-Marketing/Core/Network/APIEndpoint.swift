//
//  APIEndpoint.swift
//  E-Marketing
//

import Foundation

enum APIEndpoint {
    static let base = URL(string: "https://dummyjson.com")!

    static let login = base.appending(path: "auth/login")
    static let products = base.appending(path: "auth/products")
    static let categories = base.appending(path: "products/categories")
}
