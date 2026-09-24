//
//  AuthenticationViewModel.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {

    @Published var username = ""
    @Published var password = ""

    @Published private(set) var isLoading = false
    @Published private(set) var isAuthenticated = false

    private let repository: AuthRepositoryProtocol
    private let toastManager: ToastManager

    init(
        repository: AuthRepositoryProtocol,
        toastManager: ToastManager
    ) {
        self.repository = repository
        self.toastManager = toastManager

        checkAuthentication()
    }

    // MARK: - Login

    func login() async {

        guard !username
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        else {
            showError(.emptyUsername)
            return
        }

        guard !password.isEmpty else {
            showError(.emptyPassword)
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            _ = try await repository.login(
                username: username,
                password: password
            )

            isAuthenticated = true

        } catch let error as AppError {
            showError(error)

        } catch {
            showError(.unknown)
        }
    }

    // MARK: - Check Authentication

    func checkAuthentication() {
        do {
            let token = try repository.getAccessToken()

            isAuthenticated = !(token?.isEmpty ?? true)

        } catch {
            isAuthenticated = false
        }
    }

    // MARK: - Logout

    func logout() {
        do {
            try repository.logout()
            username = ""
            password = ""
            isAuthenticated = false

        } catch {
            showError(.keychain)
        }
    }

    // MARK: - Error

    private func showError(_ error: AppError) {
        toastManager.show(
            message: error.localizedDescription,
            type: .error
        )
    }
}
