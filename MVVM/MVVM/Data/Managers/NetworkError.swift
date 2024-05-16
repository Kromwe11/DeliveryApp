//
//  NetworkError.swift
//  DeliveryApp
//

import Foundation

/// NetworkError
enum NetworkError: Error {
    case connectionError
    case serverError
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .connectionError:
            return L10n.connectionError
        case .serverError:
            return L10n.serverError
        }
    }
}
