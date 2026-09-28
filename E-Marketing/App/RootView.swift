//
//  RootView.swift
//  E-Marketing
//

import SwiftUI

struct RootView: View {

    @ObservedObject var session: SessionStore
    @ObservedObject var toastManager: ToastManager
    private let imageCache: ImageCache
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var productListViewModel: ProductListViewModel

    init(
        session: SessionStore,
        toastManager: ToastManager,
        imageCache: ImageCache,
        loginUseCase: LoginUseCaseProtocol,
        fetchCategories: FetchCategoriesUseCaseProtocol,
        fetchProductPage: FetchProductPageUseCaseProtocol
    ) {
        _session = ObservedObject(wrappedValue: session)
        _toastManager = ObservedObject(wrappedValue: toastManager)
        self.imageCache = imageCache
        _authenticationViewModel = StateObject(
            wrappedValue: .init(
                loginUseCase: loginUseCase,
                toastManager: toastManager
            )
        )
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                fetchCategories: fetchCategories,
                toastManager: toastManager
            )
        )
        _productListViewModel = StateObject(
            wrappedValue: ProductListViewModel(
                fetchProductPage: fetchProductPage,
                toastManager: toastManager
            )
        )
    }

    var body: some View {
        ZStack {
            if session.isAuthenticated {
                MainTabView(
                    homeViewModel: homeViewModel,
                    productListViewModel: productListViewModel
                ) {
                    session.logout()
                }
            } else {
                AuthenticationView(viewModel: authenticationViewModel)
            }

            if let toast = toastManager.toast {
                VStack {
                    ToastView(toast: toast)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
            }
        }
        .environment(\.imageCache, imageCache)
        .animation(.easeInOut(duration: 0.3), value: session.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: toastManager.toast)
        .onChange(of: session.isAuthenticated) { isAuthenticated in
            guard !isAuthenticated else { return }
            productListViewModel.clearSession()
        }
        .task(id: session.notice) {
            presentSessionNotice()
        }
        .task(id: toastManager.toast?.id) {
            await dismissToastIfNeeded()
        }
    }

    private func presentSessionNotice() {
        guard let notice = session.notice else { return }
        let message: String
        switch notice {
        case .unauthorized:
            message = AppError.unauthorized.localizedDescription
        case .keychain:
            message = AppError.keychain.localizedDescription
        }
        session.clearNotice()
        toastManager.show(message: message, type: .error)
    }

    private func dismissToastIfNeeded() async {
        guard let toast = toastManager.toast else { return }
        do {
            try await Task.sleep(for: .seconds(toast.duration))
        } catch {
            return
        }
        guard !Task.isCancelled, toastManager.toast?.id == toast.id else { return }
        toastManager.dismiss()
    }
}
