//
//  ToastManager.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation
import SwiftUI

@MainActor
final class ToastManager: ObservableObject {

    @Published private(set) var toast: ToastData?

    private var dismissTask: Task<Void, Never>?

    func show(
        message: String,
        type: ToastType,
        duration: UInt64 = 3
    ) {
        dismissTask?.cancel()

        toast = ToastData(
            message: message,
            type: type
        )

        dismissTask = Task { [weak self] in
            try? await Task.sleep(
                for: .seconds(duration)
            )

            guard !Task.isCancelled else {
                return
            }

            self?.toast = nil
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        toast = nil
    }
}
