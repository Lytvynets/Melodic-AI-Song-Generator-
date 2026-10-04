//
//  SplashScreenView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//


import SwiftUI

struct SplashScreenView: View {
    
    var onFinished: () -> Void = {}
    
    @State private var blobRotationA: Double = 0
    @State private var blobRotationB: Double = 0
    @State private var ringPulse: CGFloat = 1
    @State private var equalizerActive = false
        
    @State private var logoScale: CGFloat = 0.55
    @State private var logoOpacity: Double = 0
    
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0
    
    @State private var titleOpacity: Double = 0
    @State private var titleScale: CGFloat = 0.85
    @State private var titleBlur: CGFloat = 12
    
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 8
    
    @State private var progressUIOpacity: Double = 0
    @State private var progress: CGFloat = 0
    
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                logoMark
                    .padding(.bottom, 36)
                
                titleBlock
                
                Spacer(minLength: 0)
                
                progressBlock
                    .padding(.bottom, 64)
            }
        }
        .task {
            await runIntroSequence()
        }
    }
    
    
    private var logoMark: some View {
        ZStack {
            
            BlobShape(seedPhases: [0.4, 2.1, 1.0, 3.4, 0.8, 2.7])
                .fill(
                    AngularGradient(
                        colors: [Theme.gradientPink, Theme.gradientPurple, Theme.gradientBlue, Theme.gradientPink],
                        center: .center
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 38)
                .opacity(0.55)
                .rotationEffect(.degrees(blobRotationA))
            
            BlobShape(seedPhases: [1.6, 0.2, 2.9, 1.1, 3.0, 0.6])
                .fill(
                    AngularGradient(
                        colors: [Theme.gradientBlue, Theme.gradientPurple, Theme.gradientPink, Theme.gradientBlue],
                        center: .center
                    )
                )
                .frame(width: 250, height: 250)
                .blur(radius: 26)
                .opacity(0.45)
                .rotationEffect(.degrees(blobRotationB))
            
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [Theme.gradientPink, Theme.gradientPurple, Theme.gradientBlue, Theme.gradientPink],
                        center: .center
                    ),
                    lineWidth: 2.5
                )
                .frame(width: 208, height: 208)
                .scaleEffect(ringPulse)
                .shadow(color: Theme.gradientPurple.opacity(0.7), radius: 16)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "17121F"), Theme.background],
                        center: .center,
                        startRadius: 4,
                        endRadius: 110
                    )
                )
                .frame(width: 196, height: 196)
            
            equalizerIcon
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }
    
    
    private var equalizerIcon: some View {
        ZStack {
            Image("logo213123")
                .resizable()
                .frame(width: 80, height: 100)
                .scaledToFit()
                .shadow(color: Theme.gradientPurple.opacity(0.8), radius: 14)
                .padding(.bottom)
            
            HStack(spacing: 0) {
                EqualizerBarsView(barCount: 6, isActive: equalizerActive, phaseOffset: 0, tint: Theme.gradientPink)
                    .frame(width: 60, height: 46)
                
                Spacer()
                    .frame(width: 60)
                
                EqualizerBarsView(barCount: 6, isActive: equalizerActive, phaseOffset: 1.4, tint: Theme.gradientPurple)
                    .frame(width: 60, height: 46)
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
        }
    }
    
    
    private var titleBlock: some View {
        VStack(spacing: 10) {
            ZStack {
                
                Text("Melodic")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.gradientPurple)
                    .blur(radius: 18)
                    .opacity(titleOpacity * 0.6)
                
                Text("Melodic")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Theme.gradientPurple, Theme.gradientPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .blur(radius: titleBlur)
            .scaleEffect(titleScale)
            .opacity(titleOpacity)
            
            Text("AI Song Generator")
                .font(.system(size: AdaptiveFontSize.adaptive17, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)
                .offset(y: subtitleOffset)
                .opacity(subtitleOpacity)
        }
    }
    
    
    private var progressBlock: some View {
        VStack(spacing: 12) {
            Text("Composing creativity...")
                .font(.system(size: AdaptiveFontSize.adaptive14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surfaceMuted)
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.gradientPink, Theme.gradientPurple, Theme.gradientBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, geo.size.width * progress), height: 4)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .shadow(color: Theme.gradientBlue.opacity(0.9), radius: 6)
                        .offset(x: max(0, geo.size.width * progress - 5))
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 60)
        }
        .opacity(progressUIOpacity)
    }
    
    
    private func runIntroSequence() async {
        withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
            blobRotationA = 360
        }
        withAnimation(.linear(duration: 17).repeatForever(autoreverses: false)) {
            blobRotationB = -360
        }
        withAnimation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true)) {
            ringPulse = 1.045
        }
        
        withAnimation(.spring(response: 0.75, dampingFraction: 0.68)) {
            logoScale = 1
            logoOpacity = 1
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        withAnimation(.easeOut(duration: 0.5)) {
            iconScale = 1
            iconOpacity = 1
        }
        equalizerActive = true
        
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        withAnimation(.easeOut(duration: 0.7)) {
            titleOpacity = 1
            titleScale = 1
            titleBlur = 0
        }
        
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        withAnimation(.easeOut(duration: 0.6)) {
            subtitleOpacity = 1
            subtitleOffset = 0
        }
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        withAnimation(.easeOut(duration: 0.3)) {
            progressUIOpacity = 1
        }
        withAnimation(.easeInOut(duration: 2.4)) {
            progress = 1
        }
        
        try? await Task.sleep(nanoseconds: 2_400_000_000)
        
        onFinished()
    }
}


private struct BlobShape: Shape {
    var seedPhases: [Double]
    var amplitude: CGFloat = 0.14
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


private struct EqualizerBarsView: View {
    let barCount: Int
    let isActive: Bool
    var phaseOffset: Double = 0
    var tint: Color
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(tint.opacity(0.85))
                        .frame(width: 4, height: height(for: index, time: t))
                }
            }
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeOut(duration: 0.4), value: isActive)
    }
    
    private func height(for index: Int, time: Double) -> CGFloat {
        guard isActive else { return 6 }
        let speed = 2.6
        let phase = phaseOffset + Double(index) * 0.75
        let wave = sin(time * speed + phase)
        let normalized = (wave + 1) / 2 
        return 6 + CGFloat(normalized) * 34
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
    SplashScreenView()
}
