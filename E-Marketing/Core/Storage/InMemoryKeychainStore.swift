//
//  InMemoryKeychainStore.swift
//  E-Marketing
//

import Foundation

final class InMemoryKeychainStore: KeychainServiceProtocol, @unchecked Sendable {
    private var storage: [String: String] = [:]
    private let lock = NSLock()

    func save(_ value: String, forKey key: String) throws {
        lock.lock()
        storage[key] = value
        lock.unlock()
    }

    func get(forKey key: String) throws -> String? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }

    func delete(forKey key: String) throws {
        lock.lock()
        storage.removeValue(forKey: key)
        lock.unlock()
    }
}
