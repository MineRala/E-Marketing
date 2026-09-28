//
//  UnauthorizedDispatcher.swift
//  E-Marketing
//

import Foundation

/// Hops a 401 onto the main actor inside the in-flight request task.
final class UnauthorizedDispatcher: @unchecked Sendable {
    @MainActor
    weak var session: SessionStore?

    func notify() async {
        await MainActor.run {
            session?.handleUnauthorized()
        }
    }
}
