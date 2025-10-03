//
//  ConsoleService.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

struct ConsoleService: LogService {
    let printParameters: Bool
    
    func trackEvent(name: String, parameters: [String: Any]?) {
        if printParameters, let parameters = parameters {
            print("[EVENT] \(name): \(parameters)")
        } else {
            print("[EVENT] \(name)")
        }
    }
    
    func trackError(name: String, error: Error, parameters: [String: Any]?) {
        if printParameters, let parameters = parameters {
            print("[ERROR] \(name): \(error) with parameters: \(parameters)")
        } else {
            print("[ERROR] \(name): \(error)")
        }
    }
}
