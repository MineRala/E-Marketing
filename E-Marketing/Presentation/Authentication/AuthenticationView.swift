//
//  AuthenticationView.swift
//  E-Marketing
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
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Text("Hesabınıza giriş yapın")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }

                TextField(
                    "Kullanıcı adı",
                    text: $viewModel.username
                )
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("auth.username")

                SecureField(
                    "Şifre",
                    text: $viewModel.password
                )
                .textContentType(.password)
                .submitLabel(.go)
                .onSubmit {
                    viewModel.submitLogin()
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("auth.password")

                Button {
                    viewModel.submitLogin()
                } label: {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Giriş Yap")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier("auth.login")

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .task(id: viewModel.loginRequestID) {
            guard viewModel.loginRequestID > 0 else { return }
            await viewModel.login()
        }
    }
}
