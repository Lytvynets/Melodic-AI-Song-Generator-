//
//  OnboardingFeatureRow.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 18.08.2026.
//

import SwiftUI

struct OnboardingFeatureRow: View {
    let feature: OnboardingPremiumFeature
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(feature.tint.opacity(0.1))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(feature.systemImage)
                        .resizable()
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: AdaptiveFontSize.adaptive15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                
                Text(feature.description)
                    .font(.system(size: AdaptiveFontSize.adaptive13, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }
}


#Preview {
    ForEach( OnboardingPremiumFeature.all) { feature in
        OnboardingFeatureRow(feature: feature)
    }
}
