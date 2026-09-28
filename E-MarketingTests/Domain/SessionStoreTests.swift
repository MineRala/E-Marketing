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
        let sut = SessionStore(authRepository: repository)

        sut.restore()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.notice)
    }

    func testRestoreDropsExpiredToken() {
        let repository = MockAuthRepository()
        repository.token = JWTFixture.token(exp: 1)
        let sut = SessionStore(
            authRepository: repository,
            now: { Date(timeIntervalSince1970: 1_700_000_000) }
        )

        sut.restore()

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(repository.token)
        XCTAssertEqual(repository.logoutCallCount, 1)
        XCTAssertEqual(sut.notice, .unauthorized)
    }

    func testRestoreKeepsUnexpiredToken() {
        let repository = MockAuthRepository()
        repository.token = JWTFixture.token(exp: 1_800_000_000)
        let sut = SessionStore(
            authRepository: repository,
            now: { Date(timeIntervalSince1970: 1_700_000_000) }
        )

        sut.restore()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(repository.token, JWTFixture.token(exp: 1_800_000_000))
    }

    func testRestoreDoesNotAuthenticateWhenTokenMissing() {
        let repository = MockAuthRepository()
        let sut = SessionStore(authRepository: repository)

        sut.restore()

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.notice)
    }

    func testLogoutClearsTokenAndSession() {
        let repository = MockAuthRepository()
        repository.token = "token"
        let sut = SessionStore(authRepository: repository)
        sut.completeLogin()

        sut.logout()

        XCTAssertEqual(repository.logoutCallCount, 1)
        XCTAssertNil(repository.token)
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.notice)
    }

    func testLogoutFailureKeepsTheSession() {
        let repository = MockAuthRepository()
        repository.token = "token"
        repository.logoutError = AppError.keychain
        let sut = SessionStore(authRepository: repository)
        sut.completeLogin()

        sut.logout()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(repository.token, "token")
        XCTAssertEqual(sut.notice, .keychain)
    }

    func testUnauthorizedKeepsSessionWhenKeychainDeleteFails() {
        let repository = MockAuthRepository()
        repository.token = "token"
        repository.logoutError = AppError.keychain
        let sut = SessionStore(authRepository: repository)
        sut.completeLogin()

        sut.handleUnauthorized()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(repository.token, "token")
        XCTAssertEqual(sut.notice, .keychain)
    }

    func testUnauthorizedEndsSessionAndPublishesNotice() {
        let repository = MockAuthRepository()
        repository.token = "token"
        let sut = SessionStore(authRepository: repository)
        sut.completeLogin()

        sut.handleUnauthorized()

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(repository.token)
        XCTAssertEqual(sut.notice, .unauthorized)
    }

    func testUnauthorizedIgnoredWhenAlreadyLoggedOut() {
        let repository = MockAuthRepository()
        let sut = SessionStore(authRepository: repository)

        sut.handleUnauthorized()

        XCTAssertEqual(repository.logoutCallCount, 0)
        XCTAssertNil(sut.notice)
    }
}
