//
//  IconChipView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import SwiftUI

struct IconChipView: View {
    let title: String
    let systemImage: String
    let iconColor: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(Theme.Typography.chip)
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(isSelected ? Theme.surfaceMuted.opacity(0.9) : Theme.surfaceMuted)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Theme.gradientPurple.opacity(0.8) : Theme.stroke,
                            lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    IconChipView(title: "Test", systemImage: "gear", iconColor: .red, isSelected: true) { }
}
