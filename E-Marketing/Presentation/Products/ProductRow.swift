//
//  ProductRow.swift
//  E-Marketing
//

import SwiftUI

struct ProductRow: View, Equatable {

    let product: Product

    var body: some View {
        HStack(spacing: AppStyle.Space.m) {
            CachedAsyncImage(
                url: URL(string: product.thumbnail),
                pointSize: CGSize(width: AppStyle.Size.thumbnail, height: AppStyle.Size.thumbnail)
            )
                .frame(width: AppStyle.Size.thumbnail, height: AppStyle.Size.thumbnail)
                .background(AppColor.field)
                .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.control, style: .continuous))

            VStack(alignment: .leading, spacing: AppStyle.Space.row) {
                Text(product.category.capitalized)
                    .font(AppStyle.Typography.tag)
                    .foregroundStyle(AppColor.accent)
                    .padding(.horizontal, AppStyle.Space.xs)
                    .padding(.vertical, 3)
                    .background(AppStyle.accentWash)
                    .clipShape(Capsule())

                Text(product.title)
                    .font(AppStyle.Typography.bodyStrong)
                    .foregroundStyle(AppColor.ink)
                    .lineLimit(2)
            }

            Spacer(minLength: AppStyle.Space.xs)

            Text(product.price, format: .currency(code: "USD"))
                .font(AppStyle.Typography.price)
                .foregroundStyle(AppColor.accent)
                .layoutPriority(1)
        }
        .appCard(padding: AppStyle.Space.s)
    }
}
