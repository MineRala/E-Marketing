//
//  LoginRequest.swift
//  E-Marketing
//

import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
    let expiresInMins: Int

    init(username: String, password: String, expiresInMins: Int = 30) {
        self.username = username
        self.password = password
        self.expiresInMins = expiresInMins
    }
}
