//
//  ToastManager.swift
//  E-Marketing
//

import Foundation
import SwiftUI

@MainActor
final class ToastManager: ObservableObject {

    @Published private(set) var toast: ToastData?

    func show(message: String, type: ToastType, duration: UInt64 = 4) {
        toast = ToastData(
            message: message,
            type: type,
            duration: TimeInterval(duration)
        )
    }

    func dismiss() {
        toast = nil
    }
}
