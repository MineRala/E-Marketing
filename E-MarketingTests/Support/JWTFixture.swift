//
//  JWTFixture.swift
//  E-MarketingTests
//

import Foundation

enum JWTFixture {
    static func token(exp: Int) -> String {
        let header = base64URL(#"{"alg":"none","typ":"JWT"}"#)
        let payload = base64URL("{\"exp\":\(exp)}")
        return "\(header).\(payload)."
    }

    private static func base64URL(_ value: String) -> String {
        Data(value.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
