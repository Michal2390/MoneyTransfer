//
//  AppView.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 29/09/2025.
//

import SwiftUI

struct AppView: View {
    
    var body: some View {
        content
    }
    
    private var content: some View {
        NavigationStack {
            CurrencyConverterView()
                .navigationTitle("Currency Converter")
        }
    }
}

#Preview {
    AppView()
        .previewEnvironment()
}