//
//  LocationError.swift
//  MVVM
//
//  Created by Висент Щепетков on 16.05.2024.
//

import Foundation

enum LocationError: Error {
    case noInternetAccess
    case locationDenied
}

extension LocationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetAccess:
            return L10n.noInternetAccess
        case .locationDenied:
            return L10n.locationDenied
        }
    }
}
