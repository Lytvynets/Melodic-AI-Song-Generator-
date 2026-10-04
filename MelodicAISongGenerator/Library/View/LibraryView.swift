//
//  LibraryView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 01.08.2026.
//


import SwiftUI
import StoreKit

struct LibraryView: View {
    
    @EnvironmentObject var playback: PlaybackController
    @EnvironmentObject var durations: DurationCache
    @EnvironmentObject var store: TrackStore
    @EnvironmentObject var inAppPurchaseViewModel: InAppPurchaseViewModel

    
    @State private var searchText = ""
    @State private var selectedGenre: Genre?
    @State private var sortOption: LibrarySortOption = .newestFirst
    
    @State private var actionSheetSong: SavedSong?
    @State private var shareURL: URL?
    @State private var isShareSheetPresented = false
    
    @State private var showPlayer = false
    @State private var showPaywall = false
    
    private let waveformBarCount = 64
    @State private var amplitudes: [Float] = []
    
    var onCreateSong: () -> Void = {}
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                searchAndFilterRow
                    .padding(.top, 16)
                genreChipsRow
                    .padding(.top, 14)
                songList
                    .padding(.top, 16)
            }
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
        .fullScreenCover(isPresented: $showPlayer) {
            if let current = playback.currentSong {
                TrackReadyView(song: current, store: store) {
                    showPlayer = false
                } onPrevious: {
                    playPrevious()
                } onNext: {
                    playNext()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let current = playback.currentSong {
                miniPlayer(for: current)
            }
        }
        .confirmationDialog(
            actionSheetSong?.title ?? "Song Options",
            isPresented: Binding(
                get: { actionSheetSong != nil },
                set: { isPresented in if !isPresented { actionSheetSong = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let song = actionSheetSong {
                Button("Share") { share(song) }
                Button("Delete", role: .destructive) { delete(song) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $isShareSheetPresented) {
            if let shareURL {
                ActivityShareSheet(items: [shareURL])
            }
        }
        .onAppear {
            playback.onTrackFinished = { _ in playNext() }
        }
        .preferredColorScheme(.dark)
    }
    
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Songs")
                    .font(Theme.Typography.screenTitle)
                    .foregroundStyle(Theme.textPrimary)
                
                HStack(spacing: 6) {
                    Text("All songs are saved locally on this device.")
                        .font(Theme.Typography.trackSubtitle)
                        .foregroundStyle(Theme.textSecondary)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: AdaptiveFontSize.adaptive11))
                        .foregroundStyle(Theme.gradientPurple)
                }
            }
            
            Spacer(minLength: 12)
            
            if !inAppPurchaseViewModel.isSubscribed {
                Image("prem2")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        openPremium()
                    }
            }
        }
        .padding(.horizontal, Theme.Layout.screenPadding)
        .padding(.top, 16)
    }
    
    
    private var searchAndFilterRow: some View {
        HStack(spacing: 10) {
            LibrarySearchField(text: $searchText)
            FilterMenuButton(selection: $sortOption)
        }
        .padding(.horizontal, Theme.Layout.screenPadding)
    }
    
    
    private var genreChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Layout.chipSpacing) {
                ChipView(title: "All", isSelected: selectedGenre == nil) {
                    selectedGenre = nil
                }
                ForEach(Genre.allCases) { genre in
                    ChipView(title: genre.title, isSelected: selectedGenre == genre) {
                        selectedGenre = genre
                    }
                }
            }
            .padding(.horizontal, Theme.Layout.screenPadding)
            .padding(.vertical, 2)
        }
    }
    
    
    @ViewBuilder
    private var songList: some View {
        if store.songs.isEmpty {
            ScrollView {
                EmptyLibraryCard(onCreateSong: onCreateSong)
                    .padding(.horizontal, Theme.Layout.screenPadding)
                    .padding(.top, 12)
            }
        } else if filteredSongs.isEmpty {
            VStack(spacing: 6) {
                Spacer()
                Text("No songs match your search")
                    .font(Theme.Typography.sectionHeader)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            List {
                ForEach(filteredSongs) { song in
                    SongRowView(
                        song: song,
                        isCurrent: playback.currentSong?.id == song.id,
                        isPlaying: playback.isPlaying,
                        duration: durations.duration(for: song, fileURL: store.fileURL(for: song)),
                        onPlayPause: { togglePlay(song) },
                        onMoreTapped: { actionSheetSong = song }
                    )
                    .onTapGesture {
                        togglePlay(song)
                        showPlayer = true
                    }
                    
                    .listRowInsets(
                        EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) { delete(song) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button { share(song) } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .tint(Theme.shareAction)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .background(Theme.background)
        }
    }
    
    
    private func miniPlayer(for song: SavedSong) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ArtworkThumbnail(
                    colors: song.artworkColors,
                    isPlaying: playback.isPlaying,
                    size: 48,
                    onTapPlay: { playback.togglePlayPause() }
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(Theme.Typography.miniPlayerTitle)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text(song.genre.capitalized)
                        .font(Theme.Typography.trackMeta)
                        .foregroundStyle(Theme.textSecondary)
                }
                
                Spacer(minLength: 8)
                
                HStack(spacing: 20) {
                    Button(action: playPrevious) {
                        Image(systemName: "backward.end.fill")
                    }
                    Button(action: { playback.togglePlayPause() }) {
                        Circle()
                            .fill(Theme.surfaceMuted)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: playback.isPlaying ? "pause.fill" : "play.fill")
                            )
                    }
                    Button(action: playNext) {
                        Image(systemName: "forward.end.fill")
                    }
                }
                .font(.system(size: AdaptiveFontSize.adaptive16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .buttonStyle(.plain)
            }
            
            WaveformScrubberView(
                amplitudes: amplitudes,
                progress: playbackProgress,
                onSeek: { fraction in
                    playback.seek(toProgress: fraction)
                }
            )
            .frame(height: 46)
        }
        .padding(.horizontal, Theme.Layout.screenPadding)
        .padding(.vertical, 12)
        .background(
            Theme.miniPlayerBackground
                .overlay(Rectangle().fill(Theme.stroke).frame(height: 1), alignment: .top)
        )
    }
    
    
    private var playbackProgress: Double {
        guard playback.duration > 0 else { return 0 }
        return min(1, max(0, playback.currentTime / playback.duration))
    }
    
    
    private var filteredSongs: [SavedSong] {
        var result = store.songs
        
        if let selectedGenre {
            result = result.filter { normalize($0.genre) == normalize(selectedGenre.rawValue) }
        }
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(query) }
        }
        
        return sortedByCurrentOption(result)
    }
    
    
    private func sortedByCurrentOption(_ songs: [SavedSong]) -> [SavedSong] {
        switch sortOption {
        case .newestFirst:
            return songs.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            return songs.sorted { $0.createdAt < $1.createdAt }
        case .titleAZ:
            return songs.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .longestFirst, .shortestFirst:
            return songs.sorted { lhs, rhs in
                let l = durations.duration(for: lhs, fileURL: store.fileURL(for: lhs)) ?? 0
                let r = durations.duration(for: rhs, fileURL: store.fileURL(for: rhs)) ?? 0
                return sortOption == .longestFirst ? l > r : l < r
            }
        }
    }
    
    
    private func normalize(_ value: String) -> String {
        value.lowercased().filter { $0.isLetter || $0.isNumber }
    }
    
    
    private func togglePlay(_ song: SavedSong) {
        Task {
            amplitudes = await WaveformExtractor.amplitudes(for: store.fileURL(for: song), sampleCount: waveformBarCount)
        }
        
        if playback.currentSong?.id == song.id {
            playback.togglePlayPause()
        } else {
            playback.play(song, url: store.fileURL(for: song))
        }
    }
    
    
    private func playNext() {
        playback.advance(by: 1, in: filteredSongs) { store.fileURL(for: $0) }
    }
    
    
    private func playPrevious() {
        playback.advance(by: -1, in: filteredSongs) { store.fileURL(for: $0) }
    }
    
    
    private func delete(_ song: SavedSong) {
        if playback.currentSong?.id == song.id {
            playback.stop()
        }
        store.delete(song)
    }
    
    
    private func share(_ song: SavedSong) {
        if inAppPurchaseViewModel.isSubscribed {
            shareURL = store.fileURL(for: song)
            isShareSheetPresented = true
        }else{
            showPaywall = true
        }
    }
    
    
    private func openPremium() {
        showPaywall = true
    }
}


#Preview {
    LibraryView()
        .environmentObject(TrackStore())
        .environmentObject(DurationCache())
        .environmentObject(PlaybackController())
        .environmentObject(InAppPurchaseViewModel())
}
