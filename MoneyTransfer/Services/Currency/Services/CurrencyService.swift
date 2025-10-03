//
//  CurrencyService.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

protocol CurrencyService {
    func convertCurrency(from: String, to: String, amount: Double) async throws -> CurrencyConversion
    func convertCurrencyReverse(from: String, to: String, amount: Double) async throws -> CurrencyConversion
}

enum CurrencyServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case noData
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .decodingError:
            return "Decoding error"
        case .noData:
            return "No data received"
        case .apiError(let message):
            return message
        }
    }
}
