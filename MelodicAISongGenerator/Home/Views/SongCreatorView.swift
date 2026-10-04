//
//  HomeView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 01.08.2026.
//


import Foundation
import SwiftUI
import BackgroundTasks
import StoreKit


struct SongCreatorView: View {
    
    @EnvironmentObject var trackStore: TrackStore
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var inAppPurchaseViewModel: InAppPurchaseViewModel
    
    
    let client = ElevenLabsMusicClient(apiKey: "sk_c76468e117ae16411e0c711a89c6b43643cfb4d623ea4636")
    
    @State private var songDescription: String = ""
    @State private var selectedGenres: Set<Genre> = [.rock]
    @State private var selectedMoods: Set<Mood> = [.energetic]
    @State private var selectedTempo: Tempo = .medium
    @State private var selectedTempoBPM = 110
    @State private var selectedVocals: VocalsOption = .none
    @State private var customLyrics: String = ""
    @State private var setTrackName: String = ""
    @State private var selectedDuration: SongDuration = .short
    @State private var selectedDurationMS = 60_000
    @State private var showPaywall = false
    @State private var showPlayer = false
    
    private let descriptionLimit = 300
    private let lyricsLimit = 3000
    
    var body: some View {
        ZStack {
            background
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                    header
                    descriptionField
                    genreSection
                    moodSection
                    tempoSection
                    vocalsSection
                    
                    if selectedVocals == .customLyrics {
                        lyricsField
                    }
                    
                    durationSection
                    nameTrackField
                    generateButton
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            
            if trackStore.isGenerating {
                GeneratingScreenView()
            }
            
            
        }
        .onChange(of: selectedDuration, { oldValue, newValue in
            switch newValue {
            case .short:
                selectedDurationMS = 30_000
            case .medium:
                selectedDurationMS = 60_000
            case .long:
                selectedDurationMS = 120_000
            }
        })
        .onChange(of: selectedTempo, { oldValue, newValue in
            switch newValue {
            case .slow:
                selectedTempoBPM = 70
            case .medium:
                selectedTempoBPM = 110
            case .fast:
                selectedTempoBPM = 140
            }
        })
        .onTapGesture {
            hideKeyboard()
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .onDisappear {
                    Task {
                        for sub in inAppPurchaseViewModel.products {
                            inAppPurchaseViewModel.isSubscribed = await inAppPurchaseViewModel.checkSubscriptionStatus(for: sub.id)
                        }
                    }
                }
        }
        .fullScreenCover(isPresented: $showPlayer) {
            if let firstSong = trackStore.songs.first {
                TrackReadyView(song: firstSong, store: trackStore, onBack: {
                    showPlayer = false
                })
            }
        }
    }
    
    
    private var background: some View {
        LinearGradient(
            colors: [.black, Color(hex: "#080C23")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    
    private var header: some View {
        HStack(alignment: .top) {
            (
                Text("What song do you\nwant to ")
                    .foregroundStyle(Theme.textPrimary)
                +
                Text("create?")
                    .foregroundStyle( LinearGradient(colors: [Theme.gradientBlue, Theme.gradientPurple, Theme.gradientPink, Theme.gradientPink], startPoint: .leading, endPoint: .trailing))
            )
            .font(Theme.Typography.title)
            .lineSpacing(4)
            
            Spacer()
            
            if !inAppPurchaseViewModel.isSubscribed {
                Image("prem2")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        showPaywall = true
                    }
            }
        }
    }
    
    
    private var descriptionField: some View {
        CounterTextEditor(
            text: $songDescription,
            placeholder: "Describe your song...\n\nExample: A chill lo-fi beat about late night drives in the city",
            characterLimit: descriptionLimit,
            minHeight: 130,
            trailingIcon: "sparkles"
        )
    }
    
    
    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Genre", hint: "Choose one or more")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Layout.chipSpacing) {
                    ForEach(Genre.allCases) { genre in
                        ChipView(
                            title: genre.title,
                            isSelected: selectedGenres.contains(genre),
                            action: { toggle(genre, in: &selectedGenres) }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Mood", hint: "Choose one or more")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Layout.chipSpacing) {
                    ForEach(Mood.allCases) { mood in
                        IconChipView(
                            title: mood.title,
                            systemImage: mood.systemImage,
                            iconColor: mood.iconColor,
                            isSelected: selectedMoods.contains(mood),
                            action: { toggle(mood, in: &selectedMoods) }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    
    private var tempoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tempo")
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.textPrimary)
            
            SegmentedGroup(
                options: Tempo.allCases,
                title: { $0.title },
                icon: { $0.systemImage },
                isSelected: { $0 == selectedTempo },
                onSelect: { selectedTempo = $0 }
            )
        }
    }
    
    
    private var vocalsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Vocals")
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.textPrimary)
            
            SegmentedGroup(
                options: VocalsOption.allCases,
                title: { $0.title },
                icon: { $0.systemImage },
                isSelected: { $0 == selectedVocals },
                onSelect: { selectedVocals = $0 }
            )
            .onChange(of: selectedVocals) { oldValue, newValue in
                if !inAppPurchaseViewModel.isSubscribed {
                    switch selectedVocals {
                    case .none:
                        selectedVocals = .none
                    case .vocals:
                        selectedVocals = .vocals
                    case .customLyrics:
                        selectedVocals = .none
                        showPaywall = true
                    }
                }
            }
        }
    }
    
    
    private var lyricsField: some View {
        CounterTextEditor(
            text: $customLyrics,
            placeholder: "Enter your own lyrics...",
            characterLimit: lyricsLimit,
            minHeight: 130
        )
    }
    
    
    private var nameTrackField: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge, style: .continuous)
                        .stroke(Theme.stroke, lineWidth: 1)
                )
            
            TextField("Enter track name", text: $setTrackName)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.vertical)
                .padding(.leading)
                .onChange(of: setTrackName) { newValue in
                    if newValue.count > 15 {
                        setTrackName = String(newValue.prefix(15))
                    }
                }
        }
    }
    
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Duration")
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.textPrimary)
            
            SegmentedGroup(
                options: SongDuration.allCases,
                title: { $0.title },
                isSelected: { $0 == selectedDuration },
                onSelect: { selectedDuration = $0 }
            )
            .onChange(of: selectedDuration) { oldValue, newValue in
                if !inAppPurchaseViewModel.isSubscribed {
                    switch selectedDuration {
                        
                    case .short:
                        selectedDuration = .short
                    case .medium:
                        showPaywall = true
                        selectedDuration = .short
                    case .long:
                        showPaywall = true
                        selectedDuration = .short
                    }
                }
            }
            
        }
    }
    
    
    private var generateButton: some View {
        
        if inAppPurchaseViewModel.isSubscribed {
            switch selectedVocals {
            case .none:
                GradientActionButton(
                    title: "Generate Song",
                    systemImage: "sparkles",
                    action: generateSongNoneLyrics
                )
                .padding(.top, 4)
            case .vocals:
                GradientActionButton(
                    title: "Generate Song",
                    systemImage: "sparkles",
                    action: generateSongDefault
                )
                .padding(.top, 4)
            case .customLyrics:
                GradientActionButton(
                    title: "Generate Song",
                    systemImage: "sparkles",
                    action: generateSongWithLyrics
                )
                .padding(.top, 4)
            }
        }else{
            GradientActionButton(
                title: "Generate Song",
                systemImage: "sparkles",
                action: generateSongNoneNotPremiumUser
            )
            .padding(.top, 4)
        }
        
        
        
    }
    
    
    private func generateSongDefault() {
        
        
        hideKeyboard()
        trackStore.isGenerating = true
        Task {
            do {
                let options = MusicGenerationOptions(
                    genre: "\(selectedGenres)",
                    mood: "\(selectedMoods)",
                    tempoBPM: selectedTempoBPM,
                    styleTags: [songDescription],
                    vocals: .anyVoice,
                    durationMs: selectedDurationMS
                )
                let result = try await client.generateTrackDetailed(options: options)
                trackStore.addTrack(result, fallbackGenre: "\(String(describing: selectedGenres.first?.rawValue ?? "Unknown"))", title: setTrackName)
                
                settingsViewModel.requestReview()
                
                print("Завершено генерації")
                if settingsViewModel.notificationsIsOn {
                    if await NotificationManager.shared.isAuthorized() {
                        NotificationManager.shared.sendSongGeneratedNotification(
                            title: setTrackName
                        )
                    }
                }
                
                
                showPlayer = true
            } catch {
                print("Помилка генерації: \(error.localizedDescription)")
            }
        }
        
        
        
        
        
        
    }
    
    
    private func generateSongWithLyrics() {
        hideKeyboard()
        trackStore.isGenerating = true
        Task {
            do {
                let options = MusicGenerationOptions(
                    genre: "\(selectedGenres)",
                    mood: "\(selectedMoods)",
                    tempoBPM: selectedTempoBPM,
                    styleTags: [songDescription],
                    vocals: .withLyrics(customLyrics),
                    durationMs: selectedDurationMS
                )
                let result = try await client.generateTrackDetailed(options: options)
                trackStore.addTrack(result, fallbackGenre: "\(String(describing: selectedGenres.first?.rawValue ?? "Unknown"))", title: setTrackName)
                
                print("Завершено генерації")
                settingsViewModel.requestReview()
                
                if settingsViewModel.notificationsIsOn {
                    if await NotificationManager.shared.isAuthorized() {
                        NotificationManager.shared.sendSongGeneratedNotification(
                            title: setTrackName
                        )
                    }
                }
                
                showPlayer = true
            } catch {
                print("Помилка генерації: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func generateSongNoneLyrics() {
        hideKeyboard()
        trackStore.isGenerating = true
        Task {
            do {
                let options = MusicGenerationOptions(
                    genre: "\(selectedGenres)",
                    mood: "\(selectedMoods)",
                    tempoBPM: selectedTempoBPM,
                    styleTags: [songDescription],
                    vocals: .none,
                    durationMs: selectedDurationMS
                )
                let result = try await client.generateTrackDetailed(options: options)
                trackStore.addTrack(result, fallbackGenre: "\(String(describing: selectedGenres.first?.rawValue ?? "Unknown"))", title: setTrackName)
                
                print("Завершено генерації")
                settingsViewModel.requestReview()
                
                if settingsViewModel.notificationsIsOn {
                    if await NotificationManager.shared.isAuthorized() {
                        NotificationManager.shared.sendSongGeneratedNotification(
                            title: setTrackName
                        )
                    }
                }
                
                showPlayer = true
            } catch {
                print("Помилка генерації: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func generateSongNoneNotPremiumUser() {
        guard FreeGenerationLimiter.canGenerate() else {
            showPaywall = true
            return
        }
        
        hideKeyboard()
        trackStore.isGenerating = true
        Task {
            do {
                let options = MusicGenerationOptions(
                    genre: "\(selectedGenres)",
                    mood: "\(selectedMoods)",
                    tempoBPM: selectedTempoBPM,
                    styleTags: [songDescription, "Do not respond to the suggestion to make the track longer than 30 seconds, and do not add custom lyrics."],
                    vocals: .none,
                    durationMs: 30_000
                )
                let result = try await client.generateTrackDetailed(options: options)
                trackStore.addTrack(result, fallbackGenre: "\(String(describing: selectedGenres.first?.rawValue ?? "Unknown"))", title: setTrackName)
                
                FreeGenerationLimiter.recordGeneration()
                
                print("Завершено генерації")
                settingsViewModel.requestReview()
                
                if settingsViewModel.notificationsIsOn {
                    if await NotificationManager.shared.isAuthorized() {
                        NotificationManager.shared.sendSongGeneratedNotification(
                            title: setTrackName
                        )
                    }
                }
                
                showPlayer = true
            } catch {
                print("Помилка генерації: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func toggle<T: Hashable>(_ value: T, in set: inout Set<T>) {
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
    }
}


#Preview {
    SongCreatorView()
        .environmentObject(TrackStore())
        .environmentObject(SettingsViewModel())
        .environmentObject(InAppPurchaseViewModel())
}
