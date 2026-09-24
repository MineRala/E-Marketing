//
//  KeychainService.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation
import Security

protocol KeychainServiceProtocol {

    func save(_ value: String, forKey key: String) throws

    func get(forKey key: String) throws -> String?

    func delete(forKey key: String) throws
}


final class KeychainService: KeychainServiceProtocol {

    private let service = "com.MineRala.E-Marketing"

    func save(_ value: String, forKey key: String) throws {

        guard let data =
                value.data(using: .utf8) else {
            throw AppError.keychain
        }

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                key,

            kSecAttrAccessible as String:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,

            kSecValueData as String:
                data
        ]

        SecItemDelete(
            query as CFDictionary
        )

        let status =
            SecItemAdd(
                query as CFDictionary,
                nil
            )

        guard status == errSecSuccess else {
            throw AppError.keychain
        }
    }

    func get(forKey key: String) throws -> String? {

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                key,

            kSecReturnData as String:
                true,

            kSecMatchLimit as String:
                kSecMatchLimitOne
        ]

        var result: AnyObject?

        let status =
            SecItemCopyMatching(
                query as CFDictionary,
                &result
            )

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(
                data: data,
                encoding: .utf8
              )
        else {
            throw AppError.keychain
        }

        return value
    }

    func delete(forKey key: String) throws {

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                key
        ]

        let status =
            SecItemDelete(
                query as CFDictionary
            )

        guard status == errSecSuccess ||
              status == errSecItemNotFound
        else {
            throw AppError.keychain
        }
    }
}
