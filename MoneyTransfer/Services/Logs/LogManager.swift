//
//  LogManager.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import Foundation

@MainActor
@Observable
class LogManager {
    private let services: [LogService]
    
    init(services: [LogService]) {
        self.services = services
    }
    
    func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(name: event.eventName, parameters: event.parameters)
        }
    }
    
    func trackError(event: LoggableEvent, error: Error) {
        for service in services {
            if let logService = service as? ConsoleService {
                logService.trackError(name: event.eventName, error: error, parameters: event.parameters)
            } else {
                service.trackEvent(name: "\(event.eventName)_Error", parameters: event.parameters)
            }
        }
    }
}
