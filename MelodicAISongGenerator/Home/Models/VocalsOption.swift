//
//  VocalsOption.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import Foundation

enum VocalsOption: String, CaseIterable, Identifiable {
    case none = "No Vocals"
    case vocals = "Vocals"
    case customLyrics = "Lyrics"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .none: return "mic.slash.fill"
        case .vocals: return "mic.fill"
        case .customLyrics: return "pencil"
        }
    }
}
