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

    private let loginUseCase: LoginUseCaseProtocol
    private let toastManager: ToastManager

    init(
        loginUseCase: LoginUseCaseProtocol,
        toastManager: ToastManager
    ) {
        self.loginUseCase = loginUseCase
        self.toastManager = toastManager
    }

    var canSubmit: Bool {
        (try? LoginCredentials(username: username, password: password)) != nil
    }

    func submitLogin() {
        guard canSubmit, !isLoading else { return }
        loginRequestID += 1
    }

    func login() async {
        guard canSubmit else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try Task.checkCancellation()
            try await loginUseCase.execute(username: username, password: password)
            password = ""
            try Task.checkCancellation()
        } catch is CancellationError {
            return
        } catch let error as AppError {
            showError(error)
        } catch {
            showError(.unknown)
        }
    }

    private func showError(_ error: AppError) {
        guard error != .unauthorized else { return }
        toastManager.show(
            message: error.localizedDescription,
            type: .error
        )
    }
}
