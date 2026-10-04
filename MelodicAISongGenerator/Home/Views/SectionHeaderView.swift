//
//  SectionHeaderView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var hint: String? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
            
            if let hint {
                Text(hint)
                    .font(Theme.Typography.sectionHint)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}


#Preview {
    SectionHeaderView(title: "Test")
}
