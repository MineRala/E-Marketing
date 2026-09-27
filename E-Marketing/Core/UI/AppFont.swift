//
//  AppFont.swift
//  E-Marketing
//

import SwiftUI

enum AppFont: String {
    case regular = "Montserrat-Regular"
    case medium = "Montserrat-Medium"
    case semiBold = "Montserrat-SemiBold"
    case bold = "Montserrat-Bold"

    func font(size: CGFloat) -> Font {
        .custom(rawValue, size: size)
    }
}
