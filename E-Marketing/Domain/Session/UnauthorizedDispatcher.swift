//
//  UnauthorizedDispatcher.swift
//  E-Marketing
//

import Foundation

/// Bridges URLSession callbacks to the main-actor session without retaining a cycle.
final class UnauthorizedDispatcher: @unchecked Sendable {
    @MainActor
    weak var session: SessionStore?

    func notify() {
        Task { @MainActor in
            session?.handleUnauthorized()
        }
    }
}
