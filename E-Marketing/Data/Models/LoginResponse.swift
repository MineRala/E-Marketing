//
//  LoginResponse.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

struct LoginResponse: Decodable {

    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let accessToken: String
    let refreshToken: String
}
