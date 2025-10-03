//
//  SecureAppView.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 02/10/2025.
//

import SwiftUI

struct SecureAppView: View {
    @Environment(SecurityManager.self) private var securityManager
    @Environment(LogManager.self) private var logManager
    
    @State private var showSecurityGate: Bool = true
    @State private var securityCheckCompleted: Bool = false
    
    var body: some View {
        Group {
            if showSecurityGate && securityCheckCompleted {
                SecurityGateView(
                    securityReport: securityManager.getSecurityReport(),
                    onContinue: {
                        if securityManager.shouldAllowAppExecution() {
                            withAnimation(.easeInOut) {
                                showSecurityGate = false
                            }
                        }
                    },
                    onExit: {
                        // In a real app, you might want to call exit(0) or show a different screen
                        logManager.trackEvent(event: SecurityManager.Event.securityThreatDetected(
                            threat: .criticalThreat
                        ))
                        // For now, we'll just keep showing the security gate
                    }
                )
            } else if !showSecurityGate {
                AppView()
            } else {
                // Loading screen while security checks are running
                securityLoadingView
            }
        }
        .onAppear {
            performInitialSecurityCheck()
        }
    }
    
    private var securityLoadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Checking Device Security...")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Please wait while we verify your device meets our security requirements.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func performInitialSecurityCheck() {
        Task {
            // Add a small delay to show the loading screen
            try? await Task.sleep(for: .seconds(1))
            
            await MainActor.run {
                securityManager.performSecurityChecks()
                securityCheckCompleted = true
                
                // If security checks pass and no warnings, skip the gate
                if securityManager.shouldAllowAppExecution() && securityManager.securityWarnings.isEmpty {
                    showSecurityGate = false
                }
            }
        }
    }
}

#Preview {
    SecureAppView()
        .previewEnvironment()
}
