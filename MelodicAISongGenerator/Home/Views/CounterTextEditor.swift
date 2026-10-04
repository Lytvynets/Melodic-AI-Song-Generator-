//
//  CounterTextEditor.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import SwiftUI


struct CounterTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let characterLimit: Int
    var minHeight: CGFloat = 110
    var trailingIcon: String? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                        .stroke(Theme.stroke, lineWidth: 1)
                )
            
            if text.isEmpty {
                Text(placeholder)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.textPlaceholder)
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
            }
            
            TextEditor(text: $text)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 28)
                .onChange(of: text) { _, newValue in
                    if newValue.count > characterLimit {
                        text = String(newValue.prefix(characterLimit))
                    }
                }
            
            if let trailingIcon {
                Image(systemName: trailingIcon)
                    .foregroundStyle(LinearGradient(colors: [Theme.gradientPink, Theme.gradientPurple], startPoint: .top, endPoint: .bottom) )
                    .padding(.top, 18)
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Text("\(text.count)/\(characterLimit)")
                .font(Theme.Typography.counter)
                .foregroundStyle(Theme.textSecondary)
                .padding(.trailing, 16)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .frame(minHeight: minHeight)
    }
}


#Preview {
    @Previewable @State var customLyrics: String = ""
    CounterTextEditor(text: $customLyrics, placeholder: "Test", characterLimit: 100)
}
