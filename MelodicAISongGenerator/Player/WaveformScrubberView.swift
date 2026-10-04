//
//  WaveformScrubberView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//


import SwiftUI
import UIKit

struct WaveformScrubberView: View {
    let amplitudes: [Float]
    let progress: Double
    let onSeek: (Double) -> Void

    @State private var isDragging = false
    @State private var dragProgress: Double = 0

    private let barSpacing: CGFloat = 3
    private let minBarHeight: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let displayProgress = isDragging ? dragProgress : progress
            let width = geo.size.width
            let height = geo.size.height
            let barWidth = self.barWidth(totalWidth: width)

            ZStack(alignment: .leading) {
                HStack(alignment: .center, spacing: barSpacing) {
                    ForEach(Array(amplitudes.enumerated()), id: \.offset) { index, amplitude in
                        Capsule()
                            .fill(barColor(forIndex: index))
                            .frame(width: barWidth, height: max(minBarHeight, CGFloat(amplitude) * height))
                    }
                }
                .frame(width: width, height: height)

                playhead(height: height)
                    .offset(x: width * displayProgress - 1)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragProgress = clampedFraction(value.location.x / width)
                    }
                    .onEnded { value in
                        let final = clampedFraction(value.location.x / width)
                        dragProgress = final
                        onSeek(final)
                        isDragging = false
                    }
            )
        }
    }

    
    private func playhead(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color.white)
                .frame(width: 9, height: 9)
                .shadow(color: .white.opacity(0.8), radius: 5)

            Rectangle()
                .fill(Color.white)
                .frame(width: 1.5)
        }
        .frame(height: height + 12, alignment: .top)
    }


    private func barWidth(totalWidth: CGFloat) -> CGFloat {
        guard amplitudes.count > 0 else { return 2 }
        let totalSpacing = barSpacing * CGFloat(amplitudes.count - 1)
        return max(1.5, (totalWidth - totalSpacing) / CGFloat(amplitudes.count))
    }

    
    private func clampedFraction(_ value: CGFloat) -> Double {
        Double(min(max(0, value), 1))
    }

    
    private func barColor(forIndex index: Int) -> Color {
        guard amplitudes.count > 1 else { return Theme.gradientPurple }
        let position = Double(index) / Double(amplitudes.count - 1)

        if position < 0.5 {
            return Color.lerp(Theme.gradientPink, Theme.gradientPurple, position / 0.5)
        } else {
            return Color.lerp(Theme.gradientPurple, Theme.gradientBlue, (position - 0.5) / 0.5)
        }
    }
}

extension Color {
    static func lerp(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let clampedT = CGFloat(min(max(0, t), 1))

        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        UIColor(a).getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        UIColor(b).getRed(&br, green: &bg, blue: &bb, alpha: &ba)

        return Color(
            red: Double(ar + (br - ar) * clampedT),
            green: Double(ag + (bg - ag) * clampedT),
            blue: Double(ab + (bb - ab) * clampedT),
            opacity: Double(aa + (ba - aa) * clampedT)
        )
    }
}
