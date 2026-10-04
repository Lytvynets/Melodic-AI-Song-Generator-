//
//  Theme.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 20.08.2026.
//

import Foundation
import SwiftUI


enum Theme {
    static let background = Color(hex: "0A0A12")
    static let miniPlayerBackground = Color(hex: "#12121B")
    static let trackCard = Color(hex: "#12121B")
    static let surface = Color(hex: "13121C")
    static let surfaceMuted = Color(hex: "16151F")
    static let stroke = Color.white.opacity(0.08)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textPlaceholder = Color.white.opacity(0.35)
    static let gradientPink = Color(hex: "#CB49E6")
    static let gradientPurple = Color(hex: "#5229EA")
    static let gradientBlue = Color(hex: "#68D7F0")
    
    
    static let brandGradient = LinearGradient(
        colors: [gradientPink, gradientPurple, gradientBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    
    static let selectionGradient = LinearGradient(
        colors: [gradientPink, gradientPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    
    static let glowColor = gradientPurple.opacity(0.45)
    static let energeticIcon = Color(hex: "C77DFF")
    static let chillIcon = Color(hex: "5AC8FA")
    static let sadIcon = Color(hex: "5AC8FA")
    static let epicIcon = Color(hex: "FFB020")
    static let romanticIcon = Color(hex: "FF5C8A")
    static let shareAction = Color(hex: "#17172B")
    static let card = Color(hex: "121019")
    static let iconBadgeBackground = Color(hex: "241F35")
    static let iconBadgeTint = Color(hex: "B98CFF")
    static let sectionCapsColor = Color.white.opacity(0.4)
    static let rowDivider = Color.white.opacity(0.06)
    static let gold = Color(hex: "FFC24B")
    
    
    static let premiumBannerGradient = LinearGradient(
        colors: [Color(hex: "#110749"), Color(hex: "#110749"), Color(hex: "#9630D1")],
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )
    
    
    static let toggleOnGradient = LinearGradient(
        colors: [gradientPurple, Color(hex: "6A6BFF")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    
    enum Layout {
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
        static let chipSpacing: CGFloat = 10
        static let cornerRadiusLarge: CGFloat = 18
        static let cornerRadiusMedium: CGFloat = 14
        static let cornerRadiusPill: CGFloat = 100
        static let segmentedHeight: CGFloat = 34
    }
    
    
    enum Typography {
        static let title = Font.system(size: AdaptiveFontSize.adaptive30, weight: .heavy)
        static let trackTitle = Font.system(size: AdaptiveFontSize.adaptive17, weight: .heavy)
        static let sectionHeader = Font.system(size: AdaptiveFontSize.adaptive17, weight: .semibold)
        static let sectionHint = Font.system(size: AdaptiveFontSize.adaptive13, weight: .regular)
        static let body = Font.system(size: AdaptiveFontSize.adaptive14, weight: .regular)
        static let chip = Font.system(size: AdaptiveFontSize.adaptive14, weight: .medium)
        static let buttonTitle = Font.system(size: AdaptiveFontSize.adaptive18, weight: .bold)
        static let trackMeta = Font.system(size: AdaptiveFontSize.adaptive11, weight: .regular)
        static let counter = Font.system(size: AdaptiveFontSize.adaptive12, weight: .regular)
        static let tabLabel = Font.system(size: AdaptiveFontSize.adaptive11, weight: .medium)
        static let miniPlayerTitle = Font.system(size: AdaptiveFontSize.adaptive17, weight: .medium)
        static let screenTitle = Font.system(size: AdaptiveFontSize.adaptive34, weight: .heavy)
        static let bannerTitle = Font.system(size: AdaptiveFontSize.adaptive22, weight: .bold)
        static let bannerSubtitle = Font.system(size: AdaptiveFontSize.adaptive12, weight: .regular)
        static let bannerChip = Font.system(size: AdaptiveFontSize.adaptive10, weight: .medium)
        static let sectionCaps = Font.system(size: AdaptiveFontSize.adaptive12, weight: .semibold)
        static let rowTitle = Font.system(size: AdaptiveFontSize.adaptive16, weight: .semibold)
        static let rowSubtitle = Font.system(size: AdaptiveFontSize.adaptive13, weight: .regular)
        static let trackSubtitle = Font.system(size: AdaptiveFontSize.adaptive14, weight: .regular)
        static let segmentSmall = Font.system(size: AdaptiveFontSize.adaptive14, weight: .semibold)
        static let footer = Font.system(size: AdaptiveFontSize.adaptive12, weight: .regular)
    }
}
