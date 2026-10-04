//
//  PaywallView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//


import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var inAppPurchaseViewModel: InAppPurchaseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPlan: PricingPlan = .weekly
    @State private var glowPulse = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    closeButton
                    crownArtwork
                    titleBlock
                    featureRow
                        .padding(.top, 20)
                    
                    pricingCards
                        .padding(.top, 22)
                    
                    ctaButton
                        .padding(.top, 22)
                    
                    footer
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            
        }
        .overlay {
            if inAppPurchaseViewModel.isLoading {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(0.5)
                    
                    ProgressView()
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
    
    
    private var closeButton: some View {
        HStack {
            Button(action: {dismiss()}) {
                Circle()
                    .fill(Theme.surfaceMuted)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: AdaptiveFontSize.adaptive15, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    
    private var crownArtwork: some View {
        ZStack {
            Circle()
                .fill(Theme.gradientPurple.opacity(0.35))
                .frame(width: 240, height: 240)
                .blur(radius: 34)
                .scaleEffect(glowPulse ? 1.12 : 0.94)
            
            VStack(spacing: 0) {
                Image("premLogo")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.gradientPink, Theme.gradientPurple, Theme.gradientBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Theme.gradientPurple.opacity(0.8), radius: 18)
            }
        }
        .frame(height: 160)
    }
    
    
    private var titleBlock: some View {
        VStack(spacing: 8) {
            (
                Text("Unlock ")
                    .foregroundStyle(Theme.textPrimary)
                +
                Text("Premium")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.gradientPurple, Theme.gradientBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .font(.system(size: AdaptiveFontSize.adaptive31, weight: .heavy))
        }
    }
    
    
    private var featureRow: some View {
        HStack(spacing: 0) {
            ForEach(PremiumFeatureHighlight.all) { feature in
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(feature.tint.opacity(0.16))
                        .frame(width: 62, height: 62)
                        .overlay(
                            Image(feature.systemImage)
                                .resizable()
                                .frame(width: 42, height: 42)
                            
                        )
                    
                    Text(feature.title)
                        .font(.system(size: AdaptiveFontSize.adaptive10, weight: .regular))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 25)
    }
    
    
    private var pricingCards: some View {
        VStack(spacing: 14) {
            ForEach(PricingPlan.allCases) { plan in
                PricingCardView(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        selectedPlan = plan
                        switch selectedPlan {
                        case .weekly:
                            inAppPurchaseViewModel.selectedProductId = AppDefaults.freeTrailWeekly
                        case .monthly:
                            inAppPurchaseViewModel.selectedProductId = AppDefaults.freeTrailMonthly
                        case .yearly:
                            inAppPurchaseViewModel.selectedProductId = AppDefaults.freeTrailYearly
                        }
                    }
                )
            }
        }
    }
    
    
    private var ctaButton: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            inAppPurchaseViewModel.isLoading = true
            Task {
                if let product = inAppPurchaseViewModel.products.first(where: {$0.id == inAppPurchaseViewModel.selectedProductId }) {
                    await inAppPurchaseViewModel.purchase(product) { result in
                        switch result {
                        case .success(_):
                            inAppPurchaseViewModel.isLoading = false
                            dismiss()
                        case .failure(_):
                            inAppPurchaseViewModel.isLoading = false
                            inAppPurchaseViewModel.presentErrorAlert = true
                        }
                    }
                }
            }
        }) {
            VStack {
                
                HStack {
                    Spacer()
                    Text("Start Free Trial")
                        .font(.system(size: AdaptiveFontSize.adaptive18, weight: .bold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: AdaptiveFontSize.adaptive16, weight: .semibold))
                }
                
                Text("Cancel anytime. No commitment.")
                    .font(.system(size: AdaptiveFontSize.adaptive13, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
            }
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(Theme.brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
            .shadow(color: Theme.glowColor, radius: 16, y: 6)
        }
        .buttonStyle(.plain)
    }
    
    
    private var footer: some View {
        VStack(spacing: 12) {
            
            
            HStack(spacing: 8) {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    Task {
                        await inAppPurchaseViewModel.restorePurchases()
                    }
                }) {
                    Text("Restore")
                }
                
                Text("|").foregroundStyle(Theme.textSecondary.opacity(0.4))
                
                Button(action: { settingsViewModel.openURL(AppDefaults.termsOfUseURL)}) {
                    Text("Terms of Use")
                }
                
                Text("|").foregroundStyle(Theme.textSecondary.opacity(0.4))
                
                Button(action: {settingsViewModel.openURL(AppDefaults.privacyPolicyURL)}) {
                    Text("Privacy Policy")
                }
            }
            .font(.system(size: AdaptiveFontSize.adaptive12, weight: .regular))
            .foregroundStyle(Theme.textSecondary.opacity(0.75))
            .buttonStyle(.plain)
        }
    }
}


#Preview {
    PaywallView()
        .environmentObject(SettingsViewModel())
        .environmentObject(InAppPurchaseViewModel())
}
