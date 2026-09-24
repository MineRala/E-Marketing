//
//  RootView.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import SwiftUI

struct RootView: View {

    private let container: AppContainer

    @StateObject private var viewModel: AuthenticationViewModel

    init(container: AppContainer) {
        self.container = container

        _viewModel = StateObject(
            wrappedValue: AuthenticationViewModel(
                repository: container.authRepository,
                toastManager: container.toastManager
            )
        )
    }

    var body: some View {
        ZStack {

            if viewModel.isAuthenticated {
                HomeView()
            } else {
                AuthenticationView(
                    viewModel: viewModel
                )
            }

            if let toast = container.toastManager.toast {
                VStack {
                    Spacer()

                    ToastView(toast: toast)
                        .padding(.bottom, 30)
                        .transition(
                            .move(edge: .bottom)
                                .combined(with: .opacity)
                        )
                }
            }
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: viewModel.isAuthenticated
        )
    }
}
