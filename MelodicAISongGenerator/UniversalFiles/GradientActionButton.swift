//
//  GradientActionButton.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import SwiftUI


struct GradientActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(Theme.Typography.buttonTitle)
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Theme.brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
            .shadow(color: Theme.glowColor, radius: 16, y: 6)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    GradientActionButton(title: "Test", systemImage: "xmark") {
        
    }
}
