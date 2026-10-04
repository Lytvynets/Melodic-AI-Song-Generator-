//
//  GeneratingScreenView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//


import SwiftUI

struct GeneratingScreenView: View {
    
    @State private var badgePulse = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            GeneratingStarfieldView()
                .opacity(0.7)
            
            VStack(spacing: 0) {
                titleBlock
                    .padding(.top, 28)
                
                Spacer(minLength: 0)
                
                TrackVisualizerView()
                    .frame(height: 380)
                    .padding(.horizontal, 8)
                
                Spacer(minLength: 0)
                
                aiBadge
                    .padding(.bottom, 28)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                badgePulse = true
            }
        }
    }
    
    
    private var titleBlock: some View {
        VStack(spacing: 10) {
            VStack(spacing: 2) {
                Text("Composing")
                    .foregroundStyle(Theme.textPrimary)
                Text("your track…")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.gradientPink, Theme.gradientPurple, Theme.gradientBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .font(.system(size: AdaptiveFontSize.adaptive38, weight: .heavy))
            .multilineTextAlignment(.center)
            
            Text("This may take up to 60 seconds")
                .font(.system(size: AdaptiveFontSize.adaptive15, weight: .regular))
                .foregroundStyle(Theme.textSecondary)
        }
    }
    
    
    private var aiBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
            Text("AI is creating something amazing")
        }
        .font(.system(size: AdaptiveFontSize.adaptive14, weight: .medium))
        .foregroundStyle(LinearGradient(colors: [Theme.gradientPink ,Theme.gradientPurple], startPoint: .leading, endPoint: .trailing) )
        .padding(.horizontal, 18)
        .frame(height: 42)
        .background(Theme.surfaceMuted.opacity(0.8))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Theme.gradientPurple.opacity(0.4), lineWidth: 1)
        )
        .opacity(badgePulse ? 1 : 0.6)
    }
}


private struct TrackVisualizerView: View {
    @State private var slowRotationA: Double = 0
    @State private var slowRotationB: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            
            ZStack {
                GeneratingBlobShape(seedPhases: [0.3, 2.4, 1.1, 3.6, 0.9, 2.0])
                    .stroke(Theme.gradientPurple.opacity(0.35), lineWidth: 1)
                    .frame(width: side * 1.05, height: side * 1.05)
                    .blur(radius: 2)
                    .rotationEffect(.degrees(slowRotationA))
                
                GeneratingBlobShape(seedPhases: [1.8, 0.6, 2.7, 1.3, 3.1, 0.4])
                    .stroke(Theme.gradientPink.opacity(0.3), lineWidth: 1)
                    .frame(width: side * 0.92, height: side * 0.92)
                    .blur(radius: 2)
                    .rotationEffect(.degrees(slowRotationB))
                
                GeneratingBlobShape(seedPhases: [0.9, 2.9, 0.2, 1.6, 3.3, 1.0])
                    .fill(
                        AngularGradient(
                            colors: [Theme.gradientPurple, Theme.gradientPink, Theme.gradientPurple],
                            center: .center
                        )
                    )
                    .frame(width: side * 0.8, height: side * 0.8)
                    .blur(radius: 40)
                    .opacity(0.28)
                    .rotationEffect(.degrees(slowRotationA))
                
                FullWidthWaveformView()
                    .frame(width: geo.size.width, height: side * 0.42)
                
                PulseRingView()
                    .frame(width: side * 0.66, height: side * 0.66)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.background.opacity(0.001), Theme.background.opacity(0.0)],
                            center: .center, startRadius: 0, endRadius: 1
                        )
                    )
                    .frame(width: side * 0.58, height: side * 0.58)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.linear(duration: 34).repeatForever(autoreverses: false)) {
                slowRotationA = 360
            }
            withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
                slowRotationB = -360
            }
        }
    }
}


