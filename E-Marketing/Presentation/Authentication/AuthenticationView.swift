//
//  AuthenticationView.swift
//  E-Marketing
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            AppColor.canvas
                .ignoresSafeArea()

            VStack(spacing: AppStyle.Space.xl) {
                VStack(spacing: AppStyle.Space.m) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppStyle.Radius.banner, style: .continuous)
                            .fill(AppColor.accentGradient)
                            .frame(width: AppStyle.Size.thumbnail, height: AppStyle.Size.thumbnail)
                            .shadow(color: AppColor.accent.opacity(0.28), radius: 16, y: 8)
                        Image(systemName: "bag.fill")
                            .font(AppStyle.Typography.mark)
                            .foregroundStyle(.white)
                    }

                    Text("auth.welcome".localized)
                        .font(AppStyle.Typography.hero)
                        .foregroundStyle(AppColor.ink)

                    Text("auth.subtitle".localized)
                        .font(AppStyle.Typography.body)
                        .foregroundStyle(AppColor.ink.opacity(0.55))
                }
                .padding(.top, AppStyle.Space.xl)

                VStack(spacing: AppStyle.Space.m) {
                    inputField(
                        systemImage: "person",
                        prompt: "auth.username".localized
                    ) {
                        TextField("auth.username".localized, text: $viewModel.username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.next)
                            .accessibilityIdentifier("auth.username")
                    }

                    inputField(
                        systemImage: "lock",
                        prompt: "auth.password".localized
                    ) {
                        SecureField("auth.password".localized, text: $viewModel.password)
                            .textContentType(.password)
                            .submitLabel(.go)
                            .onSubmit { viewModel.submitLogin() }
                            .accessibilityIdentifier("auth.password")
                    }

                    Button {
                        viewModel.submitLogin()
                    } label: {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("auth.login".localized)
                                    .font(AppStyle.Typography.button)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: AppStyle.Size.control)
                        .foregroundStyle(.white)
                        .background(AppColor.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.control, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canSubmit || viewModel.isLoading)
                    .opacity(viewModel.canSubmit ? 1 : 0.4)
                    .padding(.top, 4)
                    .accessibilityIdentifier("auth.login")
                }
                .appPanel()

                Spacer()
            }
            .padding(.horizontal, AppStyle.Space.screenWide)
            .tint(AppColor.accent)
        }
        .task(id: viewModel.loginRequestID) {
            guard viewModel.loginRequestID > 0 else { return }
            await viewModel.login()
        }
    }

    private func inputField<Field: View>(
        systemImage: String,
        prompt: String,
        @ViewBuilder field: () -> Field
    ) -> some View {
        HStack(spacing: AppStyle.Space.s) {
            Image(systemName: systemImage)
                .font(AppStyle.Typography.fieldIcon)
                .foregroundStyle(AppColor.accent)
                .frame(width: 20)
                .accessibilityHidden(true)

            field()
                .tint(AppColor.accent)
        }
        .appField()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(prompt)
    }
}
