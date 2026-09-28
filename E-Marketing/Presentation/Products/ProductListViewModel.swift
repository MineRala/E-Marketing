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
    @Published private(set) var nextPageDidFail = false
    @Published private(set) var nextPageAttempt = 0
    @Published private(set) var loadID = 0

    private let fetchProductPage: FetchProductPageUseCaseProtocol
    private let toastManager: ToastManager
    private var sessionGeneration = 0
    private var nextSkip = 0

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
        nextPageDidFail = false
        nextSkip = 0
        loadID += 1
    }

    func retryNextPage() {
        guard nextPageDidFail, !isLoading, !isLoadingNextPage else { return }
        nextPageDidFail = false
        nextPageAttempt += 1
    }

    /// Drops list and pagination state when the session ends. An in-flight page
    /// captured under the previous generation is discarded.
    func clearSession() {
        sessionGeneration += 1
        products = []
        hasMore = true
        didFail = false
        nextPageDidFail = false
        nextSkip = 0
        isLoading = false
        isLoadingNextPage = false
    }

    func loadInitial() async {
        guard products.isEmpty, !isLoading else { return }

        let generation = sessionGeneration
        isLoading = true
        defer {
            if generation == sessionGeneration {
                isLoading = false
            }
        }

        do {
            try Task.checkCancellation()
            let page = try await fetchProductPage.loadFirstPage()
            guard generation == sessionGeneration else { return }
            products = page.products
            hasMore = page.hasMore
            nextSkip = page.nextSkip
            didFail = false
            nextPageDidFail = false
        } catch is CancellationError {
            return
        } catch let error as AppError {
            guard generation == sessionGeneration else { return }
            didFail = true
            showError(error)
        } catch {
            guard generation == sessionGeneration else { return }
            didFail = true
            showError(.unknown)
        }
    }

    func loadNextIfNeeded() async {
        guard hasMore, !products.isEmpty, !isLoading, !isLoadingNextPage else { return }

        let generation = sessionGeneration
        isLoadingNextPage = true
        defer {
            if generation == sessionGeneration {
                isLoadingNextPage = false
            }
        }

        do {
            try Task.checkCancellation()
            let page = try await fetchProductPage.loadNextPage(after: products, skip: nextSkip)
            guard generation == sessionGeneration else { return }
            products = page.products
            hasMore = page.hasMore
            nextSkip = page.nextSkip
            nextPageDidFail = false
        } catch is CancellationError {
            return
        } catch let error as AppError {
            guard generation == sessionGeneration else { return }
            nextPageDidFail = true
            showError(error)
        } catch {
            guard generation == sessionGeneration else { return }
            nextPageDidFail = true
            showError(.unknown)
        }
    }

    private func showError(_ error: AppError) {
        guard error != .unauthorized else { return }
        toastManager.show(
            message: error.localizedDescription,
            type: .error
        )
    }
}
