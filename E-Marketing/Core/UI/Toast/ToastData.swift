//
//  ToastData.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

struct ToastData: Identifiable, Equatable {

    let id = UUID()
    let message: String
    let type: ToastType
}

enum ToastType: Equatable {
    case success
    case error
    case warning
    case info
}
