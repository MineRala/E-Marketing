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
            return "Kullanıcı adı boş bırakılamaz."
        case .emptyPassword:
            return "Şifre boş bırakılamaz."
        case .invalidCredentials:
            return "Kullanıcı adı veya şifre hatalı."
        case .unauthorized:
            return "Oturumunuz sona erdi. Lütfen tekrar giriş yapın."
        case .forbidden:
            return "Bu işlem için yetkiniz yok."
        case .notFound:
            return "İstenen kaynak bulunamadı."
        case .rateLimited:
            return "Çok fazla istek gönderildi. Lütfen sonra tekrar deneyin."
        case .server:
            return "Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin."
        case .timeout:
            return "İstek zaman aşımına uğradı."
        case .network:
            return "İnternet bağlantınızı kontrol edin."
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt alındı."
        case .decoding:
            return "Sunucu verileri işlenemedi."
        case .keychain:
            return "Güvenli veri kaydedilemedi."
        case .unknown:
            return "Beklenmeyen bir hata oluştu."
        }
    }
}
