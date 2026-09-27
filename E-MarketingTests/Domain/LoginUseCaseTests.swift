//
//  LoginUseCaseTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

@MainActor
final class LoginUseCaseTests: XCTestCase {

    private var repository: MockAuthRepository!
    private var session: SessionStore!
    private var sut: LoginUseCase!

    override func setUp() {
        super.setUp()
        repository = MockAuthRepository()
        session = SessionStore(authRepository: repository, toastManager: ToastManager())
        sut = LoginUseCase(repository: repository, session: session)
    }

    func testBlankUsernameDoesNotCallRepository() async {
        do {
            try await sut.execute(username: "   ", password: "emilyspass")
            XCTFail("Expected empty username")
        } catch let error as AppError {
            XCTAssertEqual(error, .emptyUsername)
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        XCTAssertEqual(repository.loginCallCount, 0)
        XCTAssertFalse(session.isAuthenticated)
    }

    func testEmptyPasswordDoesNotCallRepository() async {
        do {
            try await sut.execute(username: "emilys", password: "")
            XCTFail("Expected empty password")
        } catch let error as AppError {
            XCTAssertEqual(error, .emptyPassword)
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        XCTAssertEqual(repository.loginCallCount, 0)
        XCTAssertFalse(session.isAuthenticated)
    }

    func testTrimsUsernamePersistsTokenAndOpensSession() async throws {
        try await sut.execute(username: "  emilys  ", password: "emilyspass")

        XCTAssertEqual(repository.loginCallCount, 1)
        XCTAssertEqual(repository.lastUsername, "emilys")
        XCTAssertEqual(repository.lastPassword, "emilyspass")
        XCTAssertEqual(repository.token, "stored-token")
        XCTAssertTrue(session.isAuthenticated)
    }

    func testRepositoryErrorDoesNotOpenSession() async {
        repository.loginHandler = { throw AppError.invalidCredentials }

        do {
            try await sut.execute(username: "emilys", password: "wrong")
            XCTFail("Expected invalid credentials")
        } catch let error as AppError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        XCTAssertFalse(session.isAuthenticated)
    }
}
