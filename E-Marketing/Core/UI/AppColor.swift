//
//  AppColor.swift
//  E-Marketing
//

import SwiftUI

enum AppColor {
    static let canvas = Color(red: 0.98, green: 0.96, blue: 0.94)
    static let ink = Color(red: 0.13, green: 0.09, blue: 0.08)
    static let accent = Color(red: 0.93, green: 0.35, blue: 0.12)
    static let accentDeep = Color(red: 0.72, green: 0.22, blue: 0.08)
    static let field = Color(red: 0.96, green: 0.94, blue: 0.92)

    static let accentGradient = LinearGradient(
        colors: [accent, accentDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
