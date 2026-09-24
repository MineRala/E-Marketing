//
//  RootView.swift
//  E-Marketing
//

import SwiftUI

struct RootView: View {

    @ObservedObject var session: SessionStore
    @ObservedObject var toastManager: ToastManager
    @StateObject private var authenticationViewModel: AuthenticationViewModel

    init(
        session: SessionStore,
        toastManager: ToastManager,
        authRepository: AuthRepositoryProtocol
    ) {
        _session = ObservedObject(wrappedValue: session)
        _toastManager = ObservedObject(wrappedValue: toastManager)
        _authenticationViewModel = StateObject(
            wrappedValue: AuthenticationViewModel(
                repository: authRepository,
                session: session,
                toastManager: toastManager
            )
        )
    }

    var body: some View {
        ZStack {
            if session.isAuthenticated {
                HomeView {
                    session.logout()
                }
            } else {
                AuthenticationView(viewModel: authenticationViewModel)
            }

            if let toast = toastManager.toast {
                VStack {
                    Spacer()
                    ToastView(toast: toast)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: session.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: toastManager.toast)
    }
}