private struct PulseRingView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 - 10
                let tickCount = 120
                
                for i in 0..<tickCount {
                    let baseAngle = (Double(i) / Double(tickCount)) * 2 * .pi
                    let rotated = baseAngle + t * 0.12
                    
                    let wave = sin(rotated * 4 + t * 2.2)
                    let length: Double = 5 + (wave + 1) / 2 * 15
                    
                    let inner = CGPoint(
                        x: center.x + cos(rotated) * radius,
                        y: center.y + sin(rotated) * radius
                    )
                    let outer = CGPoint(
                        x: center.x + cos(rotated) * (radius + length),
                        y: center.y + sin(rotated) * (radius + length)
                    )
                    
                    var path = Path()
                    path.move(to: inner)
                    path.addLine(to: outer)
                    
                    context.stroke(path, with: .color(tickColor(for: rotated)), lineWidth: 1.6)
                }
                
                let topAngle = -Double.pi / 2 + t * 0.12
                let topInner = CGPoint(x: center.x + cos(topAngle) * radius, y: center.y + sin(topAngle) * radius)
                let topOuter = CGPoint(
                    x: center.x + cos(topAngle) * (radius + 26),
                    y: center.y + sin(topAngle) * (radius + 26)
                )
                var highlight = Path()
                highlight.move(to: topInner)
                highlight.addLine(to: topOuter)
                context.stroke(highlight, with: .color(.white), lineWidth: 2.4)
            }
        }
    }
    
    
    private func tickColor(for angle: Double) -> Color {
        let shifted = (angle + .pi / 2).truncatingRemainder(dividingBy: 2 * .pi)
        let normalized = shifted < 0 ? shifted + 2 * .pi : shifted
        
        let topBoost = max(0, cos(normalized))
        let isRightHalf = sin(normalized) >= 0
        let base = isRightHalf ? Theme.gradientPink : Theme.gradientPurple
        let brightness = 0.4 + topBoost * 0.6
        return base.opacity(brightness)
    }
}


private struct FullWidthWaveformView: View {
    private let barCount = 72
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            
            GeometryReader { geo in
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.gradientPurple.opacity(0.5), Theme.gradientPink.opacity(0.5)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(height: 1.2)
                    
                    HStack(spacing: max(1, geo.size.width / CGFloat(barCount) * 0.35)) {
                        ForEach(0..<barCount, id: \.self) { index in
                            Capsule()
                                .fill(barColor(for: index))
                                .frame(height: barHeight(for: index, time: t, maxHeight: geo.size.height))
                        }
                    }
                    .frame(width: geo.size.width)
                }
            }
        }
    }
    
    
    private func barHeight(for index: Int, time: Double, maxHeight: CGFloat) -> CGFloat {
        let position = Double(index) / Double(barCount - 1)
        let distanceFromCenter = abs(position - 0.5) * 2
        let envelope = 0.25 + (1 - distanceFromCenter) * 0.9
        
        let phase = Double(index) * 0.35
        let wave = sin(time * 3.1 + phase) * 0.5 + sin(time * 1.7 + phase * 1.6) * 0.5
        let normalized = (wave + 1) / 2
        
        return max(2, CGFloat(normalized) * maxHeight * CGFloat(envelope))
    }
    
    
    private func barColor(for index: Int) -> Color {
        let position = Double(index) / Double(barCount - 1)
        return position < 0.5 ? Theme.gradientPurple : Theme.gradientPurple
    }
}


private struct GeneratingBlobShape: Shape {
    var seedPhases: [Double]
    var amplitude: CGFloat = 0.1
    var points: Int = 48
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        var path = Path()
        
        for i in 0...points {
            let angle = (2 * Double.pi / Double(points)) * Double(i)
            let phase = seedPhases[i % seedPhases.count]
            let wobble = sin(angle * 3 + phase) * 0.6 + sin(angle * 5 + phase * 1.7) * 0.4
            let radius = baseRadius * (1 + amplitude * CGFloat(wobble))
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}


private struct GeneratingStarfieldView: View {
    private let stars: [Star] = (0..<24).map { i in
        var generator = SeededGenerator(seed: UInt64(i * 613 + 7))
        return Star(
            x: Double.random(in: 0...1, using: &generator),
            y: Double.random(in: 0...1, using: &generator),
            size: Double.random(in: 1.2...2.8, using: &generator),
            phase: Double.random(in: 0...(2 * .pi), using: &generator),
            speed: Double.random(in: 0.5...1.4, using: &generator),
            hue: Bool.random(using: &generator)
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    for star in stars {
                        let opacity = 0.2 + 0.5 * (0.5 + 0.5 * sin(t * star.speed + star.phase))
                        let point = CGPoint(x: star.x * size.width, y: star.y * size.height)
                        let color: Color = star.hue ? Theme.gradientPurple : Theme.gradientPink
                        context.opacity = opacity
                        context.fill(
                            Path(ellipseIn: CGRect(x: point.x, y: point.y, width: star.size, height: star.size)),
                            with: .color(color)
                        )
                    }
                }
            }
        }
    }
    
    private struct Star {
        let x: Double
        let y: Double
        let size: Double
        let phase: Double
        let speed: Double
        let hue: Bool
    }
}


private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        state = seed == 0 ? 0xDEADBEEF : seed
    }
    
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}


#Preview {
    GeneratingScreenView()
}
