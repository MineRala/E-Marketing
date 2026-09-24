//
//  NetworkErrorMapper.swift
//  E-Marketing
//

import Foundation

enum NetworkErrorMapper {

    static func map(statusCode: Int, authenticated: Bool) -> AppError {
        switch statusCode {
        case 200...299:
            return .invalidResponse
        case 400:
            return authenticated ? .invalidResponse : .invalidCredentials
        case 401:
            return authenticated ? .unauthorized : .invalidCredentials
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .rateLimited
        case 500...599:
            return .server
        default:
            return .invalidResponse
        }
    }

    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        if error is DecodingError {
            return .decoding
        }

        if let urlError = error as? URLError {
            return map(urlError)
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return map(URLError(URLError.Code(rawValue: nsError.code)))
        }

        return .unknown
    }

    static func map(_ urlError: URLError) -> AppError {
        switch urlError.code {
        case .timedOut:
            return .timeout
        case .cancelled:
            return .unknown
        case .notConnectedToInternet,
             .networkConnectionLost,
             .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed,
             .internationalRoamingOff,
             .dataNotAllowed:
            return .network
        default:
            return .network
        }
    }
}
