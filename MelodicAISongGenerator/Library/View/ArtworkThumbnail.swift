//
//  ArtworkThumbnail.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//

import SwiftUI

struct ArtworkThumbnail: View {
    let colors: [Color]
    let isPlaying: Bool
    let size: CGFloat
    let onTapPlay: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    Image(systemName: "waveform")
                        .font(.system(size: size * 0.32))
                        .foregroundStyle(.white.opacity(0.35))
                )
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
        }
    }
}


#Preview {
    ArtworkThumbnail(colors: [.red, .blue], isPlaying: true, size: 12, onTapPlay: {})
}
