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
                container: container
            )
        }
    }
}
