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
            AppView()
                .environment(delegate.dependencies.currencyManager)
                .environment(delegate.dependencies.logManager)
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
    
    init(config: BuildConfiguration) {
        switch config {
        case .mock:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true)
            ])
            currencyManager = CurrencyManager(service: MockCurrencyService(), logManager: logManager)
        case .dev, .prod:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true)
            ])
            currencyManager = CurrencyManager(service: TransferGoCurrencyService(), logManager: logManager)
        }
    }
}

extension View {
    func previewEnvironment() -> some View {
        self
            .environment(CurrencyManager(service: MockCurrencyService()))
            .environment(LogManager(services: []))
    }
}
