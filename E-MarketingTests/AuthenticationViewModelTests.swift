//
//  AuthenticationViewModelTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

@MainActor
final class AuthenticationViewModelTests: XCTestCase {

    private var repository: MockAuthRepository!
    private var toastManager: ToastManager!
    private var session: SessionStore!
    private var sut: AuthenticationViewModel!

    override func setUp() {
        super.setUp()
        repository = MockAuthRepository()
        toastManager = ToastManager()
        session = SessionStore(authRepository: repository, toastManager: toastManager)
        sut = AuthenticationViewModel(
            repository: repository,
            session: session,
            toastManager: toastManager
        )
    }

    func testEmptyUsernameShowsValidationErrorAndDoesNotLogin() async {
        sut.username = "   "
        sut.password = "emilyspass"

        await sut.login()

        XCTAssertEqual(repository.loginCallCount, 0)
        XCTAssertFalse(session.isAuthenticated)
        XCTAssertEqual(toastManager.toast?.message, AppError.emptyUsername.localizedDescription)
        XCTAssertFalse(sut.isLoading)
    }

    func testEmptyPasswordShowsValidationErrorAndDoesNotLogin() async {
        sut.username = "emilys"
        sut.password = ""

        await sut.login()

        XCTAssertEqual(repository.loginCallCount, 0)
        XCTAssertFalse(session.isAuthenticated)
        XCTAssertEqual(toastManager.toast?.message, AppError.emptyPassword.localizedDescription)
    }

    func testSuccessfulLoginPersistsTokenAndAuthenticatesSession() async {
        repository.loginHandler = { [repository] in
            repository?.token = "stored-token"
        }
        sut.username = "  emilys  "
        sut.password = "emilyspass"

        await sut.login()

        XCTAssertEqual(repository.loginCallCount, 1)
        XCTAssertEqual(repository.lastUsername, "emilys")
        XCTAssertEqual(repository.token, "stored-token")
        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(sut.password, "")
        XCTAssertNil(toastManager.toast)
        XCTAssertFalse(sut.isLoading)
    }

    func testFailedLoginShowsErrorAndDoesNotAuthenticate() async {
        repository.loginHandler = {
            throw AppError.invalidCredentials
        }
        sut.username = "emilys"
        sut.password = "wrong"

        await sut.login()

        XCTAssertEqual(repository.loginCallCount, 1)
        XCTAssertFalse(session.isAuthenticated)
        XCTAssertEqual(
            toastManager.toast?.message,
            AppError.invalidCredentials.localizedDescription
        )
        XCTAssertEqual(sut.password, "wrong")
    }

    func testLoadingIsTrueWhileLoginRequestIsInFlight() async {
        var continuation: CheckedContinuation<Void, Error>?
        repository.loginHandler = {
            try await withCheckedThrowingContinuation { continuation = $0 }
        }

        sut.username = "emilys"
        sut.password = "emilyspass"

        let task = Task { await self.sut.login() }

        let loadingBecameTrue = await waitUntil(timeout: 1) { self.sut.isLoading }
        XCTAssertTrue(loadingBecameTrue)
        XCTAssertFalse(session.isAuthenticated)

        continuation?.resume()
        await task.value

        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(session.isAuthenticated)
    }

    func testSubmitLoginIncrementsRequestIDForStructuredTask() {
        XCTAssertEqual(sut.loginRequestID, 0)
        sut.submitLogin()
        XCTAssertEqual(sut.loginRequestID, 1)
    }

    private func waitUntil(
        timeout: TimeInterval,
        predicate: @escaping () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        return predicate()
    }
}
