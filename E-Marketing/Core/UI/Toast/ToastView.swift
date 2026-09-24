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
        HStack(spacing: 12) {

            Image(systemName: iconName)
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )

            Text(toast.message)
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(backgroundColor)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
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

    private var backgroundColor: Color {
        switch toast.type {
        case .success:
            return .green
        case .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }
}
