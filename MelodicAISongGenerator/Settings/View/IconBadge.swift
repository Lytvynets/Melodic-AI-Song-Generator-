//
//  IconBadge.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 16.08.2026.
//

import SwiftUI

struct IconBadge: View {
    let systemImage: String
    var tint: Color = Theme.iconBadgeTint
    var size: CGFloat = 44

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Theme.iconBadgeBackground)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemImage)
                    .font(.system(size: size * 0.42, weight: .medium))
                    .foregroundStyle(LinearGradient(colors: [Theme.gradientPink, Theme.gradientPurple], startPoint: .top, endPoint: .bottom))
            )
    }
}

#Preview {
    IconBadge(systemImage: "gear")
}
