//
//  HomeView.swift
//  E-Marketing
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel
    @State private var isLogoutConfirmPresented = false
    let onLogout: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: AppStyle.Space.s),
        GridItem(.flexible(), spacing: AppStyle.Space.s)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyle.Space.xl) {
                    bannerSection
                    categorySection
                }
                .padding(.horizontal, AppStyle.Space.screen)
                .padding(.top, AppStyle.Space.xs)
                .padding(.bottom, AppStyle.Space.xl)
            }
            .appScreen()
            .navigationTitle("home.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isLogoutConfirmPresented = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(AppStyle.Typography.iconSmall)
                            .foregroundStyle(AppColor.accent)
                            .frame(width: AppStyle.Size.toolbarButton, height: AppStyle.Size.toolbarButton)
                            .background(AppStyle.accentWash)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("home.logout".localized)
                    .accessibilityIdentifier("home.logout")
                }
            }
            .toolbarBackground(AppColor.canvas, for: .navigationBar)
            .alert(
                "home.logout.confirm.title".localized,
                isPresented: $isLogoutConfirmPresented
            ) {
                Button("home.logout.confirm.action".localized, role: .destructive) {
                    onLogout()
                }
                .accessibilityIdentifier("home.logout.confirm")
                Button("home.logout.cancel".localized, role: .cancel) {}
            } message: {
                Text("home.logout.confirm.message".localized)
            }
            .task(id: viewModel.reloadID) {
                await viewModel.loadCategories()
            }
        }
    }

    private var bannerSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.Space.m) {
            sectionTitle("home.campaigns".localized, identifier: "home.root")

            TabView {
                ForEach(viewModel.banners) { banner in
                    bannerCard(banner)
                }
            }
            .frame(height: 188)
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private func bannerCard(_ banner: CampaignBanner) -> some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .center, spacing: AppStyle.Space.s) {
                VStack(alignment: .leading, spacing: AppStyle.Space.xs) {
                    Text(banner.titleKey.localized)
                        .font(AppStyle.Typography.banner)
                        .foregroundStyle(.white)
                    Text(banner.subtitleKey.localized)
                        .font(AppStyle.Typography.caption)
                        .foregroundStyle(.white.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 72)
            }

            Image(systemName: banner.symbol)
                .font(AppStyle.Typography.bannerSymbol)
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(.white.opacity(0.18))
                .clipShape(Circle())
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(banner.gradient)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.banner, style: .continuous))
        .padding(.horizontal, 2)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: AppStyle.Space.m) {
            HStack {
                sectionTitle("home.categories".localized)
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppColor.accent)
                } else if !viewModel.categories.isEmpty {
                    Text("\(viewModel.categories.count)")
                        .font(AppStyle.Typography.meta)
                        .foregroundStyle(AppColor.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppStyle.accentWash)
                        .clipShape(Capsule())
                }
            }

            LazyVGrid(columns: columns, spacing: AppStyle.Space.s) {
                ForEach(viewModel.categories) { category in
                    categoryCard(category)
                        .accessibilityIdentifier("home.category.\(category.slug)")
                }
            }

            if viewModel.didFail, viewModel.categories.isEmpty {
                Button("home.retry".localized) {
                    viewModel.retry()
                }
                .font(AppStyle.Typography.bodyStrong)
                .foregroundStyle(AppColor.accent)
            }
        }
    }

    private func sectionTitle(_ title: String, identifier: String? = nil) -> some View {
        HStack(spacing: AppStyle.Space.xs) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(AppColor.accent)
                .frame(width: 4, height: 18)
            titledText(title, identifier: identifier)
        }
    }

    @ViewBuilder
    private func titledText(_ title: String, identifier: String?) -> some View {
        if let identifier {
            Text(title)
                .font(AppStyle.Typography.section)
                .foregroundStyle(AppColor.ink)
                .accessibilityIdentifier(identifier)
        } else {
            Text(title)
                .font(AppStyle.Typography.section)
                .foregroundStyle(AppColor.ink)
        }
    }

    private func categoryCard(_ category: ProductCategory) -> some View {
        VStack(alignment: .leading, spacing: AppStyle.Space.m) {
            Image(systemName: symbolName(for: category.slug))
                .font(AppStyle.Typography.icon)
                .foregroundStyle(AppColor.accent)
                .frame(width: AppStyle.Size.iconTile, height: AppStyle.Size.iconTile)
                .background(AppStyle.accentWash)
                .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.badge, style: .continuous))

            Text(category.name)
                .font(AppStyle.Typography.cardTitle)
                .foregroundStyle(AppColor.ink)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .appCard()
    }

    private func symbolName(for slug: String) -> String {
        switch slug {
        case "beauty", "skin-care", "fragrances":
            return "sparkles"
        case "smartphones", "mobile-accessories", "tablets":
            return "iphone"
        case "laptops":
            return "laptopcomputer"
        case "groceries":
            return "cart"
        case "furniture", "home-decoration", "kitchen-accessories":
            return "sofa"
        default:
            return "tag"
        }
    }
}

private extension CampaignBanner {
    var gradient: LinearGradient {
        switch style {
        case .summer:
            return LinearGradient(
                colors: [AppColor.accent, Color(red: 0.98, green: 0.55, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .tech:
            return LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.16, blue: 0.38),
                    Color(red: 0.28, green: 0.38, blue: 0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .home:
            return LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.36, blue: 0.34),
                    Color(red: 0.20, green: 0.58, blue: 0.46)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
