//
//  SongRowView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//

import SwiftUI

struct SongRowView: View {
    let song: SavedSong
    let isCurrent: Bool
    let isPlaying: Bool
    let duration: TimeInterval?
    let onPlayPause: () -> Void
    let onMoreTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ArtworkThumbnail(
                colors: song.artworkColors,
                isPlaying: isCurrent && isPlaying,
                size: 64,
                onTapPlay: onPlayPause
            )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(song.title)
                        .font(Theme.Typography.trackTitle)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    
                    if isCurrent {
                        Image(systemName: "waveform")
                            .font(.system(size: AdaptiveFontSize.adaptive12, weight: .semibold))
                            .foregroundStyle(Theme.gradientPurple)
                            .padding(.leading, 7)
                    }
                }
                
                Text(song.genre.capitalized)
                    .font(Theme.Typography.trackSubtitle)
                    .foregroundStyle(Theme.textSecondary)
                
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                    Text(durationText)
                        .padding(.trailing, 7)
                    
                    Image(systemName: "calendar")
                    Text(dateText)
                }
                .font(Theme.Typography.trackMeta)
                .foregroundStyle(Theme.textSecondary.opacity(0.8))
                .labelStyle(.titleAndIcon)
            }
            
            Spacer(minLength: 8)
            
            VStack(spacing: 14) {
                
                Spacer()
                    .frame(height: 15)
                
                
                Button(action: onPlayPause) {
                    Circle()
                        .fill(Theme.surfaceMuted)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: isCurrent && isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: AdaptiveFontSize.adaptive14, weight: .bold))
                                .foregroundStyle(Theme.textPrimary)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Theme.trackCard)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }
    
    
    private var durationText: String {
        guard let duration else { return "–:––" }
        return DurationFormatter.format(duration)
    }
    
    
    private var dateText: String {
        song.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
}


#Preview {
    SongRowView(song: SavedSong(id: UUID(), title: "Test title", genre: "Rock", fileName: "Teeeesd", createdAt: Date.now), isCurrent: true, isPlaying: false, duration: 12.4, onPlayPause: {} , onMoreTapped: {})
}
