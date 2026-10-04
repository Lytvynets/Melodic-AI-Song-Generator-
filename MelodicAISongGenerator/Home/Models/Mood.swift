//
//  Mood.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import Foundation
import SwiftUI

enum Mood: String, CaseIterable, Identifiable {
    case energetic = "Energetic"
    case chill = "Chill"
    case sad = "Sad"
    case epic = "Epic"
    case romantic = "Romantic"

    var id: String { rawValue }
    var title: String { rawValue }

    var systemImage: String {
        switch self {
        case .energetic: return "bolt.fill"
        case .chill: return "snowflake"
        case .sad: return "cloud.rain.fill"
        case .epic: return "sparkle"
        case .romantic: return "heart.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .energetic: return Theme.energeticIcon
        case .chill: return Theme.chillIcon
        case .sad: return Theme.sadIcon
        case .epic: return Theme.epicIcon
        case .romantic: return Theme.romanticIcon
        }
    }
}
