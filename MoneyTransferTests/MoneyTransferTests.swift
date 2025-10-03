//
//  MoneyTransferTests.swift
//  MoneyTransferTests
//
//  Created by Michal Fereniec on 02/10/2025.
//

import Testing
import Foundation

@testable import MoneyTransfer

struct CurrencyModelTests {
    
    @Test func testCurrencyCreation() {
        let pln = Currency.pln
        #expect(pln.code == "PLN")
        #expect(pln.name == "Polish Zloty")
        #expect(pln.country == "Poland")
        #expect(pln.limit == 20000.0)
    }
    
    @Test func testAllCurrencies() {
        let allCurrencies = Currency.all
        #expect(allCurrencies.count == 4)
        
        let codes = allCurrencies.map { $0.code }
        #expect(codes.contains("PLN"))
        #expect(codes.contains("EUR"))
        #expect(codes.contains("GBP"))
        #expect(codes.contains("UAH"))
        
        // Verify all currencies are unique
        let uniqueCodes = Set(codes)
        #expect(uniqueCodes.count == 4)
        
        // Verify expected currencies exist
        let expectedCodes = Set(["PLN", "EUR", "GBP", "UAH"])
        #expect(Set(codes) == expectedCodes)
        
        // Verify no duplicates in the array
        #expect(allCurrencies.count == Set(allCurrencies.map { $0.code }).count)
        
        // Verify all currencies have valid properties
        for currency in allCurrencies {
            #expect(!currency.code.isEmpty)
            #expect(!currency.name.isEmpty)
            #expect(!currency.country.isEmpty)
            #expect(currency.limit > 0)
            #expect(!currency.flagImageName.isEmpty)
        }
    }
    
    @Test func testCurrencyFromCode() {
        let pln = Currency.fromCode("PLN")
        #expect(pln != nil)
        #expect(pln?.code == "PLN")
        
        let invalid = Currency.fromCode("XYZ")
        #expect(invalid == nil)
    }
    
    @Test func testCurrencyEquality() {
        let pln1 = Currency.pln
        let pln2 = Currency.pln
        let eur = Currency.eur
        
        #expect(pln1 == pln2)
        #expect(pln1 != eur)
    }
    
    @Test func testCurrencyFlagProperties() {
        #expect(Currency.pln.flagImageName == "pl-icon")
        #expect(Currency.eur.flagImageName == "eur-icon")
        #expect(Currency.gbp.flagImageName == "gb-icon")
        #expect(Currency.uah.flagImageName == "ua-icon")
        
        #expect(Currency.pln.flag == "🇵🇱")
        #expect(Currency.eur.flag == "🇩🇪")
        #expect(Currency.gbp.flag == "🇬🇧")
        #expect(Currency.uah.flag == "🇺🇦")
    }
}

struct CurrencyConversionModelTests {
    
    @Test func testCurrencyConversionCreation() {
        let conversion = CurrencyConversion(
            from: "PLN",
            to: "UAH",
            amount: 100.0,
            convertedAmount: 755.0,
            rate: 7.55
        )
        
        #expect(conversion.from == "PLN")
        #expect(conversion.to == "UAH")
        #expect(conversion.amount == 100.0)
        #expect(conversion.convertedAmount == 755.0)
        #expect(conversion.rate == 7.55)
        #expect(conversion.date <= Date.now)
    }
    
    @Test func testMockConversion() {
        let mockConversion = CurrencyConversion.mock
        #expect(mockConversion.from == "PLN")
        #expect(mockConversion.to == "UAH")
        #expect(mockConversion.amount == 300.0)
        #expect(mockConversion.convertedAmount == 2265.0)
        #expect(mockConversion.rate == 7.55)
    }
}

struct MockCurrencyServiceTests {
    
//    @Test func testMockConversion() async throws {
//        let service = MockCurrencyService()
//        let conversion = try await service.convertCurrency(from: "PLN", to: "UAH", amount: 100.0)
//        
//        #expect(conversion.from == "PLN")
//        #expect(conversion.to == "UAH")
//        #expect(conversion.amount == 100.0)
//        #expect(conversion.convertedAmount == 755.0) // 100 * 7.55
//        #expect(conversion.rate == 7.55)
//    }
//    
//    @Test func testMockReverseConversion() async throws {
//        let service = MockCurrencyService()
//        let conversion = try await service.convertCurrencyReverse(from: "UAH", to: "PLN", amount: 723.0)
//        
//        #expect(conversion.from == "UAH")
//        #expect(conversion.to == "PLN")
//        #expect(conversion.amount == 723.0)
//        #expect(abs(conversion.convertedAmount - 100.0) < 1.0) // Allow for rounding
//        #expect(conversion.rate > 0)
//    }
//    
    @Test func testAllCurrencyPairs() async throws {
        let service = MockCurrencyService()
        let currencies = ["PLN", "EUR", "GBP", "UAH"]
        
        for fromCurrency in currencies {
            for toCurrency in currencies where fromCurrency != toCurrency {
                let conversion = try await service.convertCurrency(
                    from: fromCurrency, 
                    to: toCurrency, 
                    amount: 100.0
                )
                #expect(conversion.from == fromCurrency)
                #expect(conversion.to == toCurrency)
                #expect(conversion.amount == 100.0)
                #expect(conversion.rate > 0)
                #expect(conversion.convertedAmount > 0)
            }
        }
    }
}

@MainActor
struct CurrencyManagerTests {
    
    @Test func testCurrencyManagerConversion() async throws {
        let service = MockCurrencyService()
        let manager = CurrencyManager(service: service)
        
        let conversion = try await manager.convertCurrency(from: "PLN", to: "UAH", amount: 100.0)
        
        #expect(conversion.from == "PLN")
        #expect(conversion.to == "UAH")
        #expect(conversion.amount == 100.0)
        #expect(conversion.convertedAmount == 755.0)
        #expect(conversion.rate == 7.55)
    }
    
//    @Test func testCurrencyManagerReverseConversion() async throws {
//        let service = MockCurrencyService()
//        let manager = CurrencyManager(service: service)
//        
//        let conversion = try await manager.convertCurrencyReverse(from: "UAH", to: "PLN", amount: 755.0)
//        
//        #expect(conversion.from == "UAH")
//        #expect(conversion.to == "PLN")
//        #expect(conversion.amount == 755.0)
//        #expect(abs(conversion.convertedAmount - 100.0) < 0.01)
//        #expect(conversion.rate == 7.55)
//    }
    
    @Test func testCurrencyManagerWithLogManager() async throws {
        let service = MockCurrencyService()
        let logManager = LogManager(services: [])
        let manager = CurrencyManager(service: service, logManager: logManager)
        
        let conversion = try await manager.convertCurrency(from: "EUR", to: "GBP", amount: 50.0)
        
        #expect(conversion.from == "EUR")
        #expect(conversion.to == "GBP")
        #expect(conversion.amount == 50.0)
        #expect(conversion.rate > 0)
    }
}
