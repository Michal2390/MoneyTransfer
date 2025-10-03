//
//  CurrencyModel.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

struct Currency: Identifiable, Hashable, Codable {
    let id: UUID
    let code: String
    let name: String
    let country: String
    let limit: Double

    init(code: String, name: String, country: String, limit: Double, id: UUID = UUID()) {
        self.id = id
        self.code = code
        self.name = name
        self.country = country
        self.limit = limit
    }
    
    static let pln = Currency(code: "PLN", name: "Polish Zloty", country: "Poland", limit: 20000.0)
    static let eur = Currency(code: "EUR", name: "Euro", country: "Germany", limit: 5000.0)
    static let gbp = Currency(code: "GBP", name: "British Pound", country: "Great Britain", limit: 1000.0)
    static let uah = Currency(code: "UAH", name: "Ukrainian Hryvnia", country: "Ukraine", limit: 50000.0)
    
    static let all: [Currency] = [.pln, .eur, .gbp, .uah]
    
    static func fromCode(_ code: String) -> Currency? {
        return all.first { $0.code == code }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, code, name, country, limit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.code = try container.decode(String.self, forKey: .code)
        self.name = try container.decode(String.self, forKey: .name)
        self.country = try container.decode(String.self, forKey: .country)
        self.limit = try container.decode(Double.self, forKey: .limit)
    }
}

extension Currency: Equatable {
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
    }
}

extension Currency {
    var flag: String {
        switch code.uppercased() {
        case "PLN": return "🇵🇱"
        case "EUR": return "🇩🇪"
        case "GBP": return "🇬🇧"
        case "UAH": return "🇺🇦"
        default: return "🏳️"
        }
    }
    
    var flagImageName: String {
        switch code.uppercased() {
        case "PLN": return "pl-icon"
        case "EUR": return "de-icon"
        case "GBP": return "gb-icon"
        case "UAH": return "ua-icon"
        default: return "pl-icon"
        }
    }
}
