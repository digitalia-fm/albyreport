//
//  AlbyError.swift
//  albyreport
//
//  Created by Franco Solerio on 09/10/23.
//

import Foundation

public struct ErrorResponse: Codable {
    public let code: Int?       // 0
    public let error: String     // true
    public let message: String? // "The requested resource was not found."
}


public enum AlbyError: Error {
    case alby(response: ErrorResponse)
    case notFound
    case unknown
    
    var httpStatusCode: HTTPStatusCode? {
        switch self {
            case .alby(let response):
                return HTTPStatusCode(rawValue: response.code ?? 0)
            default:
                return nil
        }
    }
}

extension AlbyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .alby(let response):
                return response.message
            case .notFound:
                return "Not found"
            case .unknown:
                return "Unknown Alby error"
        }
    }
}
