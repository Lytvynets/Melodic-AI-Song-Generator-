//
//  OnboardingModels.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//


import SwiftUI

struct OnboardingTitlePart {
    let text: String
    let isHighlighted: Bool
}

struct OnboardingPage: Identifiable {
    let id: Int
    let titleParts: [OnboardingTitlePart]
    let subtitle: String
    let buttonTitle: String
    let placeholderIcon: String
    let accentColor: Color
    let showPremiumHint: Bool
    
    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            titleParts: [
                .init(text: "Create any song\nwith ", isHighlighted: false),
                .init(text: "AI", isHighlighted: true)
            ],
            subtitle: "Turn your wildest ideas\ninto full, radio-ready songs\nin just seconds",
            buttonTitle: "Continue",
            placeholderIcon: "onb1",
            accentColor: Theme.gradientBlue,
            showPremiumHint: false
        ),
        OnboardingPage(
            id: 1,
            titleParts: [
                .init(text: "Any genre,\nany ", isHighlighted: false),
                .init(text: "mood", isHighlighted: true)
            ],
            subtitle: "From pop to lo-fi,\nrock to rap — just describe it\nand we'll bring it to life",
            buttonTitle: "Continue",
            placeholderIcon: "onb2",
            accentColor: Theme.gradientPurple,
            showPremiumHint: false
        ),
        OnboardingPage(
            id: 2,
            titleParts: [
                .init(text: "Vocals, instrumental,\nor ", isHighlighted: false),
                .init(text: "your own lyrics", isHighlighted: true)
            ],
            subtitle: "Sing your own words,\nlet AI write them for you,\nor skip vocals entirely",
            buttonTitle: "Continue",
            placeholderIcon: "onb3",
            accentColor: Theme.gradientPurple,
            showPremiumHint: false
        ),
        OnboardingPage(
            id: 3,
            titleParts: [
                .init(text: "Your first hit is\n", isHighlighted: false),
                .init(text: "one tap", isHighlighted: true),
                .init(text: " away", isHighlighted: false)
            ],
            subtitle: "Join thousands of creators\nturning ideas into songs\nevery single day",
            buttonTitle: "Get Started",
            placeholderIcon: "onb4",
            accentColor: Theme.gradientPink,
            showPremiumHint: true
        )
    ]
}
