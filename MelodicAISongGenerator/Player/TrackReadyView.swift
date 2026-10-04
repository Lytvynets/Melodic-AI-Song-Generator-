//
//  TrackReadyView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//


import SwiftUI
import UniformTypeIdentifiers
import StoreKit

struct TrackReadyView: View {
    let song: SavedSong
    let store: TrackStore
    
    var onBack: () -> Void = {}
    var onPrevious: () -> Void = {}
    var onNext: () -> Void = {}
    
    @EnvironmentObject var playback: PlaybackController
    @EnvironmentObject var inAppPurchaseViewModel: InAppPurchaseViewModel

    
    @State private var amplitudes: [Float] = []
    @State private var isShareSheetPresented = false
    @State private var showFileExporter = false
    @State private var exportDocument: AudioDocument?
    @State private var exportFileName = "Song.mp3"
    @State private var showPaywall = false
    
    private let waveformBarCount = 64
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    header
                    artwork
                        .padding(.top, 24)
                    
                    songInfoRow
                        .padding(.top, 25)
                    
                    waveformBlock
                        .padding(.top, 22)
                    
                    playbackControls
                        .padding(.top, 22)
                    
                    actionRow
                        .padding(.top, 40)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
            }
            .scrollIndicators(.hidden)
        }
        .task {
            amplitudes = await WaveformExtractor.amplitudes(for: store.fileURL(for: song), sampleCount: waveformBarCount)
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ActivityShareSheet(items: [store.fileURL(for: song)])
        }
        .fullScreenCover(isPresented: $showPaywall, content: {
            PaywallView()
                .onDisappear {
                    Task {
                        for sub in inAppPurchaseViewModel.products {
                            inAppPurchaseViewModel.isSubscribed = await inAppPurchaseViewModel.checkSubscriptionStatus(for: sub.id)
                        }
                    }
                }

        })
        .fileExporter(
            isPresented: $showFileExporter,
            document: exportDocument,
            contentType: .mp3,
            defaultFilename: exportFileName
        ) { result in
            switch result {
            case .success(let url):
                print("Файл збережено: \(url)")
                
            case .failure(let error):
                print("Помилка збереження: \(error.localizedDescription)")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    
    private var header: some View {
        HStack {
            circleButton(systemImage: "chevron.down", action: onBack)
            Spacer()
        }
        .padding(.top, 8)
    }
    
    
    private func circleButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(Theme.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: systemImage)
                        .font(.system(size: AdaptiveFontSize.adaptive15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                )
        }
        .buttonStyle(.plain)
    }
    
    
    private var artwork: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(colors: song.artworkColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(
                Image(systemName: "waveform")
                    .font(.system(size: 90))
                    .foregroundStyle(.white.opacity(0.12))
            )
            .aspectRatio(1.5, contentMode: .fit)
            .overlay(alignment: .topLeading) {
                genreBadge
                    .padding(16)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.stroke, lineWidth: 1)
            )
            .padding(.horizontal)
    }
    
    
    private var genreBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 11))
            Text(song.genre.capitalized)
                .font(.system(size: AdaptiveFontSize.adaptive13, weight: .semibold))
        }
        .foregroundStyle(Theme.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.black.opacity(0.35))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Theme.stroke, lineWidth: 1)
        )
    }
    
    
    private var songInfoRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.system(size: AdaptiveFontSize.adaptive26, weight: .heavy))
                    .foregroundStyle(Theme.textPrimary)
                
                Text(song.genre.capitalized)
                    .font(.system(size: AdaptiveFontSize.adaptive14, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
    }
    
    
    private var waveformBlock: some View {
        VStack(spacing: 8) {
            WaveformScrubberView(
                amplitudes: amplitudes,
                progress: progress,
                onSeek: { fraction in
                    playback.seek(toProgress: fraction)
                }
            )
            .frame(height: 46)
            
            HStack {
                Text(DurationFormatter.format(playback.currentTime))
                Spacer()
                Text(DurationFormatter.format(effectiveDuration))
            }
            .font(.system(size: AdaptiveFontSize.adaptive13, weight: .regular))
            .foregroundStyle(Theme.textSecondary)
        }
    }
    
    
    private var progress: Double {
        guard effectiveDuration > 0 else { return 0 }
        return min(1, max(0, playback.currentTime / effectiveDuration))
    }
    
    
    private var effectiveDuration: TimeInterval {
        playback.currentSong?.id == song.id ? playback.duration : 0
    }
    
    
    private var playbackControls: some View {
        HStack(spacing: 44) {
            Button(action: onPrevious) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: AdaptiveFontSize.adaptive20, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .buttonStyle(.plain)
            
            Button(action: togglePlay) {
                Circle()
                    .fill(Theme.surfaceMuted)
                    .frame(width: 84, height: 84)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(colors: [Theme.gradientPink, Theme.gradientPurple, Theme.gradientBlue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )
                    .overlay(
                        Image(systemName: isCurrentlyPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: AdaptiveFontSize.adaptive28, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                            .offset(x: isCurrentlyPlaying ? 0 : 2)
                    )
                    .shadow(color: Theme.glowColor, radius: 18)
            }
            .buttonStyle(.plain)
            
            Button(action: onNext) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: AdaptiveFontSize.adaptive20, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .buttonStyle(.plain)
        }
    }
    
    
    private var isCurrentlyPlaying: Bool {
        playback.currentSong?.id == song.id && playback.isPlaying
    }
    
    
    private func togglePlay() {
        if playback.currentSong?.id == song.id {
            playback.togglePlayPause()
        } else {
            playback.play(song, url: store.fileURL(for: song))
        }
    }
    
    
    private var actionRow: some View {
        HStack(spacing: 12) {
            actionCard(title: "Save", subtitle: "Add to Library", systemImage: "arrow.down", tint: Theme.gradientPink, action:{ saveToFiles(song) })
            actionCard(title: "Share", subtitle: "Share your track", systemImage: "square.and.arrow.up", tint: Theme.gradientBlue, action: {
                if inAppPurchaseViewModel.isSubscribed {
                    isShareSheetPresented = true
                }else{
                    showPaywall = true
                }
            })
        }
    }
    
    
    func saveToFiles(_ song: SavedSong) {
        if inAppPurchaseViewModel.isSubscribed {
            let url = store.fileURL(for: song)
            guard let data = try? Data(contentsOf: url) else {
                print("Не вдалося прочитати аудіофайл")
                return
            }
            
            exportDocument = AudioDocument(data: data)
            exportFileName = "\(song.title).mp3"
            showFileExporter = true
        }else{
            showPaywall = true
        }
    }
    
    
    private func actionCard(title: String, subtitle: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: AdaptiveFontSize.adaptive20, weight: .semibold))
                    .foregroundStyle(tint)
                    .padding(.bottom, 5)
                
                Text(title)
                    .font(.system(size: AdaptiveFontSize.adaptive14, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: AdaptiveFontSize.adaptive11, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .padding(.vertical, 16)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium, style: .continuous)
                    .stroke(Theme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    TrackReadyView(
        song: SavedSong(id: UUID(), title: "Midnight Drive", genre: "Lo-Fi", fileName: "preview.mp3", createdAt: Date()),
        store: TrackStore()
    )
    .environmentObject(PlaybackController())
    .environmentObject(InAppPurchaseViewModel())
}
