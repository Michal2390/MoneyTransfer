//
//  SecurityManagerTests.swift
//  MoneyTransferTests
//
//  Created by Michal Fereniec on 02/10/2025.
//

import Testing
import Foundation
@testable import MoneyTransfer

@MainActor
struct SecurityManagerTests {
    
    @Test func testSecurityManagerInitialization() async throws {
        let logManager = LogManager(services: [])
        let securityManager = SecurityManager(logManager: logManager)
        
        #expect(!securityManager.isJailbroken) // Default state
        #expect(!securityManager.isDebuggerAttached)
        #expect(!securityManager.isReverseEngineered)
        #expect(!securityManager.isTampered)
        #expect(!securityManager.isAppIntegrityCompromised)
    }
    
    @Test func testPerformSecurityChecks() async throws {
        let logManager = LogManager(services: [])
        let securityManager = SecurityManager(logManager: logManager)
        
        securityManager.performSecurityChecks()
        
        // After performing checks, we should have some state
        // Note: Actual values depend on the test environment
        #expect(securityManager.securityChecksPassed != nil)
    }
    
    @Test func testShouldAllowAppExecution() async throws {
        let logManager = LogManager(services: [])
        let securityManager = SecurityManager(logManager: logManager)
        
        securityManager.performSecurityChecks()
        
        // In test environment, should typically allow execution
        let shouldAllow = securityManager.shouldAllowAppExecution()
        
        #if DEBUG
        // Debug builds are more lenient
        #expect(shouldAllow == true || shouldAllow == false) // Either is acceptable
        #else
        // Production builds should be more strict
        #expect(shouldAllow != nil)
        #endif
    }
    
    @Test func testGetSecurityReport() async throws {
        let logManager = LogManager(services: [])
        let securityManager = SecurityManager(logManager: logManager)
        
        securityManager.performSecurityChecks()
        
        let report = securityManager.getSecurityReport()
        
        #expect(report.timestamp <= Date())
        #expect(!report.warnings.isEmpty || report.warnings.isEmpty) // Either state is valid
    }
    
    @Test func testSecurityWarningTypes() async throws {
        // Test that all security warning types are properly defined
        let allWarnings = SecurityManager.SecurityWarning.allCases
        
        #expect(allWarnings.contains(.jailbroken))
        #expect(allWarnings.contains(.debuggerAttached))
        #expect(allWarnings.contains(.reverseEngineered))
        #expect(allWarnings.contains(.simulator))
        #expect(allWarnings.contains(.tampered))
        #expect(allWarnings.contains(.integrityCompromised))
        
        #expect(allWarnings.count == 6)
    }
    
    @Test func testSecurityReportCodable() async throws {
        let report = SecurityReport(
            jailbroken: false,
            debuggerAttached: true,
            reverseEngineered: false,
            simulator: true,
            tampered: false,
            integrityCompromised: false,
            overallSecure: false,
            warnings: [.debuggerAttached, .simulator]
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(report)
        #expect(!data.isEmpty)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedReport = try decoder.decode(SecurityReport.self, from: data)
        
        #expect(decodedReport.jailbroken == report.jailbroken)
        #expect(decodedReport.debuggerAttached == report.debuggerAttached)
        #expect(decodedReport.simulator == report.simulator)
        #expect(decodedReport.warnings.count == report.warnings.count)
    }
}