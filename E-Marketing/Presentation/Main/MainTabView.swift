//
//  MainTabView.swift
//  E-Marketing
//

import SwiftUI

struct MainTabView: View {

    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var productListViewModel: ProductListViewModel
    let onLogout: () -> Void

    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel, onLogout: onLogout)
                .tabItem {
                    Label("home.tab".localized, systemImage: "house")
                        .accessibilityIdentifier("tab.home")
                }

            ProductListView(viewModel: productListViewModel)
                .tabItem {
                    Label("products.tab".localized, systemImage: "bag")
                        .accessibilityIdentifier("tab.products")
                }
        }
        .tint(AppColor.accent)
    }
}
