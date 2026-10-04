//
//  AppearanceOption.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 16.08.2026.
//

import Foundation

enum AppearanceOption: String, CaseIterable, Identifiable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"

    var id: String { rawValue }
    var title: String { rawValue }
}
