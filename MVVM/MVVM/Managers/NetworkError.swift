//
//  NetworkError.swift
//  TestMVP
//
//  Created by Висент Щепетков on 12.02.2024.
//

import Foundation

/// NetworkError
enum NetworkError: Error {
    case connectionError
    case serverError
    case otherError
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .connectionError:
            return "Не удалось подключиться к сети. Пожалуйста, проверьте ваше интернет-соединение."
        case .serverError:
            return "Произошла ошибка сервера. Пожалуйста, попробуйте позже."
        case .otherError:
            return "Произошла неизвестная ошибка. Пожалуйста, попробуйте позже."
        }
    }
}
