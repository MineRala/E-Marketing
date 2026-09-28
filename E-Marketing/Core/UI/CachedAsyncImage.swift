//
//  CachedAsyncImage.swift
//  E-Marketing
//

import SwiftUI

struct CachedAsyncImage: View {

    let url: URL?
    var pointSize: CGSize

    @Environment(\.imageCache) private var imageCache
    @Environment(\.displayScale) private var displayScale
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.systemGray5)
            }
        }
        .task(id: Request(url: url, pointSize: pointSize)) {
            image = await imageCache.image(
                for: url,
                pointSize: pointSize,
                scale: displayScale
            )
        }
    }

    private struct Request: Equatable {
        let url: URL?
        let pointSize: CGSize
    }
}

private struct ImageCacheKey: EnvironmentKey {
    static let defaultValue = ImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
