//
//  ChipView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import SwiftUI

struct ChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.chip)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(colors: [Color(hex: "#7A2ACD") , Color(hex: "#4727BE")], startPoint: .topTrailing, endPoint: .bottomLeading)
                        } else {
                            Theme.surfaceMuted
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Theme.stroke, lineWidth: 2)
                )
                .shadow(color: isSelected ? Theme.glowColor : .clear, radius: 10, y: 2)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    ChipView(title: "Test", isSelected: true) { }
}
