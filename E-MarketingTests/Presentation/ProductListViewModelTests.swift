//
//  ProductListViewModelTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

@MainActor
final class ProductListViewModelTests: XCTestCase {

    private var repository: MockProductRepository!
    private var toastManager: ToastManager!
    private var sut: ProductListViewModel!

    override func setUp() {
        super.setUp()
        repository = MockProductRepository()
        toastManager = ToastManager()
        sut = ProductListViewModel(
            fetchProductPage: FetchProductPageUseCase(repository: repository, pageSize: 2),
            toastManager: toastManager
        )
    }

    func testLoadInitialFetchesFirstPage() async {
        repository.pages = [page(ids: [1, 2], total: 4, skip: 0)]

        await sut.loadInitial()

        XCTAssertEqual(sut.products.map(\.id), [1, 2])
        XCTAssertTrue(sut.hasMore)
        XCTAssertEqual(repository.calls.first?.limit, 2)
        XCTAssertEqual(repository.calls.first?.skip, 0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(toastManager.toast)
    }

    func testLoadInitialDoesNotRefetchWhenProductsExist() async {
        repository.pages = [page(ids: [1], total: 1, skip: 0)]
        await sut.loadInitial()

        await sut.loadInitial()

        XCTAssertEqual(repository.calls.count, 1)
    }

    func testLoadNextAppendsAndStopsAtEnd() async {
        repository.pages = [
            page(ids: [1, 2], total: 3, skip: 0),
            page(ids: [3], total: 3, skip: 2)
        ]
        await sut.loadInitial()

        await sut.loadNextIfNeeded()

        XCTAssertEqual(sut.products.map(\.id), [1, 2, 3])
        XCTAssertEqual(repository.calls[1].skip, 2)
        XCTAssertFalse(sut.hasMore)

        await sut.loadNextIfNeeded()

        XCTAssertEqual(repository.calls.count, 2)
    }

    func testLoadNextIsIgnoredWhileRequestIsInFlight() async {
        repository.pages = [page(ids: [1], total: 3, skip: 0)]
        await sut.loadInitial()

        var continuation: CheckedContinuation<ProductPage, Error>?
        repository.onFetch = {
            try await withCheckedThrowingContinuation { continuation = $0 }
        }

        let first = Task { await self.sut.loadNextIfNeeded() }
        let started = await waitUntil { self.sut.isLoadingNextPage }
        XCTAssertTrue(started)

        await sut.loadNextIfNeeded()

        continuation?.resume(returning: page(ids: [2], total: 3, skip: 1))
        await first.value

        XCTAssertEqual(repository.calls.filter { $0.skip == 1 }.count, 1)
    }

    func testNextPageFailureShowsToastAndKeepsLoadedProducts() async {
        repository.pages = [page(ids: [1, 2], total: 4, skip: 0)]
        await sut.loadInitial()

        repository.error = AppError.network
        await sut.loadNextIfNeeded()

        XCTAssertEqual(sut.products.map(\.id), [1, 2])
        XCTAssertTrue(sut.hasMore)
        XCTAssertFalse(sut.isLoadingNextPage)
        XCTAssertEqual(toastManager.toast?.message, AppError.network.localizedDescription)
    }

    func testInitialFailureShowsToast() async {
        repository.error = AppError.timeout

        await sut.loadInitial()

        XCTAssertTrue(sut.products.isEmpty)
        XCTAssertTrue(sut.didFail)
        XCTAssertEqual(toastManager.toast?.message, AppError.timeout.localizedDescription)
    }

    private func page(ids: [Int], total: Int, skip: Int) -> ProductPage {
        ProductPage(
            products: ids.map {
                Product(id: $0, title: "Item \($0)", price: 1, thumbnail: "", category: "beauty")
            },
            total: total,
            skip: skip,
            limit: ids.count
        )
    }

    private func waitUntil(predicate: @escaping () -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(1)
        while Date() < deadline {
            if predicate() { return true }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        return predicate()
    }
}
