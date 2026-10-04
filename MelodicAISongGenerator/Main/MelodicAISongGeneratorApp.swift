//
//  MelodicAISongGeneratorApp.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 31.07.2026.
//

import SwiftUI

@main
struct MelodicAISongGeneratorApp: App {
    
    @StateObject var trackStore = TrackStore()
    @StateObject var playback = PlaybackController()
    @StateObject var durations = DurationCache()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject var inAppPurchaseViewModel = InAppPurchaseViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(trackStore)
                .environmentObject(playback)
                .environmentObject(durations)
                .environmentObject(settingsViewModel)
                .environmentObject(inAppPurchaseViewModel)
        }
    }
}
