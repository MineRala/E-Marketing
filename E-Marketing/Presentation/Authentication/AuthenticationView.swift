//
//  AuthenticationView.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import SwiftUI

struct AuthenticationView: View {

    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Hoş Geldiniz")
                        .font(
                            .system(
                                size: 32,
                                weight: .bold
                            )
                        )
                        .foregroundColor(.black)

                    Text("Hesabınıza giriş yapın")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }

                TextField(
                    "Kullanıcı adı",
                    text: $viewModel.username
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

                SecureField(
                    "Şifre",
                    text: $viewModel.password
                )
                .padding()
                .background(Color(.systemGray6))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Giriş Yap")
                                .font(
                                    .system(
                                        size: 17,
                                        weight: .semibold
                                    )
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}
