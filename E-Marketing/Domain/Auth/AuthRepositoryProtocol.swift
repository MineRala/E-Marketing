//
//  AuthRepositoryProtocol.swift
//  E-Marketing
//

import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func login(username: String, password: String) async throws
    func getAccessToken() throws -> String?
    func logout() throws
}
