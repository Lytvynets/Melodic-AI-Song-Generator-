//
//  ToggleSwitchView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 16.08.2026.
//

import SwiftUI

struct ToggleSwitchView: View {
    @Binding var isOn: Bool

    private let width: CGFloat = 51
    private let height: CGFloat = 31
    private let knobPadding: CGFloat = 2

    var body: some View {
        Capsule()
            .fill(isOn ? AnyShapeStyle(Theme.toggleOnGradient) : AnyShapeStyle(Theme.surfaceMuted))
            .frame(width: width, height: height)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .padding(knobPadding)
                    .frame(width: height, height: height)
                    .offset(x: isOn ? (width - height) / 2 : -(width - height) / 2)
            )
            .animation(.easeInOut(duration: 0.18), value: isOn)
            .onTapGesture { isOn.toggle() }
    }
}


#Preview {
    @Previewable @State var test = false
    ToggleSwitchView(isOn: $test)
}
