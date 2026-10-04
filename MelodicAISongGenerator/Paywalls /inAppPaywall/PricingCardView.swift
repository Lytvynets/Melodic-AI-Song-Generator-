//
//  PricingCardView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 18.08.2026.
//

import SwiftUI


struct PricingCardView: View {
    let plan: PricingPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                HStack(spacing: 14) {
                    radio
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title)
                            .font(.system(size: AdaptiveFontSize.adaptive17, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text(plan.trialText)
                            .font(.system(size: AdaptiveFontSize.adaptive14, weight: .semibold))
                            .foregroundStyle(plan.accentColor)
                        
                        Text(plan.thenText)
                            .font(.system(size: AdaptiveFontSize.adaptive12, weight: .regular))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    
                    Spacer(minLength: 8)
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(plan.price)
                            .font(.system(size: AdaptiveFontSize.adaptive17, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text(plan.periodLabel)
                            .font(.system(size: AdaptiveFontSize.adaptive12, weight: .regular))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(14)
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
            .overlay(border)
            .shadow(color: isSelected ? plan.accentColor.opacity(0.35) : .clear, radius: 14, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    
    private var radio: some View {
        ZStack {
            Circle()
                .stroke(plan.accentColor, lineWidth: 2)
                .frame(width: 24, height: 24)
            
            if isSelected {
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
            }
        }
    }
    
    
    @ViewBuilder
    private var cardBackground: some View {
        if plan.isHighlighted {
            LinearGradient(
                colors: [plan.accentColor.opacity(isSelected ? 0.22 : 0.1), Theme.gradientBlue.opacity(isSelected ? 0.16 : 0.06)],
                startPoint: .leading, endPoint: .trailing
            )
        } else {
            (isSelected ? plan.accentColor.opacity(0.12) : Theme.surface)
        }
    }
    
    @ViewBuilder
    private var border: some View {
        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
            .strokeBorder(
                plan.isHighlighted
                ? AnyShapeStyle(LinearGradient(colors: [Theme.gradientPink, Theme.gradientBlue], startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(isSelected ? plan.accentColor : Theme.stroke),
                lineWidth: plan.isHighlighted ? 1.6 : (isSelected ? 1.6 : 1)
            )
    }
}


#Preview {
    PricingCardView(plan: .yearly, isSelected: true) {}
}
