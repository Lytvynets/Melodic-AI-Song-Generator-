//
//  SettingsRow.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 16.08.2026.
//

import SwiftUI

struct SettingsRow<Accessory: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder var accessory: () -> Accessory

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemImage: icon)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(Theme.Typography.rowTitle)
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(Theme.Typography.rowSubtitle)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: 8)

            accessory()
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsRow(icon: "gear", title: "Test", subtitle: "Test") {}
}
