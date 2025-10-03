//
//  CurrencyConverterView.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import SwiftUI

struct CurrencyConverterView: View {
    
    @Environment(CurrencyManager.self) private var currencyManager
    @Environment(LogManager.self) private var logManager
    
    @State private var fromCurrency: Currency = .pln
    @State private var toCurrency: Currency = .uah
    @State private var amountString: String = "100.00"
    @State private var convertedAmountString: String = ""
    @State private var conversionRate: Double = 0.0
    @State private var isConverting: Bool = false
    @State private var conversionError: String?
    
    @State private var showFromPicker: Bool = false
    @State private var showToPicker: Bool = false
    
    @State private var showTopBanner: Bool = false
    @State private var topBannerMessage: String = ""
    
    // Debounce timer for API calls
    @State private var conversionTask: Task<Void, Never>?
    
    private var amount: Double { parseAmount(amountString) ?? 0.0 }
    private var isOverLimit: Bool { amount > 0 && amount > fromCurrency.limit }
    
    var body: some View {
        screen
    }
    
    // MARK: - Screen
    
    private var screen: some View {
        ScrollView {
            VStack(spacing: 16) {
                bannerArea
                converterCard
                limitWarning
                Spacer(minLength: 10)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFromPicker) { fromPickerSheet }
        .sheet(isPresented: $showToPicker) { toPickerSheet }
        .onAppear { performInitialConversion() }
        .onChange(of: fromCurrency) { _, _ in performConversionWithDebounce() }
        .onChange(of: toCurrency) { _, _ in performConversionWithDebounce() }
        .onChange(of: amountString) { _, _ in performConversionWithDebounce() }
    }
    
    // MARK: - Banner Area
    
    private var bannerArea: some View {
        Group {
            if showTopBanner {
                BannerView(
                    style: .error,
                    title: "No network",
                    message: topBannerMessage.isEmpty ? "Check your internet connection" : topBannerMessage,
                    onClose: { withAnimation { showTopBanner = false } }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Converter Card
    
    private var converterCard: some View {
        VStack(spacing: 0) {
            sendingCard
            receivingCard
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(rateBadgeOverlay, alignment: .bottom)
        .overlay(loadingOverlay)
    }
    
    private var sendingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sending from")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            HStack {
                currencyButton(
                    flag: fromCurrency.flagImageName,
                    code: fromCurrency.code,
                    action: { showFromPicker = true }
                )
                Spacer()
                editableAmountView
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(limitBorderOverlay)
    }
    
    private var receivingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Receiver gets")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            HStack {
                currencyButton(
                    flag: toCurrency.flagImageName,
                    code: toCurrency.code,
                    action: { showToPicker = true }
                )
                Spacer()
                convertedAmountView
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - UI Components
    
    private func currencyButton(flag: String, code: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                flagView(flag: flag)
                Text(code)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(.plain)
        .disabled(isConverting)
    }
    
    private func flagView(flag: String) -> some View {
        Image(flag)
            .resizable()
            .frame(width: 24, height: 16)
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
    
    private var editableAmountView: some View {
        EditableAmountView(
            amountString: $amountString,
            placeholder: "0.00",
            isOverLimit: isOverLimit,
            isEditable: true
        )
        .disabled(isConverting)
    }
    
    private var convertedAmountView: some View {
        EditableAmountView(
            amountString: .constant(convertedAmountString),
            placeholder: "0.00",
            isOverLimit: false,
            isEditable: false
        )
    }
    
    private var rateBadgeOverlay: some View {
        Group {
            if conversionRate > 0 && !isConverting {
                Text("1 \(fromCurrency.code) = \(conversionRate, specifier: "%.4f") \(toCurrency.code)")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .offset(y: -30)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: conversionRate)
    }
    
    private var loadingOverlay: some View {
        Group {
            if isConverting {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.1))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                    )
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var limitBorderOverlay: some View {
        Group {
            if isOverLimit {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.95, green: 0.0, blue: 0.35), lineWidth: 1.5)
                    .animation(.easeInOut(duration: 0.2), value: isOverLimit)
            }
        }
    }
    
    private var limitWarning: some View {
        Group {
            if isOverLimit {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color(red: 0.95, green: 0.0, blue: 0.35))
                    Text("Maximum sending amount: \(formatAmount(fromCurrency.limit)) \(fromCurrency.code)")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.95, green: 0.0, blue: 0.35))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 1.0, green: 0.9, blue: 0.9))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isOverLimit)
    }
    
    // MARK: - Sheets
    
    private var fromPickerSheet: some View {
        NavigationStack {
            CurrencyPickerView(title: "Sending from") { currency in
                fromCurrency = currency
                showFromPicker = false
            }
        }
    }
    
    private var toPickerSheet: some View {
        NavigationStack {
            CurrencyPickerView(title: "Receiving to") { currency in
                toCurrency = currency
                showToPicker = false
            }
        }
    }
    
    // MARK: - Conversion Logic
    
    private func performInitialConversion() {
        guard amount > 0 else { return }
        performConversion()
    }
    
    private func performConversionWithDebounce() {
        // Cancel previous task
        conversionTask?.cancel()
        
        // Create new debounced task
        conversionTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            
            if !Task.isCancelled {
                await MainActor.run {
                    performConversion()
                }
            }
        }
    }
    
    private func performConversion() {
        guard let amt = parseAmount(amountString), amt > 0 else {
            convertedAmountString = ""
            conversionRate = 0
            return
        }
        
        // Don't convert if over limit
        if amt > fromCurrency.limit {
            convertedAmountString = ""
            conversionRate = 0
            return
        }
        
        Task {
            await MainActor.run {
                isConverting = true
                conversionError = nil
                showTopBanner = false
            }
            
            do {
                let conversion = try await currencyManager.convertCurrency(
                    from: fromCurrency.code,
                    to: toCurrency.code,
                    amount: amt
                )
                
                await MainActor.run {
                    convertedAmountString = formatConvertedAmount(conversion.convertedAmount)
                    conversionRate = conversion.rate
                    isConverting = false
                }
            } catch {
                await MainActor.run {
                    isConverting = false
                    conversionRate = 0
                    convertedAmountString = ""
                    topBannerMessage = error.localizedDescription
                    showTopBanner = true
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseAmount(_ string: String) -> Double? {
        guard !string.isEmpty else { return nil }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        // Handle both comma and dot as decimal separator
        let normalizedString = string.replacingOccurrences(of: ",", with: ".")
        
        return formatter.number(from: normalizedString)?.doubleValue
    }
    
    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.groupingSize = 3
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f", value)
    }
    
    private func formatConvertedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

#Preview {
    NavigationStack {
        CurrencyConverterView()
            .previewEnvironment()
    }
}
