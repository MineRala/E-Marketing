//
//  AppError.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

enum AppError: LocalizedError, Equatable {

    case invalidCredentials
    case network
    case invalidResponse
    case decoding
    case keychain
    case emptyUsername
    case emptyPassword
    case unknown

    var errorDescription: String? {
        switch self {

        case .invalidCredentials:
            return "Kullanıcı adı veya şifre hatalı."

        case .network:
            return "İnternet bağlantınızı kontrol edin."

        case .invalidResponse:
            return "Sunucudan geçersiz yanıt alındı."

        case .decoding:
            return "Sunucu verileri işlenemedi."

        case .keychain:
            return "Güvenli veri kaydedilemedi."

        case .emptyUsername:
            return "Kullanıcı adı boş bırakılamaz."

        case .emptyPassword:
            return "Şifre boş bırakılamaz."

        case .unknown:
            return "Beklenmeyen bir hata oluştu."
        }
    }
}
