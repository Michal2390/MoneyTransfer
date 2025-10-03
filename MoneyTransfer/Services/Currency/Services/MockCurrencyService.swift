//
//  MockCurrencyService.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

struct MockCurrencyService: CurrencyService {
    
    func convertCurrency(from: String, to: String, amount: Double) async throws -> CurrencyConversion {
        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(800))
        
        // Mock exchange rates
        let rate = getMockRate(from: from, to: to)
        let convertedAmount = amount * rate
        
        return CurrencyConversion(
            from: from,
            to: to,
            amount: amount,
            convertedAmount: convertedAmount,
            rate: rate
        )
    }
    
    func convertCurrencyReverse(from: String, to: String, amount: Double) async throws -> CurrencyConversion {
        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(800))
        
        // Mock exchange rates - get reverse rate
        let forwardRate = getMockRate(from: to, to: from)
        let convertedAmount = amount / forwardRate
        
        return CurrencyConversion(
            from: to,
            to: from,
            amount: amount,
            convertedAmount: convertedAmount,
            rate: forwardRate
        )
    }
    
    private func getMockRate(from: String, to: String) -> Double {
        // Updated mock exchange rates to be more realistic
        switch (from, to) {
        case ("PLN", "UAH"): return 7.23
        case ("PLN", "EUR"): return 0.23
        case ("PLN", "GBP"): return 0.20
        case ("EUR", "PLN"): return 4.35
        case ("EUR", "UAH"): return 31.45
        case ("EUR", "GBP"): return 0.87
        case ("GBP", "PLN"): return 5.00
        case ("GBP", "EUR"): return 1.15
        case ("GBP", "UAH"): return 36.15
        case ("UAH", "PLN"): return 0.138
        case ("UAH", "EUR"): return 0.032
        case ("UAH", "GBP"): return 0.028
        default: return 1.0
        }
    }
}