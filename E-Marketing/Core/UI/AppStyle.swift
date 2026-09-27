//
//  AppStyle.swift
//  E-Marketing
//

import SwiftUI

enum AppStyle {
    enum Typography {
        static let hero = AppFont.bold.font(size: 32)
        static let banner = AppFont.bold.font(size: 26)
        static let section = AppFont.bold.font(size: 20)
        static let button = AppFont.semiBold.font(size: 17)
        static let body = AppFont.regular.font(size: 16)
        static let bodyStrong = AppFont.semiBold.font(size: 16)
        static let cardTitle = AppFont.semiBold.font(size: 15)
        static let price = AppFont.bold.font(size: 15)
        static let caption = AppFont.medium.font(size: 14)
        static let meta = AppFont.semiBold.font(size: 13)
        static let tag = AppFont.semiBold.font(size: 11)
        static let icon = Font.system(size: 18, weight: .semibold)
        static let iconSmall = Font.system(size: 15, weight: .semibold)
        static let fieldIcon = Font.system(size: 16, weight: .semibold)
        static let mark = Font.system(size: 32, weight: .semibold)
        static let bannerSymbol = Font.system(size: 34, weight: .semibold)
    }

    enum Space {
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 14
        static let l: CGFloat = 20
        static let xl: CGFloat = 28
        static let inset: CGFloat = 16
        static let screen: CGFloat = 20
        static let screenWide: CGFloat = 24
        static let row: CGFloat = 6
    }

    enum Radius {
        static let control: CGFloat = 14
        static let card: CGFloat = 18
        static let banner: CGFloat = 22
        static let panel: CGFloat = 24
        static let badge: CGFloat = 12
        static let toast: CGFloat = 16
    }

    enum Size {
        static let control: CGFloat = 52
        static let thumbnail: CGFloat = 76
        static let iconTile: CGFloat = 40
        static let toolbarButton: CGFloat = 36
    }

    static let accentWash = AppColor.accent.opacity(0.12)
    static let cardShadow = AppColor.ink.opacity(0.05)
}

private struct AppCardModifier: ViewModifier {
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.card, style: .continuous))
            .shadow(color: AppStyle.cardShadow, radius: 10, y: 4)
    }
}

private struct AppPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppStyle.Space.l)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.panel, style: .continuous))
            .shadow(color: AppColor.ink.opacity(0.06), radius: 18, y: 8)
    }
}

private struct AppFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppStyle.Space.inset)
            .frame(height: AppStyle.Size.control)
            .background(AppColor.field)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.control, style: .continuous))
    }
}

extension View {
    func appCard(padding: CGFloat = AppStyle.Space.m) -> some View {
        modifier(AppCardModifier(padding: padding))
    }

    func appPanel() -> some View {
        modifier(AppPanelModifier())
    }

    func appField() -> some View {
        modifier(AppFieldModifier())
    }

    func appScreen() -> some View {
        background(AppColor.canvas)
    }
}
