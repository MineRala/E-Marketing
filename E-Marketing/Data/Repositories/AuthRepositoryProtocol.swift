//
//  AuthRepositoryProtocol.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

protocol AuthRepositoryProtocol {

    func login(username: String, password: String) async throws -> LoginResponse

    func getAccessToken() throws -> String?

    func logout() throws
}
