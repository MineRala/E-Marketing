//
//  HomeView.swift
//  E-Marketing
//

import SwiftUI

struct HomeView: View {

    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            Text("Home")
                .navigationTitle("Home")
                .accessibilityIdentifier("home.root")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Çıkış Yap") {
                            onLogout()
                        }
                        .accessibilityIdentifier("home.logout")
                    }
                }
        }
    }
}

#Preview {
    HomeView {}
}
