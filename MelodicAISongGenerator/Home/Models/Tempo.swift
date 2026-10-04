//
//  Tempo.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import Foundation

enum Tempo: String, CaseIterable, Identifiable, Equatable {
    case slow = "Slow"
    case medium = "Medium"
    case fast = "Fast"

    var id: String { rawValue }
    var title: String { rawValue }

    var systemImage: String {
        switch self {
        case .slow: return "tortoise.fill"
        case .medium: return "waveform"
        case .fast: return "paperplane.fill"
        }
    }
}
