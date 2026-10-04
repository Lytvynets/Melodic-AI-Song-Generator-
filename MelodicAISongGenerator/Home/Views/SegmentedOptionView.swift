//
//  SegmentedOptionView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import SwiftUI

struct SegmentedOptionView: View {
    let title: String
    var systemImage: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(Theme.Typography.chip.weight(isSelected ? .semibold : .medium))
            }
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Layout.segmentedHeight)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    SegmentedOptionView(title: "Test", isSelected: true) { }
}
