//
//  SessionStoreTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

@MainActor
final class SessionStoreTests: XCTestCase {

    func testRestoreAuthenticatesWhenTokenExists() {
        let repository = MockAuthRepository()
        repository.token = "token"
        let sut = SessionStore(authRepository: repository, toastManager: ToastManager())

        sut.restore()

        XCTAssertTrue(sut.isAuthenticated)
    }

    func testRestoreDoesNotAuthenticateWhenTokenMissing() {
        let repository = MockAuthRepository()
        let sut = SessionStore(authRepository: repository, toastManager: ToastManager())

        sut.restore()

        XCTAssertFalse(sut.isAuthenticated)
    }

    func testLogoutClearsTokenAndSession() {
        let repository = MockAuthRepository()
        repository.token = "token"
        let sut = SessionStore(authRepository: repository, toastManager: ToastManager())
        sut.completeLogin()

        sut.logout()

        XCTAssertEqual(repository.logoutCallCount, 1)
        XCTAssertNil(repository.token)
        XCTAssertFalse(sut.isAuthenticated)
    }

    func testUnauthorizedEndsSessionAndShowsToast() {
        let repository = MockAuthRepository()
        repository.token = "token"
        let toast = ToastManager()
        let sut = SessionStore(authRepository: repository, toastManager: toast)
        sut.completeLogin()

        sut.handleUnauthorized()

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(repository.token)
        XCTAssertEqual(toast.toast?.message, AppError.unauthorized.localizedDescription)
    }

    func testUnauthorizedIgnoredWhenAlreadyLoggedOut() {
        let repository = MockAuthRepository()
        let toast = ToastManager()
        let sut = SessionStore(authRepository: repository, toastManager: toast)

        sut.handleUnauthorized()

        XCTAssertEqual(repository.logoutCallCount, 0)
        XCTAssertNil(toast.toast)
    }
}
