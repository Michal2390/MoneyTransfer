//
//  CurrencyPickerView.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 02/10/2025.
//

import SwiftUI

struct CurrencyPickerView: View {
    let title: String
    let currencies: [Currency]
    let onSelect: (Currency) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    
    init(title: String, currencies: [Currency] = Currency.all, onSelect: @escaping (Currency) -> Void) {
        self.title = title
        self.currencies = currencies
        self.onSelect = onSelect
    }
    
    private var filtered: [Currency] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return currencies }
        let q = trimmed.lowercased()
        return currencies.filter {
            $0.name.lowercased().contains(q)
            || $0.country.lowercased().contains(q)
            || $0.code.lowercased().contains(q)
        }
    }
    
    var body: some View {
        listBody
            .navigationTitle(title)
            .toolbar { pickerToolbar }
    }
    
    private var listBody: some View {
        List {
            searchSection
            countriesSection
        }
        .listStyle(.insetGrouped)
    }
    
    private var searchSection: some View {
        Section("Search") {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
    }
    
    private var countriesSection: some View {
        Section("All countries") {
            ForEach(filtered, id: \.self) { currency in
                row(for: currency)
            }
        }
    }
    
    private func row(for currency: Currency) -> some View {
        Button {
            onSelect(currency)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                flagBubble(for: currency)
                titles(for: currency)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func flagBubble(for currency: Currency) -> some View {
        Image(currency.flagImageName)
            .resizable()
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            .background(Circle().fill(Color.gray.opacity(0.15)))
    }
    
    private func titles(for currency: Currency) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(currency.country)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
            Text("\(currency.name) • \(currency.code)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ToolbarContentBuilder
    private var pickerToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Close") { dismiss() }
        }
    }
}