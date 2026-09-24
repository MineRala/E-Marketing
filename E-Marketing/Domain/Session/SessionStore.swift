//
//  SessionStore.swift
//  E-Marketing
//

import Foundation

@MainActor
final class SessionStore: ObservableObject {

    @Published private(set) var isAuthenticated = false

    private let authRepository: AuthRepositoryProtocol
    private let toastManager: ToastManager

    init(
        authRepository: AuthRepositoryProtocol,
        toastManager: ToastManager
    ) {
        self.authRepository = authRepository
        self.toastManager = toastManager
    }

    func restore() {
        do {
            let token = try authRepository.getAccessToken()
            isAuthenticated = !(token?.isEmpty ?? true)
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
            toastManager.show(
                message: AppError.keychain.localizedDescription,
                type: .error
            )
        }
        isAuthenticated = false
    }

    func handleUnauthorized() {
        guard isAuthenticated else { return }
        logout()
        toastManager.show(
            message: AppError.unauthorized.localizedDescription,
            type: .error
        )
    }
}
