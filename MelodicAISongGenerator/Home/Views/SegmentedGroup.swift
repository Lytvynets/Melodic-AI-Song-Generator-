//
//  SegmentedGroup.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import SwiftUI

struct SegmentedGroup<Option: Identifiable>: View {
    let options: [Option]
    let title: (Option) -> String
    var icon: ((Option) -> String)? = nil
    let isSelected: (Option) -> Bool
    let onSelect: (Option) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options) { option in
                SegmentedOptionView(
                    title: title(option),
                    systemImage: icon?(option),
                    isSelected: isSelected(option),
                    action: { onSelect(option) }
                )
                .background(
                    Group {
                        if isSelected(option) {
                            Theme.selectionGradient
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous))
                                .shadow(color: Theme.glowColor, radius: 10, y: 2)
                        }
                    }
                )
            }
        }
        .padding(4)
        .background(Theme.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }
}


#Preview {
    @Previewable @State var selectedDuration: SongDuration = .medium
    SegmentedGroup(
        options: SongDuration.allCases,
        title: { $0.title },
        isSelected: { $0 == selectedDuration },
        onSelect: { selectedDuration = $0 }
    )
}
