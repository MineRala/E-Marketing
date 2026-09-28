//
//  LoginResponse+Fixture.swift
//  E-MarketingTests
//

@testable import E_Marketing

extension LoginResponse {
    static func fixture(
        accessToken: String = "access-token",
        refreshToken: String = "refresh-token"
    ) -> LoginResponse {
        LoginResponse(
            id: 1,
            username: "emilys",
            email: "emily@example.com",
            firstName: "Emily",
            lastName: "Smith",
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }

    static var loginJSON: String {
        """
        {
          "id": 1,
          "username": "emilys",
          "email": "emily@example.com",
          "firstName": "Emily",
          "lastName": "Smith",
          "accessToken": "access-token",
          "refreshToken": "refresh-token"
        }
        """
    }
}
