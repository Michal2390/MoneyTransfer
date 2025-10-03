//
//  CurrencyManager.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class CurrencyManager {
    
    private let service: CurrencyService
    private let logManager: LogManager?
    
    init(service: CurrencyService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
    }
    
    enum Event: LoggableEvent {
        case convertStart(from: String, to: String, amount: Double)
        case convertSuccess(conversion: CurrencyConversion)
        case convertFail(error: Error)
        
        var eventName: String {
            switch self {
            case .convertStart:     return "CurrencyManager_Convert_Start"
            case .convertSuccess:   return "CurrencyManager_Convert_Success"
            case .convertFail:      return "CurrencyManager_Convert_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .convertStart(let from, let to, let amount):
                return [
                    "from": from,
                    "to": to,
                    "amount": amount
                ]
            case .convertSuccess(let conversion):
                return [
                    "from": conversion.from,
                    "to": conversion.to,
                    "amount": conversion.amount,
                    "convertedAmount": conversion.convertedAmount,
                    "rate": conversion.rate
                ]
            case .convertFail(let error):
                return ["error": error.localizedDescription]
            }
        }
        
        var type: LogType {
            switch self {
            case .convertFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    func convertCurrency(from: String, to: String, amount: Double) async throws -> CurrencyConversion {
        logManager?.trackEvent(event: Event.convertStart(from: from, to: to, amount: amount))
        
        do {
            let conversion = try await service.convertCurrency(from: from, to: to, amount: amount)
            logManager?.trackEvent(event: Event.convertSuccess(conversion: conversion))
            return conversion
        } catch {
            logManager?.trackEvent(event: Event.convertFail(error: error))
            throw error
        }
    }
    
    func convertCurrencyReverse(from: String, to: String, amount: Double) async throws -> CurrencyConversion {
        logManager?.trackEvent(event: Event.convertStart(from: from, to: to, amount: amount))
        
        do {
            let conversion = try await service.convertCurrencyReverse(from: from, to: to, amount: amount)
            logManager?.trackEvent(event: Event.convertSuccess(conversion: conversion))
            return conversion
        } catch {
            logManager?.trackEvent(event: Event.convertFail(error: error))
            throw error
        }
    }
}
