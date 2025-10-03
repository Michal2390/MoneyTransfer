//
//  CurrencyConversionModel.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

struct CurrencyConversion: Codable {
    let from: String
    let to: String
    let amount: Double
    let convertedAmount: Double
    let rate: Double
    let date: Date
    
    init(from: String, to: String, amount: Double, convertedAmount: Double, rate: Double) {
        self.from = from
        self.to = to
        self.amount = amount
        self.convertedAmount = convertedAmount
        self.rate = rate
        self.date = Date()
    }
    
    static var mock: CurrencyConversion {
        CurrencyConversion(
            from: "PLN",
            to: "UAH",
            amount: 300.0,
            convertedAmount: 2265.0,
            rate: 7.55
        )
    }
}
