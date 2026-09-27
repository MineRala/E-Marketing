//
//  Catalog.swift
//  E-Marketing
//

import Foundation

enum Catalog {
    static func prepare(_ categories: [ProductCategory]) -> [ProductCategory] {
        var seenSlugs = Set<String>()

        let prepared = categories.compactMap { category -> ProductCategory? in
            let slug = category.slug.trimmingCharacters(in: .whitespacesAndNewlines)
            let name = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let url = category.url.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !slug.isEmpty, !name.isEmpty, isHTTPURL(url) else { return nil }
            guard seenSlugs.insert(slug).inserted else { return nil }
            return ProductCategory(slug: slug, name: name, url: url)
        }

        return prepared.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    private static func isHTTPURL(_ string: String) -> Bool {
        guard let url = URL(string: string), let scheme = url.scheme?.lowercased() else {
            return false
        }
        return scheme == "https" || scheme == "http"
    }
}
