//
//  SongDuration.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import Foundation

enum SongDuration: String, CaseIterable, Identifiable {
    case short = "30 sec"
    case medium = "1 min"
    case long = "2 min"

    var id: String { rawValue }
    var title: String { rawValue }
}
