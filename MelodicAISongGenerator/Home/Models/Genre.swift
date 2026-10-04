//
//  Genre.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import Foundation

enum Genre: String, CaseIterable, Identifiable {
    case pop = "Pop"
    case rock = "Rock"
    case hipHop = "Hip-Hop"
    case edm = "EDM"
    case loFi = "Lo-Fi"
    case jazz = "Jazz"
    case classical = "Classical"

    var id: String { rawValue }
    var title: String { rawValue }
}
