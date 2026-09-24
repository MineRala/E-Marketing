//
//  PassthroughInterceptor.swift
//  E-MarketingTests
//

import Foundation
@testable import E_Marketing

struct PassthroughInterceptor: RequestInterceptor {
    func adapt(_ request: URLRequest) throws -> URLRequest {
        request
    }
}
