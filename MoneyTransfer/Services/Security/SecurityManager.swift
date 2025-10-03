//
//  SecurityManager.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 02/10/2025.
//

import Foundation
import IOSSecuritySuite

@MainActor
@Observable
class SecurityManager {
    
    private let logManager: LogManager?
    
    // Security status properties
    var isJailbroken: Bool = false
    var isDebuggerAttached: Bool = false
    var isReverseEngineered: Bool = false
    var isSimulator: Bool = false
    var isTampered: Bool = false
    var isAppIntegrityCompromised: Bool = false
    
    // Security check results
    var securityChecksPassed: Bool = true
    var securityWarnings: [SecurityWarning] = []
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    
    enum Event: LoggableEvent {
        case securityCheckStarted
        case securityCheckCompleted(passed: Bool, warnings: [SecurityWarning])
        case securityThreatDetected(threat: SecurityThreat)
        case securityCheckFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .securityCheckStarted: return "SecurityManager_Check_Started"
            case .securityCheckCompleted: return "SecurityManager_Check_Completed"
            case .securityThreatDetected: return "SecurityManager_Threat_Detected"
            case .securityCheckFailed: return "SecurityManager_Check_Failed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .securityCheckStarted:
                return nil
            case .securityCheckCompleted(let passed, let warnings):
                return [
                    "passed": passed,
                    "warningCount": warnings.count,
                    "warnings": warnings.map { $0.rawValue }
                ]
            case .securityThreatDetected(let threat):
                return ["threat": threat.rawValue]
            case .securityCheckFailed(let error):
                return ["error": error.localizedDescription]
            }
        }
        
        var type: LogType {
            switch self {
            case .securityCheckStarted, .securityCheckCompleted:
                return .analytic
            case .securityThreatDetected:
                return .severe
            case .securityCheckFailed:
                return .warning
            }
        }
    }
    
    enum SecurityWarning: String, CaseIterable {
        case jailbroken = "Device is jailbroken"
        case debuggerAttached = "Debugger is attached"
        case reverseEngineered = "App may be reverse engineered"
        case simulator = "Running on simulator"
        case tampered = "App binary has been tampered"
        case integrityCompromised = "App integrity is compromised"
    }
    
    enum SecurityThreat: String {
        case criticalThreat = "Critical security threat detected"
        case moderateThreat = "Moderate security threat detected"
        case lowThreat = "Low security threat detected"
    }
    
    // MARK: - Public Methods
    
    func performSecurityChecks() {
        logManager?.trackEvent(event: Event.securityCheckStarted)
        
        do {
            // Reset previous state
            securityWarnings.removeAll()
            
            // Perform all security checks
            checkJailbreakStatus()
            checkDebuggerAttachment()
            checkReverseEngineering()
            checkSimulatorStatus()
            checkAppIntegrity()
            
            // Determine overall security status
            evaluateOverallSecurity()
            
            logManager?.trackEvent(event: Event.securityCheckCompleted(
                passed: securityChecksPassed,
                warnings: securityWarnings
            ))
            
        } catch {
            logManager?.trackEvent(event: Event.securityCheckFailed(error: error))
        }
    }
    
    func shouldAllowAppExecution() -> Bool {
        // Define your security policy here
        // For a financial app, you might want to be more restrictive
        
        #if DEBUG
        // In debug mode, allow execution even with some security warnings
        return !isJailbroken || !isTampered
        #else
        // In production, be more strict
        return securityChecksPassed && !isJailbroken && !isTampered && !isReverseEngineered
        #endif
    }
    
    func getSecurityReport() -> SecurityReport {
        return SecurityReport(
            jailbroken: isJailbroken,
            debuggerAttached: isDebuggerAttached,
            reverseEngineered: isReverseEngineered,
            simulator: isSimulator,
            tampered: isTampered,
            integrityCompromised: isAppIntegrityCompromised,
            overallSecure: securityChecksPassed,
            warnings: securityWarnings
        )
    }
    
    // MARK: - Private Security Checks
    
    private func checkJailbreakStatus() {
        isJailbroken = IOSSecuritySuite.amIJailbroken()
        
        if isJailbroken {
            securityWarnings.append(.jailbroken)
            logManager?.trackEvent(event: Event.securityThreatDetected(threat: .criticalThreat))
        }
    }
    
    private func checkDebuggerAttachment() {
        isDebuggerAttached = IOSSecuritySuite.amIBeingDebugged()
        
        if isDebuggerAttached {
            securityWarnings.append(.debuggerAttached)
            logManager?.trackEvent(event: Event.securityThreatDetected(threat: .moderateThreat))
        }
    }
    
    private func checkReverseEngineering() {
        isReverseEngineered = IOSSecuritySuite.amIReverseEngineered()
        
        if isReverseEngineered {
            securityWarnings.append(.reverseEngineered)
            logManager?.trackEvent(event: Event.securityThreatDetected(threat: .criticalThreat))
        }
    }
    
    private func checkSimulatorStatus() {
        isSimulator = IOSSecuritySuite.amIRunInEmulator()
        
        if isSimulator {
            securityWarnings.append(.simulator)
            #if !DEBUG
            // Only log as threat in production builds
            logManager?.trackEvent(event: Event.securityThreatDetected(threat: .lowThreat))
            #endif
        }
    }
    
    private func checkAppIntegrity() {
        // Check if the app has been tampered with
        isTampered = IOSSecuritySuite.amITampered([
            .bundleID("com.michalkoks.MoneyTransfer"),
            .mobileProvision("your-mobile-provision-sha256-hash"), // Replace with actual hash
            .machO("your-macho-hash") // Replace with actual hash
        ]).result
        
        if isTampered {
            securityWarnings.append(.tampered)
            logManager?.trackEvent(event: Event.securityThreatDetected(threat: .criticalThreat))
        }
        
        // Additional integrity checks
        isAppIntegrityCompromised = checkAdditionalIntegrityMeasures()
        
        if isAppIntegrityCompromised {
            securityWarnings.append(.integrityCompromised)
            logManager?.trackEvent(event: Event.securityThreatDetected(threat: .criticalThreat))
        }
    }
    
    private func checkAdditionalIntegrityMeasures() -> Bool {
        // Check for suspicious runtime modifications
        let suspiciousLibraries = [
            "FridaGadget",
            "frida",
            "cynject",
            "libcycript"
        ]
        
        for library in suspiciousLibraries {
            if IOSSecuritySuite.amIRuntimeManipulated() {
                return true
            }
        }
        
        return false
    }
    
    private func evaluateOverallSecurity() {
        // Define your security policy
        let criticalThreats = [isJailbroken, isTampered, isReverseEngineered]
        let hasCriticalThreat = criticalThreats.contains(true)
        
        #if DEBUG
        // In debug mode, be more lenient
        securityChecksPassed = !hasCriticalThreat
        #else
        // In production, be strict about security
        securityChecksPassed = securityWarnings.isEmpty
        #endif
    }
}

// MARK: - Supporting Types

struct SecurityReport: Codable {
    let jailbroken: Bool
    let debuggerAttached: Bool
    let reverseEngineered: Bool
    let simulator: Bool
    let tampered: Bool
    let integrityCompromised: Bool
    let overallSecure: Bool
    let warnings: [SecurityManager.SecurityWarning]
    let timestamp: Date
    
    init(jailbroken: Bool, debuggerAttached: Bool, reverseEngineered: Bool, simulator: Bool, tampered: Bool, integrityCompromised: Bool, overallSecure: Bool, warnings: [SecurityManager.SecurityWarning]) {
        self.jailbroken = jailbroken
        self.debuggerAttached = debuggerAttached
        self.reverseEngineered = reverseEngineered
        self.simulator = simulator
        self.tampered = tampered
        self.integrityCompromised = integrityCompromised
        self.overallSecure = overallSecure
        self.warnings = warnings
        self.timestamp = Date()
    }
}