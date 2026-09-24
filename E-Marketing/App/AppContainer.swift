//
//  AppContainer.swift
//  E-Marketing
//

import Foundation

@MainActor
final class AppContainer {

    let session: SessionStore
    let toastManager: ToastManager
    let authRepository: AuthRepositoryProtocol

    init(
        isUITesting: Bool = ProcessInfo.processInfo.arguments.contains("--ui-testing")
    ) {
        let toastManager = ToastManager()
        self.toastManager = toastManager

        if isUITesting {
            let keychain = InMemoryKeychainStore()
            let repository = UITestingAuthRepository(keychain: keychain)
            self.authRepository = repository
            let session = SessionStore(
                authRepository: repository,
                toastManager: toastManager
            )
            self.session = session
            session.restore()
            return
        }

        let dispatcher = UnauthorizedDispatcher()
        let keychain = KeychainService()
        let interceptor = AuthRequestInterceptor(keychain: keychain)

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = false
        configuration.urlCache = nil

        let apiClient = APIClient(
            interceptor: interceptor,
            session: URLSession(configuration: configuration),
            onUnauthorized: { dispatcher.notify() }
        )

        let repository = AuthRepository(
            apiClient: apiClient,
            keychain: keychain
        )
        self.authRepository = repository

        let session = SessionStore(
            authRepository: repository,
            toastManager: toastManager
        )
        dispatcher.session = session
        self.session = session
        session.restore()
    }
}
