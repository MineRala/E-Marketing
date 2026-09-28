//
//  HomeViewModel.swift
//  E-Marketing
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var categories: [ProductCategory] = []
    @Published private(set) var isLoading = false
    @Published private(set) var didFail = false
    @Published private(set) var reloadID = 0

    let banners = CampaignBanner.samples

    private let fetchCategories: FetchCategoriesUseCaseProtocol
    private let toastManager: ToastManager

    init(fetchCategories: FetchCategoriesUseCaseProtocol, toastManager: ToastManager) {
        self.fetchCategories = fetchCategories
        self.toastManager = toastManager
    }

    func retry() {
        guard !isLoading else { return }
        reloadID += 1
    }

    func loadCategories() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try Task.checkCancellation()
            categories = try await fetchCategories.execute()
            didFail = false
        } catch is CancellationError {
            return
        } catch let error as AppError {
            didFail = categories.isEmpty
            showError(error)
        } catch {
            didFail = categories.isEmpty
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
