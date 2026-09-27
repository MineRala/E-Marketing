//
//  HomeViewModelTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var repository: MockCatalogRepository!
    private var toastManager: ToastManager!
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        repository = MockCatalogRepository()
        toastManager = ToastManager()
        sut = HomeViewModel(
            fetchCategories: FetchCategoriesUseCase(repository: repository),
            toastManager: toastManager
        )
    }

    func testLoadCategoriesSuccess() async {
        repository.result = .success([
            ProductCategory(slug: "beauty", name: "Beauty", url: "https://dummyjson.com/products/category/beauty")
        ])

        await sut.loadCategories()

        XCTAssertEqual(sut.categories.map(\.slug), ["beauty"])
        XCTAssertFalse(sut.didFail)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(toastManager.toast)
    }

    func testLoadCategoriesFailureShowsToast() async {
        repository.result = .failure(AppError.network)

        await sut.loadCategories()

        XCTAssertTrue(sut.categories.isEmpty)
        XCTAssertTrue(sut.didFail)
        XCTAssertEqual(toastManager.toast?.message, AppError.network.localizedDescription)
        XCTAssertFalse(sut.isLoading)
    }

    func testRetryIncrementsReloadWhenIdle() {
        XCTAssertEqual(sut.reloadID, 0)
        sut.retry()
        XCTAssertEqual(sut.reloadID, 1)
    }
}
