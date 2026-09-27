//
//  ToastView.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import SwiftUI

struct ToastView: View {
    let toast: ToastData

    var body: some View {
        HStack(spacing: AppStyle.Space.s) {

            Image(systemName: iconName)
                .font(AppStyle.Typography.icon)
                .foregroundStyle(accent)

            Text(toast.message)
                .font(AppStyle.Typography.caption)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, AppStyle.Space.inset)
        .padding(.vertical, AppStyle.Space.m)
        .background(AppColor.ink)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.Radius.toast, style: .continuous))
        .shadow(
            color: .black.opacity(0.15),
            radius: 10,
            y: 5
        )
        .padding(.horizontal, 20)
    }

    private var iconName: String {
        switch toast.type {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    private var accent: Color {
        switch toast.type {
        case .success:
            return Color(red: 0.35, green: 0.72, blue: 0.48)
        case .error, .warning:
            return AppColor.accent
        case .info:
            return Color(red: 0.45, green: 0.62, blue: 0.86)
        }
    }
}
