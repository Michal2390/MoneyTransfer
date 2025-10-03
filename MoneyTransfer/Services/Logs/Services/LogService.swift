//
//  LogService.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

protocol LogService {
    func trackEvent(name: String, parameters: [String: Any]?)
    func trackError(name: String, error: Error, parameters: [String: Any]?)
}
