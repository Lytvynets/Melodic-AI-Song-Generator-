//
//  PaywallOnboardingView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//


import SwiftUI
import StoreKit

struct PaywallOnboardingView: View {
    
    var dismissPaywall: () -> Void = {}
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var inAppPurchaseViewModel: InAppPurchaseViewModel
    
    @State private var glowPulse = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            Image("onbBackground")
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    titleBlock
                        .padding(.top, 24)
                    
                    crownArtwork
                        .padding(.top, 24)
                    
                    featureList
                        .padding(.top, 8)
                    
                    ctaCard
                        .padding(.top, 24)
                    
                    footer
                        .padding(.top, 18)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
    
    
    private var titleBlock: some View {
        ZStack {
            VStack(spacing: 10) {(
                Text("Unlock ")
                    .foregroundStyle(Theme.textPrimary)
                +
                Text("Premium")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.gradientPink, Theme.gradientPurple, Theme.gradientBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .font(.system(size: AdaptiveFontSize.adaptive34, weight: .heavy))
                
                Text("Get everything you need\nto create amazing music")
                    .font(.system(size: AdaptiveFontSize.adaptive14, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Spacer()
                Button {
                    dismissPaywall()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    
    private var crownArtwork: some View {
        ZStack {
            Circle()
                .fill(Theme.gradientPink.opacity(0.35))
                .frame(width: 170, height: 170)
                .blur(radius: 40)
                .scaleEffect(glowPulse ? 1.1 : 0.92)
            
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
                    .shadow(color: Theme.gradientPink.opacity(0.7), radius: 22)
            }
        }
    }
    
    
    private var featureList: some View {
        VStack(spacing: 14) {
            ForEach(OnboardingPremiumFeature.all) { feature in
                OnboardingFeatureRow(feature: feature)
            }
        }
    }
    
    
    private var ctaCard: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            inAppPurchaseViewModel.selectedProductId = AppDefaults.freeTrailWeekly
            inAppPurchaseViewModel.isLoading = true
            Task {
                if let product = inAppPurchaseViewModel.products.first(where: {$0.id == inAppPurchaseViewModel.selectedProductId }) {
                    await inAppPurchaseViewModel.purchase(product) { result in
                        switch result {
                        case .success(_):
                            inAppPurchaseViewModel.isLoading = false
                            dismissPaywall()
                        case .failure(_):
                            inAppPurchaseViewModel.isLoading = false
                            inAppPurchaseViewModel.presentErrorAlert = true
                        }
                    }
                }
            }
        }) {
            ZStack {
                VStack(spacing: 4) {
                    Text("3-DAY FREE TRIAL")
                        .font(.system(size: AdaptiveFontSize.adaptive10, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())
                    
                    Text("Start Free Trial")
                        .font(.system(size: AdaptiveFontSize.adaptive20, weight: .heavy))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("Then \(inAppPurchaseViewModel.getPrice(productID: AppDefaults.freeTrailWeekly, products: inAppPurchaseViewModel.products)) per week • Cancel anytime")
                        .font(.system(size: AdaptiveFontSize.adaptive13, weight: .regular))
                        .foregroundStyle(Theme.textPrimary.opacity(0.85))
                }
                
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.system(size: AdaptiveFontSize.adaptive17, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                        )
                }
                .padding(.trailing, 18)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Theme.gradientPurple, Theme.gradientPink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
            .shadow(color: Theme.glowColor, radius: 20, y: 8)
        }
        .buttonStyle(.plain)
    }
    
    
    private var footer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button(action: {settingsViewModel.openURL(AppDefaults.termsOfUseURL)}) {
                    Text("Terms of Use")
                }
                
                Text("•").foregroundStyle(Theme.textSecondary.opacity(0.5))
                Button(action: {settingsViewModel.openURL(AppDefaults.privacyPolicyURL)}) {
                    Text("Privacy Policy")
                }
                
                Text("•").foregroundStyle(Theme.textSecondary.opacity(0.5))
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    Task {
                        await inAppPurchaseViewModel.restorePurchases()
                    }
                }) {
                    Text("Restore")
                }
            }
            .font(.system(size: AdaptiveFontSize.adaptive13, weight: .regular))
            .foregroundStyle(Theme.textSecondary.opacity(0.8))
            .buttonStyle(.plain)
        }
    }
}


#Preview {
    PaywallOnboardingView()
        .environmentObject(SettingsViewModel())
        .environmentObject(InAppPurchaseViewModel())
}
