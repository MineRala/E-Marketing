//
//  AppContainer.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

@MainActor
final class AppContainer {

    let apiClient: APIClientProtocol
    let keychainService: KeychainServiceProtocol
    let authRepository: AuthRepositoryProtocol
    let toastManager: ToastManager

    init() {
        self.keychainService = KeychainService()

        self.apiClient = APIClient(
            keychain: keychainService
        )

        self.authRepository = AuthRepository(
            apiClient: apiClient,
            keychain: keychainService
        )

        self.toastManager = ToastManager()
    }
}
