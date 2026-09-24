//
//  LoginResponse.swift
//  E-Marketing
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

    init(
        id: Int,
        username: String,
        email: String,
        firstName: String,
        lastName: String,
        accessToken: String,
        refreshToken: String
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    private enum CodingKeys: String, CodingKey {
        case id, username, email, firstName, lastName
        case accessToken, refreshToken, token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
            ?? container.decode(String.self, forKey: .token)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken) ?? ""
    }
}

extension LoginResponse: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        "LoginResponse(id: \(id), username: \(username), email: \(email))"
    }

    var debugDescription: String {
        description
    }
}
