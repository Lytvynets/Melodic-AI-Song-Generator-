//
//  FilterMenuButton.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//


import SwiftUI
import UIKit

struct FilterMenuButton: View {
    @Binding var selection: LibrarySortOption
    
    var body: some View {
        Menu {
            Picker("", selection: $selection) {
                ForEach(LibrarySortOption.allCases) { option in
                    Label(option.title, systemImage: option.systemImage).tag(option)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Filter")
            }
            .font(Theme.Typography.chip)
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous)
                    .stroke(Theme.stroke, lineWidth: 1)
            )
        }
    }
}


#Preview {
    @Previewable @State var selection: LibrarySortOption = .longestFirst
    FilterMenuButton(selection: $selection)
}



private extension LibrarySortOption {
    var title: String { rawValue }
}


enum LibrarySortOption: String, CaseIterable, Identifiable {
    case newestFirst = "Newest first"
    case oldestFirst = "Oldest first"
    case longestFirst = "Longest first"
    case shortestFirst = "Shortest first"
    case titleAZ = "Title A–Z"
    
    var id: String { rawValue }
    var systemImage: String {
        switch self {
        case .newestFirst: return "arrow.down.circle"
        case .oldestFirst: return "arrow.up.circle"
        case .longestFirst: return "hourglass"
        case .shortestFirst: return "bolt"
        case .titleAZ: return "textformat"
        }
    }
}
