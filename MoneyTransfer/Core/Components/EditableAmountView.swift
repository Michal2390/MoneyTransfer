//
//  EditableAmountView.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 02/10/2025.
//

import SwiftUI
import Combine

struct EditableAmountView: View {
    @Binding var amountString: String
    let placeholder: String
    let isOverLimit: Bool
    let isEditable: Bool
    
    @FocusState private var isFocused: Bool
    @State private var textWidth: CGFloat = 100
    
    private var limitColor: Color {
        Color(red: 0.95, green: 0.0, blue: 0.35)
    }
    
    private var textColor: Color {
        if isOverLimit {
            return limitColor
        }
        return .primary
    }
    
    var body: some View {
        Group {
            if isEditable {
                editableTextField
            } else {
                displayText
            }
        }
    }
    
    private var editableTextField: some View {
        HStack(spacing: 0) {
            TextField(placeholder, text: $amountString)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(textColor)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .onReceive(Just(amountString)) { _ in
                    validateAndFormatInput()
                }
                .background(
                    Text(amountString.isEmpty ? placeholder : amountString)
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.clear)
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                textWidth = geometry.size.width
                            }
                        })
                )
                .frame(minWidth: max(textWidth, 60))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
    
    private var displayText: some View {
        Text(amountString.isEmpty ? placeholder : amountString)
            .font(.system(size: 28, weight: .bold, design: .default))
            .foregroundColor(textColor)
    }
    
    private func validateAndFormatInput() {
        // Remove any non-numeric characters except decimal point
        let filtered = amountString.filter { $0.isNumber || $0 == "." || $0 == "," }
        
        // Handle multiple decimal points
        let components = filtered.components(separatedBy: CharacterSet(charactersIn: ".,"))
        if components.count > 2 {
            // Keep only first decimal point
            let integerPart = components.first ?? ""
            let decimalPart = components.dropFirst().joined()
            let normalizedDecimal = String(decimalPart.prefix(2)) // Max 2 decimal places
            amountString = integerPart + "." + normalizedDecimal
        } else if filtered != amountString {
            amountString = filtered.replacingOccurrences(of: ",", with: ".")
        }
        
        // Limit decimal places to 2
        if let dotIndex = amountString.firstIndex(of: ".") {
            let afterDot = amountString[dotIndex...]
            if afterDot.count > 3 { // dot + 2 decimal places
                let endIndex = amountString.index(dotIndex, offsetBy: 3)
                amountString = String(amountString[..<endIndex])
            }
        }
        
        // Prevent leading zeros (except for "0." or just "0")
        if amountString.hasPrefix("0") && amountString.count > 1 && !amountString.hasPrefix("0.") {
            amountString = String(amountString.dropFirst())
        }
        
        // Limit to reasonable maximum length (e.g., 10 digits before decimal)
        if let dotIndex = amountString.firstIndex(of: ".") {
            let beforeDot = String(amountString[..<dotIndex])
            if beforeDot.count > 10 {
                amountString = String(beforeDot.prefix(10)) + String(amountString[dotIndex...])
            }
        } else if amountString.count > 10 {
            amountString = String(amountString.prefix(10))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EditableAmountView(
            amountString: .constant("100.00"),
            placeholder: "0.00",
            isOverLimit: false,
            isEditable: true
        )
        
        EditableAmountView(
            amountString: .constant("25000"),
            placeholder: "0.00",
            isOverLimit: true,
            isEditable: true
        )
        
        EditableAmountView(
            amountString: .constant("723.38"),
            placeholder: "0.00",
            isOverLimit: false,
            isEditable: false
        )
    }
    .padding()
}