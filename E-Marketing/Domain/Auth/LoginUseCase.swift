//
//  LoginUseCase.swift
//  E-Marketing
//

import Foundation

struct LoginCredentials: Equatable, Sendable {
    let username: String
    let password: String

    init(username: String, password: String) throws {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { throw AppError.emptyUsername }
        guard !password.isEmpty else { throw AppError.emptyPassword }
        self.username = trimmedUsername
        self.password = password
    }
}

@MainActor
protocol LoginUseCaseProtocol {
    func execute(username: String, password: String) async throws
}

@MainActor
struct LoginUseCase: LoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let session: SessionStore

    init(repository: AuthRepositoryProtocol, session: SessionStore) {
        self.repository = repository
        self.session = session
    }

    func execute(username: String, password: String) async throws {
        let credentials = try LoginCredentials(username: username, password: password)
        try await repository.login(
            username: credentials.username,
            password: credentials.password
        )
        session.completeLogin()
    }
}
