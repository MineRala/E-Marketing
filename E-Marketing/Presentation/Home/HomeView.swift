//
//  HomeView.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import SwiftUI

struct HomeView: View {

    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            Text("Home")
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Çıkış Yap") {
                            onLogout()
                        }
                    }
                }
        }
    }
}

#Preview {
    HomeView {}
}
