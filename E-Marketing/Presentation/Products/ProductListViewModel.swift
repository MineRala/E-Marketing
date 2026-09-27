//
//  ProductListViewModel.swift
//  E-Marketing
//

import Foundation

@MainActor
final class ProductListViewModel: ObservableObject {

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var hasMore = true
    @Published private(set) var didFail = false
    @Published private(set) var loadID = 0

    private let fetchProductPage: FetchProductPageUseCaseProtocol
    private let toastManager: ToastManager

    init(
        fetchProductPage: FetchProductPageUseCaseProtocol,
        toastManager: ToastManager
    ) {
        self.fetchProductPage = fetchProductPage
        self.toastManager = toastManager
    }

    func retry() {
        guard !isLoading else { return }
        products = []
        hasMore = true
        didFail = false
        loadID += 1
    }

    func loadInitial() async {
        guard products.isEmpty, !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try Task.checkCancellation()
            let page = try await fetchProductPage.loadFirstPage()
            products = page.products
            hasMore = page.hasMore
            didFail = false
        } catch is CancellationError {
            return
        } catch let error as AppError {
            didFail = true
            showError(error)
        } catch {
            didFail = true
            showError(.unknown)
        }
    }

    func loadNextIfNeeded() async {
        guard hasMore, !products.isEmpty, !isLoading, !isLoadingNextPage else { return }

        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            try Task.checkCancellation()
            let page = try await fetchProductPage.loadNextPage(after: products)
            products = page.products
            hasMore = page.hasMore
        } catch is CancellationError {
            return
        } catch let error as AppError {
            showError(error)
        } catch {
            showError(.unknown)
        }
    }

    private func showError(_ error: AppError) {
        toastManager.show(
            message: error.localizedDescription,
            type: .error
        )
    }
}
