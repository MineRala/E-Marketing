//
//  E_MarketingApp.swift
//  E-Marketing
//

import SwiftUI

@main
struct E_MarketingApp: App {

    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(
                session: container.session,
                toastManager: container.toastManager,
                loginUseCase: container.loginUseCase,
                fetchCategories: container.fetchCategories,
                fetchProductPage: container.fetchProductPage
            )
        }
    }
}
