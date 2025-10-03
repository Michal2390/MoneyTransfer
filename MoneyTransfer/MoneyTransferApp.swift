//
//  MoneyTransferApp.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import SwiftUI

@main
struct MoneyTransferApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SecureAppView()
                .environment(delegate.dependencies.currencyManager)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.securityManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        let config: BuildConfiguration
        
        #if MOCK
        config = .mock
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        dependencies = Dependencies(config: config)
        return true
    }
}

enum BuildConfiguration {
    case mock, dev, prod
}

@MainActor
struct Dependencies {
    let currencyManager: CurrencyManager
    let logManager: LogManager
    let securityManager: SecurityManager
    
    init(config: BuildConfiguration) {
        switch config {
        case .mock:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true)
            ])
            securityManager = SecurityManager(logManager: logManager)
            currencyManager = CurrencyManager(service: MockCurrencyService(), logManager: logManager)
        case .dev, .prod:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true)
            ])
            securityManager = SecurityManager(logManager: logManager)
            currencyManager = CurrencyManager(service: TransferGoCurrencyService(), logManager: logManager)
        }
        
        // Perform security checks on initialization
        securityManager.performSecurityChecks()
    }
}

extension View {
    func previewEnvironment() -> some View {
        let logManager = LogManager(services: [])
        self
            .environment(CurrencyManager(service: MockCurrencyService()))
            .environment(logManager)
            .environment(SecurityManager(logManager: logManager))
    }
}