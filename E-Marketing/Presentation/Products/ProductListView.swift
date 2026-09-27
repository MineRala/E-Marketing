//
//  ProductListView.swift
//  E-Marketing
//

import SwiftUI

struct ProductListView: View {

    @ObservedObject var viewModel: ProductListViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading, viewModel.products.isEmpty {
                    ProgressView()
                        .tint(AppColor.accent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.didFail, viewModel.products.isEmpty {
                    VStack(spacing: AppStyle.Space.m) {
                        Image(systemName: "shippingbox")
                            .font(AppStyle.Typography.bannerSymbol)
                            .foregroundStyle(AppColor.ink.opacity(0.45))
                        Text("products.empty".localized)
                            .font(AppStyle.Typography.body)
                            .foregroundStyle(AppColor.ink.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Button("home.retry".localized) {
                            viewModel.retry()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColor.accent)
                    }
                    .padding(.horizontal, AppStyle.Space.screen)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.products) { product in
                            ProductRow(product: product)
                                .equatable()
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(
                                    top: AppStyle.Space.row,
                                    leading: AppStyle.Space.screen,
                                    bottom: AppStyle.Space.row,
                                    trailing: AppStyle.Space.screen
                                ))
                                .listRowBackground(Color.clear)
                        }

                        if viewModel.hasMore {
                            ProgressView()
                                .tint(AppColor.accent)
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .task(id: viewModel.products.count) {
                                    await viewModel.loadNextIfNeeded()
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appScreen()
            .navigationTitle("products.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.canvas, for: .navigationBar)
            .accessibilityIdentifier("products.root")
            .task(id: viewModel.loadID) {
                await viewModel.loadInitial()
            }
        }
    }
}
