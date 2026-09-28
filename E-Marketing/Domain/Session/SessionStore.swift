//
//  SessionStore.swift
//  E-Marketing
//

import Foundation

enum SessionNotice: Equatable {
    case unauthorized
    case keychain
}

@MainActor
final class SessionStore: ObservableObject {

    @Published private(set) var isAuthenticated = false
    @Published private(set) var notice: SessionNotice?

    private let authRepository: AuthRepositoryProtocol
    private let now: () -> Date

    init(
        authRepository: AuthRepositoryProtocol,
        now: @escaping () -> Date = Date.init
    ) {
        self.authRepository = authRepository
        self.now = now
    }

    func clearNotice() {
        notice = nil
    }

    func restore() {
        do {
            guard let token = try authRepository.getAccessToken(), !token.isEmpty else {
                isAuthenticated = false
                return
            }
            if AccessTokenExpiry.isExpired(token, at: now()) {
                try? authRepository.logout()
                isAuthenticated = false
                notice = .unauthorized
                return
            }
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    func completeLogin() {
        isAuthenticated = true
    }

    func logout() {
        do {
            try authRepository.logout()
        } catch {
            notice = .keychain
            return
        }
        isAuthenticated = false
    }

    func handleUnauthorized() {
        guard isAuthenticated else { return }
        logout()
        guard !isAuthenticated else { return }
        notice = .unauthorized
    }
}
