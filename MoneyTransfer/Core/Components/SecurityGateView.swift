//
//  SecurityGateView.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 02/10/2025.
//

import SwiftUI

struct SecurityGateView: View {
    let securityReport: SecurityReport
    let onContinue: () -> Void
    let onExit: () -> Void
    
    @State private var showDetails: Bool = false
    
    private var criticalWarnings: [SecurityManager.SecurityWarning] {
        securityReport.warnings.filter { warning in
            switch warning {
            case .jailbroken, .tampered, .reverseEngineered:
                return true
            default:
                return false
            }
        }
    }
    
    private var shouldBlockAccess: Bool {
        #if DEBUG
        return false // Allow access in debug mode
        #else
        return !criticalWarnings.isEmpty
        #endif
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            warningsSection
            actionSection
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: shouldBlockAccess ? "exclamationmark.shield.fill" : "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(shouldBlockAccess ? .red : .green)
            
            Text(shouldBlockAccess ? "Security Warning" : "Security Check Passed")
                .font(.title.bold())
                .foregroundStyle(shouldBlockAccess ? .red : .primary)
            
            Text(shouldBlockAccess ? 
                 "Your device may not be secure for financial transactions." :
                 "Your device meets our security requirements.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var warningsSection: some View {
        Group {
            if !securityReport.warnings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Security Issues Detected")
                            .font(.headline)
                        Spacer()
                        Button(showDetails ? "Hide Details" : "Show Details") {
                            withAnimation(.easeInOut) {
                                showDetails.toggle()
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    }
                    
                    if showDetails {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(securityReport.warnings, id: \.rawValue) { warning in
                                warningRow(warning)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private func warningRow(_ warning: SecurityManager.SecurityWarning) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconForWarning(warning))
                .foregroundStyle(colorForWarning(warning))
                .font(.body)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(warning.rawValue)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Text(descriptionForWarning(warning))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            if shouldBlockAccess {
                Button(action: onExit) {
                    Text("Exit App")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                #if DEBUG
                Button(action: onContinue) {
                    Text("Continue Anyway (Debug Only)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                #endif
            } else {
                Button(action: onContinue) {
                    Text("Continue to App")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func iconForWarning(_ warning: SecurityManager.SecurityWarning) -> String {
        switch warning {
        case .jailbroken:
            return "iphone.slash"
        case .debuggerAttached:
            return "ladybug"
        case .reverseEngineered:
            return "arrow.triangle.2.circlepath.circle"
        case .simulator:
            return "desktopcomputer"
        case .tampered:
            return "exclamationmark.triangle"
        case .integrityCompromised:
            return "checkmark.seal"
        }
    }
    
    private func colorForWarning(_ warning: SecurityManager.SecurityWarning) -> Color {
        switch warning {
        case .jailbroken, .tampered, .reverseEngineered:
            return .red
        case .debuggerAttached, .integrityCompromised:
            return .orange
        case .simulator:
            return .blue
        }
    }
    
    private func descriptionForWarning(_ warning: SecurityManager.SecurityWarning) -> String {
        switch warning {
        case .jailbroken:
            return "Device has been modified to bypass security restrictions"
        case .debuggerAttached:
            return "Development tools are currently attached to the app"
        case .reverseEngineered:
            return "App may have been modified or analyzed by third parties"
        case .simulator:
            return "App is running in a development environment"
        case .tampered:
            return "App files may have been modified since installation"
        case .integrityCompromised:
            return "App integrity checks have failed"
        }
    }
}

#Preview {
    SecurityGateView(
        securityReport: SecurityReport(
            jailbroken: true,
            debuggerAttached: false,
            reverseEngineered: false,
            simulator: true,
            tampered: false,
            integrityCompromised: false,
            overallSecure: false,
            warnings: [.jailbroken, .simulator]
        ),
        onContinue: {},
        onExit: {}
    )
}