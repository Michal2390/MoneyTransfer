//
//  TransferGoCurrencyService.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .decodingError:
            return "Decoding error"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

protocol CurrencyNetworking {
    func convertCurrency(from: String, to: String, amount: Double) async throws -> CurrencyConversion
    func convertCurrencyReverse(from: String, to: String, amount: Double) async throws -> CurrencyConversion
}

@Observable
final class TransferGoCurrencyService: CurrencyNetworking, CurrencyService {
    private let baseURL = "https://my.transfergo.com/api/fx-rates"
    var isLoading = false
    
    func convertCurrency(from: String, to: String, amount: Double) async throws -> CurrencyConversion {
        isLoading = true
        defer { isLoading = false }
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "amount", value: "\(amount)")
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Log response for debugging
            #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("TransferGo API Response: \(jsonString)")
            }
            #endif
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(TransferGoResponse.self, from: data)
            
            return CurrencyConversion(
                from: result.from,
                to: result.to,
                amount: result.fromAmount,
                convertedAmount: result.toAmount,
                rate: result.rate
            )
        } catch let decodingError as DecodingError {
            print("TransferGo decoding error: \(decodingError)")
            throw NetworkError.decodingError
        } catch {
            print("TransferGo network error: \(error)")
            throw NetworkError.unknown
        }
    }
    
    func convertCurrencyReverse(from: String, to: String, amount: Double) async throws -> CurrencyConversion {
        isLoading = true
        defer { isLoading = false }
        
        // For reverse conversion, we calculate backwards from the target amount
        // First get the rate from 'to' currency to 'from' currency
        let forwardConversion = try await convertCurrency(from: to, to: from, amount: 1.0)
        let reverseRate = forwardConversion.rate
        let originalAmount = amount / reverseRate
        
        return CurrencyConversion(
            from: to,
            to: from,
            amount: amount,
            convertedAmount: originalAmount,
            rate: reverseRate
        )
    }
}

// MARK: - TransferGo API Response Models
private struct TransferGoResponse: Codable {
    let from: String
    let to: String
    let rate: Double
    let fromAmount: Double
    let toAmount: Double
    
    private enum CodingKeys: String, CodingKey {
        case from, to, rate, fromAmount, toAmount
    }
}