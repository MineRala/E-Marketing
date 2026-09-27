//
//  AppContainer.swift
//  E-Marketing
//

import Foundation

@MainActor
final class AppContainer {

    let session: SessionStore
    let toastManager: ToastManager
    let loginUseCase: LoginUseCaseProtocol
    let fetchCategories: FetchCategoriesUseCaseProtocol
    let fetchProductPage: FetchProductPageUseCaseProtocol

    init(
        isUITesting: Bool = ProcessInfo.processInfo.arguments.contains("--ui-testing")
    ) {
        let toastManager = ToastManager()
        self.toastManager = toastManager

        if isUITesting {
            let keychain = InMemoryKeychainStore()
            let repository = UITestingAuthRepository(keychain: keychain)
            let session = SessionStore(
                authRepository: repository,
                toastManager: toastManager
            )
            self.session = session
            self.loginUseCase = LoginUseCase(repository: repository, session: session)
            self.fetchCategories = FetchCategoriesUseCase(repository: UITestingCatalogRepository())
            self.fetchProductPage = FetchProductPageUseCase(repository: UITestingProductRepository())
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
            onUnauthorized: { await dispatcher.notify() }
        )

        let repository = AuthRepository(
            apiClient: apiClient,
            keychain: keychain
        )
        let session = SessionStore(
            authRepository: repository,
            toastManager: toastManager
        )
        dispatcher.session = session
        self.session = session
        self.loginUseCase = LoginUseCase(repository: repository, session: session)
        self.fetchCategories = FetchCategoriesUseCase(
            repository: CatalogRepository(apiClient: apiClient)
        )
        self.fetchProductPage = FetchProductPageUseCase(
            repository: ProductRepository(apiClient: apiClient)
        )
        session.restore()
    }
}
