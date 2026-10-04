//
//  PremiumCrownBadge.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//

import SwiftUI

struct PremiumCrownBadge: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.surface)
                .frame(width: 52, height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.gradientPurple.opacity(0.6), lineWidth: 1.5)
                )
                .overlay(
                    Image(systemName: "crown.fill")
                        .foregroundStyle(Theme.gold)
                )
                .shadow(color: Theme.glowColor, radius: 10)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    PremiumCrownBadge { }
}
