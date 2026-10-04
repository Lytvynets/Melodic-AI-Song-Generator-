//
//  PricingPlan.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 18.08.2026.
//

import Foundation
import SwiftUI

enum PricingPlan: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Annual"
        }
    }
    
    var trialText: String { "3-day free trial" }
    
    var thenText: String {
        switch self {
        case .weekly: return "Then \(AppDefaults.weeklyPrice) per week"
        case .monthly: return "Then \(AppDefaults.monthlyPrice) per month"
        case .yearly: return "Then \(AppDefaults.yearlyPrice) per year"
        }
    }
    
    var price: String {
        switch self {
        case .weekly: return "\(AppDefaults.weeklyPrice)"
        case .monthly: return "\(AppDefaults.monthlyPrice)"
        case .yearly: return "\(AppDefaults.yearlyPrice)"
        }
    }
    
    var periodLabel: String {
        switch self {
        case .weekly: return "per week"
        case .monthly: return "per month"
        case .yearly: return "per year"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .weekly: return Theme.gradientPurple
        case .monthly: return Theme.gradientBlue
        case .yearly: return Theme.gradientPink
        }
    }
    
    var badge: String? {
        self == .yearly ? "BEST VALUE" : nil
    }
    
    var savings: String? {
        self == .yearly ? "Save 61%" : nil
    }
    
    var isHighlighted: Bool { self == .yearly }
}


struct PremiumFeatureHighlight: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let tint: Color
    
    static let all: [PremiumFeatureHighlight] = [
        PremiumFeatureHighlight(title: "Unlimited\ngenerations", systemImage: "pay1", tint: Theme.gradientPurple),
        PremiumFeatureHighlight(title: "Custom lyrics &\nvocal control", systemImage: "pay2", tint: Theme.gradientPurple),
        PremiumFeatureHighlight(title: "High quality\nexport", systemImage: "pay3", tint: Theme.gradientBlue)
    ]
}
