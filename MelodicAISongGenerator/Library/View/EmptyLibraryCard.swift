//
//  EmptyLibraryCard.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//

import SwiftUI


struct EmptyLibraryCard: View {
    let onCreateSong: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.gradientPurple.opacity(0.25))
                        .frame(width: 56, height: 56)
                        .blur(radius: 10)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: AdaptiveFontSize.adaptive26))
                        .foregroundStyle(Theme.gradientPurple)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: AdaptiveFontSize.adaptive14, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .offset(x: 10, y: -14)
                }
                .frame(width: 56, height: 56)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("No songs yet — create your first one!")
                        .font(Theme.Typography.sectionHeader)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Start by describing the song you want to hear.")
                        .font(Theme.Typography.rowSubtitle)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 0)
            }
            
            GradientActionButton(title: "Create Song", systemImage: "sparkles", action: onCreateSong)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                .fill(Theme.surface.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                .strokeBorder(Theme.brandGradient, style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
        )
    }
}


#Preview {
    EmptyLibraryCard { }
}
