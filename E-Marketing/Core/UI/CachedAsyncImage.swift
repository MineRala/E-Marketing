//
//  CachedAsyncImage.swift
//  E-Marketing
//

import SwiftUI

struct CachedAsyncImage: View {

    let url: URL?
    var pointSize: CGSize

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
            image = await ImageCache.shared.image(
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
