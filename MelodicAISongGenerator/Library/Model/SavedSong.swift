//
//  SavedSong.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//

import Foundation
import SwiftUI

struct SavedSong: Identifiable, Codable {
    let id: UUID
    var title: String
    var genre: String
    var fileName: String
    var createdAt: Date
    
    var artworkColors: [Color] {
        var hasher = Hasher()
        hasher.combine(genre.lowercased())
        let hue = Double(abs(hasher.finalize()) % 360) / 360.0
        return [
            Color(hue: hue, saturation: 0.65, brightness: 0.85),
            Color(hue: (hue + 0.12).truncatingRemainder(dividingBy: 1.0), saturation: 0.7, brightness: 0.6)
        ]
    }
}
