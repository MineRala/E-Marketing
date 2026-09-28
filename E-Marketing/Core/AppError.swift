//
//  AppError.swift
//  E-Marketing
//

import Foundation

enum AppError: LocalizedError, Equatable {
    case emptyUsername
    case emptyPassword
    case invalidCredentials
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case server
    case timeout
    case network
    case invalidResponse
    case decoding
    case keychain
    case unknown

    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "error.empty_username".localized
        case .emptyPassword:
            return "error.empty_password".localized
        case .invalidCredentials:
            return "error.invalid_credentials".localized
        case .unauthorized:
            return "error.unauthorized".localized
        case .forbidden:
            return "error.forbidden".localized
        case .notFound:
            return "error.not_found".localized
        case .rateLimited:
            return "error.rate_limited".localized
        case .server:
            return "error.server".localized
        case .timeout:
            return "error.timeout".localized
        case .network:
            return "error.network".localized
        case .invalidResponse:
            return "error.invalid_response".localized
        case .decoding:
            return "error.decoding".localized
        case .keychain:
            return "error.keychain".localized
        case .unknown:
            return "error.unknown".localized
        }
    }
}
