//
//  OnboardingPremiumFeature.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 18.08.2026.
//

import Foundation
import SwiftUI


struct OnboardingPremiumFeature: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
    let tint: Color
    
    static let all: [OnboardingPremiumFeature] = [
        OnboardingPremiumFeature(
            title: "Unlimited song generations",
            description: "Create as many songs as you want, whenever inspiration hits.",
            systemImage: "pay1",
            tint: Theme.gradientPurple
        ),
        
        OnboardingPremiumFeature(
            title: "Custom lyrics & full vocal control",
            description: "Write your own lyrics or generate vocals exactly how you imagine.",
            systemImage: "pay2",
            tint: Theme.gradientPurple
        ),
        
        OnboardingPremiumFeature(
            title: "Save & export in high quality",
            description: "Export your songs in the best quality and keep them forever.",
            systemImage: "pay3",
            tint: Theme.gradientBlue
        )
    ]
}
