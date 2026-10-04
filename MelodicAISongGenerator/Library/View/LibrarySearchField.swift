//
//  LibrarySearchField.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//

import SwiftUI

struct LibrarySearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)

            TextField("", text: $text, prompt: Text("Search songs...").foregroundStyle(Theme.textPlaceholder))
                .foregroundStyle(Theme.textPrimary)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }
}


#Preview {
    @Previewable @State var text = ""
    LibrarySearchField(text: $text)
}
