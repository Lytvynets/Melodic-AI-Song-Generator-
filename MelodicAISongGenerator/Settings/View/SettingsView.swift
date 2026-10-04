//
//  SettingsView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 01.08.2026.
//


import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var inAppPurchaseViewModel: InAppPurchaseViewModel
    
    @State private var showNotificationAlert = false
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack {
                    HStack {
                        title
                        Spacer()
                    }
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
                
                if !inAppPurchaseViewModel.isSubscribed {
                    VStack {
                        premiumBanner
                    }
                }
                
                VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                    generalSection
                    supportSection
                    legalSection
                    footer
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showPaywall, content: {
            PaywallView()
                .onDisappear {
                    Task {
                        for sub in inAppPurchaseViewModel.products {
                            inAppPurchaseViewModel.isSubscribed = await inAppPurchaseViewModel.checkSubscriptionStatus(for: sub.id)
                        }
                    }
                }

        })
        .onAppear {
            let notificationsIsOn = UserDefaults.standard.object(forKey: "notificationsIsOn") as? Bool ?? false
            settingsViewModel.notificationsIsOn = notificationsIsOn
            
        }
        .sheet(isPresented: $settingsViewModel.showShareSheet, content: {
            if let url = URL(string: AppDefaults.appURL) {
                ShareSheetURL(activityItems: [url])
            }
        })
        .alert("Enable Notifications", isPresented: $showNotificationAlert) {
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Cancel", role: .cancel) { }
            
        } message: {
            Text("Notifications are disabled. Please enable them in Settings to receive reminders.")
        }
    }
    
    
    private var title: some View {
        Text("Settings")
            .font(Theme.Typography.screenTitle)
            .foregroundStyle(Theme.textPrimary)
    }
    
    
    private var premiumBanner: some View {
        VStack {
            Image("premiumBanner")
                .resizable()
                .frame(height: 160)
                .scaledToFit()
                .onTapGesture {
                    openPremium()
                }
        }
    }
    
    
    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionCapsHeader(title: "General")
            
            SettingsCard {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Manage push notifications"
                ) {
                    ToggleSwitchView(isOn: $settingsViewModel.notificationsIsOn)
                        .onChange(of: settingsViewModel.notificationsIsOn) { isOn in
                            if isOn {
                                handleNotificationToggle()
                            } else {
                                NotificationManager.shared.disableNotifications()
                            }
                        }
                }
            }
        }
    }
    
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionCapsHeader(title: "Support")
            
            SettingsCard {
                SettingsRow(
                    icon: "arrow.counterclockwise",
                    title: "Restore Purchases",
                    subtitle: "Recover your premium purchase",
                    accessory: { ChevronAccessory() }
                )
                .onTapGesture(perform: restorePurchases)
                
                RowDivider()
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Rate the App",
                    subtitle: "Support us by leaving a review",
                    accessory: { ChevronAccessory() }
                )
                .onTapGesture(perform: rateApp)
                
                RowDivider()
                
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Share the App",
                    subtitle: "Tell your friends about Melodic",
                    accessory: { ChevronAccessory() }
                )
                .onTapGesture(perform: shareApp)
                
                RowDivider()
                
                SettingsRow(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Contact Support",
                    subtitle: "We're here to help",
                    accessory: { ChevronAccessory() }
                )
                .onTapGesture(perform: contactSupport)
            }
        }
    }
    
    
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionCapsHeader(title: "Legal")
            
            SettingsCard {
                SettingsRow(
                    icon: "checkmark.shield.fill",
                    title: "Terms of Use",
                    subtitle: "",
                    accessory: { ChevronAccessory() }
                )
                .onTapGesture(perform: openTerms)
                
                RowDivider()
                
                SettingsRow(
                    icon: "lock.fill",
                    title: "Privacy Policy",
                    subtitle: "",
                    accessory: { ChevronAccessory() }
                )
                .onTapGesture(perform: openPrivacyPolicy)
            }
        }
    }
    
    
    private var footer: some View {
        VStack(spacing: 4) {
            Text("Melodic 1.0.0")
            Text("All songs are stored locally on this device.")
        }
        .font(Theme.Typography.footer)
        .foregroundStyle(Theme.textSecondary)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
    
    
    func handleNotificationToggle() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            DispatchQueue.main.async {
                
                switch settings.authorizationStatus {
                    
                case .authorized:
                    print("authorized")
                    
                case .notDetermined:
                    Task {
                        let granted = await NotificationManager.shared.requestPermission()
                        
                        await MainActor.run {
                            settingsViewModel.notificationsIsOn = granted
                        }
                    }
                    
                case .denied:
                    settingsViewModel.notificationsIsOn = false
                    showNotificationAlert = true
                    
                default:
                    settingsViewModel.notificationsIsOn = false
                }
            }
        }
    }
    
    
    private func openPremium() {
        showPaywall = true
    }
    
    
    private func restorePurchases() {
        Task {
            await inAppPurchaseViewModel.restorePurchases()
        }
    }
    
    private func rateApp() {
        settingsViewModel.requestReview()
    }
    
    private func shareApp() {
        settingsViewModel.showShareSheet = true
    }
    
    private func contactSupport() {
        settingsViewModel.openURL(AppDefaults.supportURL)
    }
    
    
    private func openTerms() {
        settingsViewModel.openURL(AppDefaults.termsOfUseURL)
    }
    
    private func openPrivacyPolicy() {
        settingsViewModel.openURL(AppDefaults.privacyPolicyURL)
    }
}


#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(InAppPurchaseViewModel())
}


struct ShareSheetURL: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
