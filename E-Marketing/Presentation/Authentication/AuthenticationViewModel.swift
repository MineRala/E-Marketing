//
//  AuthenticationViewModel.swift
//  E-Marketing
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {

    @Published var username = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var loginRequestID = 0

    private let repository: AuthRepositoryProtocol
    private let session: SessionStore
    private let toastManager: ToastManager

    init(
        repository: AuthRepositoryProtocol,
        session: SessionStore,
        toastManager: ToastManager
    ) {
        self.repository = repository
        self.session = session
        self.toastManager = toastManager
    }

    func submitLogin() {
        guard !isLoading else { return }
        loginRequestID += 1
    }

    func login() async {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty else {
            showError(.emptyUsername)
            return
        }

        guard !password.isEmpty else {
            showError(.emptyPassword)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try Task.checkCancellation()
            try await repository.login(
                username: trimmedUsername,
                password: password
            )
            try Task.checkCancellation()
            password = ""
            session.completeLogin()
        } catch is CancellationError {
            return
        } catch let error as AppError {
            showError(error)
        } catch {
            showError(.unknown)
        }
    }

    private func showError(_ error: AppError) {
        toastManager.show(
            message: error.localizedDescription,
            type: .error
        )
    }
}
