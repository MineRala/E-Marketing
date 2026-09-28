//
//  AccessTokenExpiry.swift
//  E-Marketing
//

import Foundation

enum AccessTokenExpiry {

    /// Reads the JWT `exp` claim. A token without a readable expiry is treated as not expired.
    static func isExpired(_ token: String, at now: Date) -> Bool {
        guard let expiration = expirationDate(in: token) else { return false }
        return expiration <= now
    }

    static func expirationDate(in token: String) -> Date? {
        let segments = token.split(separator: ".")
        guard segments.count >= 2,
              let data = base64URLDecode(String(segments[1])),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? NSNumber else {
            return nil
        }
        return Date(timeIntervalSince1970: exp.doubleValue)
    }

    private static func base64URLDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = (4 - base64.count % 4) % 4
        if padding < 4 {
            base64 += String(repeating: "=", count: padding)
        }
        return Data(base64Encoded: base64)
    }
}
