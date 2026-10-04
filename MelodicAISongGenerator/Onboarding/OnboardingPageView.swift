//
//  OnboardingPageView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 17.08.2026.
//

import SwiftUI


struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let onAdvance: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)
            
            placeholderArtwork
            
            Spacer(minLength: 32)
            
            titleText
                .font(.system(size: AdaptiveFontSize.adaptive32, weight: .heavy))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
            
            Text(page.subtitle)
                .font(.system(size: AdaptiveFontSize.adaptive15, weight: .regular))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 24)
            
            Spacer(minLength: 24)
            
            ctaButton
                .padding(.horizontal, Theme.Layout.screenPadding)
        }
        .padding(.top, 60)
        .padding(.bottom, 28)
    }
    
    
    private var placeholderArtwork: some View {
        ZStack {
            VStack(spacing: 1) {
                Image(page.placeholderIcon)
                    .resizable()
            }
        }
        .id(page.id)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
    
    
    private var titleText: Text {
        page.titleParts.reduce(Text("")) { partial, part in
            partial + Text(part.text)
                .foregroundColor(part.isHighlighted ? page.accentColor : Theme.textPrimary)
        }
    }
    
    
    private var ctaButton: some View {
        Button(action: onAdvance) {
            HStack {
                Spacer()
                Text(page.buttonTitle)
                    .font(.system(size: AdaptiveFontSize.adaptive17, weight: .bold))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: AdaptiveFontSize.adaptive15, weight: .semibold))
            }
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, 22)
            .frame(height: 56)
            .background(isLastPage ? Theme.brandGradient : Theme.selectionGradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
            .shadow(color: Theme.glowColor, radius: 14, y: 6)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    ForEach(OnboardingPage.all) { page in
        OnboardingPageView(
            page: page,
            isLastPage: page.id == OnboardingPage.all.count - 1,
            onAdvance: {  }
        )
        .tag(page.id)
    }
}
