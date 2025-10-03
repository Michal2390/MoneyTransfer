//
//  AppView.swift
//  MoneyTransfer
//
//  Created by Michal Fereniec on 01/10/2025.
//
import SwiftUI

struct BannerView: View {
    enum Style {
        case error, info
    }
    
    let style: Style
    let title: String
    let message: String
    let onClose: () -> Void
    
    var body: some View {
        container
    }
    
    private var container: some View {
        HStack(alignment: .top, spacing: 12) {
            iconView
            textStack
            Spacer(minLength: 8)
            closeButton
        }
        .padding(12)
        .background(backgroundShape)
        .overlay(borderShape)
    }
    
    private var iconView: some View {
        Image(systemName: style == .error ? "xmark.circle.fill" : "info.circle.fill")
            .foregroundStyle(style == .error ? Color.red : Color.blue)
            .font(.title3)
    }
    
    private var textStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
        }
    }
    
    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .foregroundStyle(.secondary)
                .font(.footnote.weight(.semibold))
        }
    }
    
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke((style == .error ? Color.red : Color.blue).opacity(0.15), lineWidth: 1)
    }
}
