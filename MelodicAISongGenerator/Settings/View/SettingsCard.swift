//
//  SettingsCard.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 16.08.2026.
//

import SwiftUI

struct ChevronAccessory: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: AdaptiveFontSize.adaptive14, weight: .semibold))
            .foregroundStyle(Theme.textSecondary.opacity(0.6))
    }
}


struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }
}


struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.rowDivider)
            .frame(height: 1)
            .padding(.leading, 58)
    }
}


struct SectionCapsHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(Theme.Typography.sectionCaps)
            .tracking(0.5)
            .foregroundStyle(Theme.sectionCapsColor)
            .padding(.leading, 4)
    }
}


#Preview {
    SettingsCard() {}
}
