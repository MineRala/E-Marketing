//
//  RootView.swift
//  E-Marketing
//

import SwiftUI

struct RootView: View {

    @ObservedObject var session: SessionStore
    @ObservedObject var toastManager: ToastManager
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var productListViewModel: ProductListViewModel

    init(
        session: SessionStore,
        toastManager: ToastManager,
        loginUseCase: LoginUseCaseProtocol,
        fetchCategories: FetchCategoriesUseCaseProtocol,
        fetchProductPage: FetchProductPageUseCaseProtocol
    ) {
        _session = ObservedObject(wrappedValue: session)
        _toastManager = ObservedObject(wrappedValue: toastManager)
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
        .animation(.easeInOut(duration: 0.3), value: session.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: toastManager.toast)
        .task(id: toastManager.toast?.id) {
            await dismissToastIfNeeded()
        }
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
