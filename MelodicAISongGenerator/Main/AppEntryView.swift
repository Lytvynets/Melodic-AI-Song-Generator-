//
//  AppEntryView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//

import SwiftUI
import StoreKit


private enum AppFlowStep {
    case splash
    case onboarding
    case paywall
    case main
}


struct AppEntryView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var step: AppFlowStep = .splash
    @EnvironmentObject private var inAppPurchaseViewModel: InAppPurchaseViewModel


    var body: some View {
        ZStack {
            switch step {
            case .splash:
                SplashScreenView {
                    advanceAfterSplash()
                }
                .transition(.opacity)
                .onAppear {
                    Task {
                        await inAppPurchaseViewModel.fetchProducts()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            Task {
                                for sub in inAppPurchaseViewModel.products {
                                    inAppPurchaseViewModel.isSubscribed = await inAppPurchaseViewModel.checkSubscriptionStatus(for: sub.id)
                                }
                            }
                            
                            AppDefaults.weeklyPrice = "\(inAppPurchaseViewModel.getPrice(productID: AppDefaults.freeTrailWeekly, products: inAppPurchaseViewModel.products))"
                            
                            AppDefaults.monthlyPrice = "\(inAppPurchaseViewModel.getPrice(productID: AppDefaults.freeTrailMonthly, products: inAppPurchaseViewModel.products))"
                            
                            AppDefaults.yearlyPrice = "\(inAppPurchaseViewModel.getPrice(productID: AppDefaults.freeTrailYearly, products: inAppPurchaseViewModel.products))"
                            
                        }
                    }
                }

            case .onboarding:
                OnboardingView {
                    hasCompletedOnboarding = true
                    withAnimation(.easeInOut(duration: 0.4)) {
                        step = inAppPurchaseViewModel.isSubscribed ? .main : .paywall
                    }
                }
                .transition(.opacity)
                .onDisappear {
                    Task {
                        for sub in inAppPurchaseViewModel.products {
                            inAppPurchaseViewModel.isSubscribed = await inAppPurchaseViewModel.checkSubscriptionStatus(for: sub.id)
                        }
                    }
                }


            case .paywall:
                PaywallOnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        step = .main
                    }
                }
                .onDisappear {
                    Task {
                        for sub in inAppPurchaseViewModel.products {
                            inAppPurchaseViewModel.isSubscribed = await inAppPurchaseViewModel.checkSubscriptionStatus(for: sub.id)
                        }
                    }
                }
                

            case .main:
                RootView()
                    .transition(.opacity)
            }
        }
    }

    
    private func advanceAfterSplash() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if !hasCompletedOnboarding {
                step = .onboarding              
            } else if !inAppPurchaseViewModel.isSubscribed {
                step = .paywall
            } else {
                step = .main
            }
        }
    }
}


#Preview {
    AppEntryView()
}
