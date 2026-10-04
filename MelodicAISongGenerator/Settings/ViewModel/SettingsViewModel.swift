//
//  SettingsViewModel.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 20.08.2026.
//

import Foundation
import UIKit
import StoreKit
internal import Combine

class SettingsViewModel: ObservableObject {
  
    @Published var notificationsIsOn: Bool {
        didSet {
            UserDefaults.standard.set(notificationsIsOn, forKey: "notificationsIsOn")
        }
    }
    
    
    @Published var showShareSheet = false
    
  
    init() {
        let notificationsIsOn = UserDefaults.standard.object(forKey: "notificationsIsOn") as? Bool ?? false
        self.notificationsIsOn = notificationsIsOn
    }
    
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
