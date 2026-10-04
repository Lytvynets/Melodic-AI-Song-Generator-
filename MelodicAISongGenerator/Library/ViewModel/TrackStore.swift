//
//  TrackStore.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//


import Foundation
import AVFoundation
import SwiftUI
internal import Combine


@MainActor
final class TrackStore: ObservableObject {
    
    @Published var isGenerating = false
    @Published private(set) var songs: [SavedSong] = []
    
    private let folder: URL
    private let metadataURL: URL
    
    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        folder = documents.appendingPathComponent("Songs", isDirectory: true)
        metadataURL = documents.appendingPathComponent("songs.json")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        load()
    }
    
    
    func addTrack(_ result: DetailedComposeResult, fallbackGenre: String = "Unknown", title: String?) {
        let fileName = "\(UUID().uuidString).mp3"
        let fileURL = folder.appendingPathComponent(fileName)
        
        do {
            try result.audioData.write(to: fileURL, options: .atomic)
            isGenerating = false
        } catch {
            isGenerating = false
            print("Не вдалося зберегти трек: \(error.localizedDescription)")
            return
        }
        
        if title == "" {
            let title = "Untitled Track"
            let genre = result.songMetadata?.genres?.first ?? fallbackGenre
            let song = SavedSong(id: UUID(), title: title, genre: genre, fileName: fileName, createdAt: Date())
            songs.insert(song, at: 0)
            persist()
        }else{
            let genre = result.songMetadata?.genres?.first ?? fallbackGenre
            let song = SavedSong(id: UUID(), title: title ?? "Untitled Track", genre: genre, fileName: fileName, createdAt: Date())
            songs.insert(song, at: 0)
            persist()
        }
    }
    
    func delete(_ song: SavedSong) {
        try? FileManager.default.removeItem(at: fileURL(for: song))
        songs.removeAll { $0.id == song.id }
        persist()
    }
    
    func fileURL(for song: SavedSong) -> URL {
        folder.appendingPathComponent(song.fileName)
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(songs) {
            try? data.write(to: metadataURL, options: .atomic)
        }
    }
    
    private func load() {
        guard let data = try? Data(contentsOf: metadataURL) else { return }
        songs = (try? JSONDecoder().decode([SavedSong].self, from: data)) ?? []
    }
}


@MainActor
final class DurationCache: ObservableObject {
    
    @Published private(set) var durations: [UUID: TimeInterval] = [:]
    
    private var loadingIDs: Set<UUID> = []
    
    func duration(for song: SavedSong, fileURL: URL) -> TimeInterval? {
        if let cached = durations[song.id] {
            return cached
        }
        guard !loadingIDs.contains(song.id) else { return nil }
        loadingIDs.insert(song.id)
        
        Task {
            await load(songID: song.id, url: fileURL)
        }
        return nil
    }
    
    private func load(songID: UUID, url: URL) async {
        defer { loadingIDs.remove(songID) }
        
        let asset = AVURLAsset(url: url)
        guard let cmDuration = try? await asset.load(.duration) else { return }
        
        let seconds = CMTimeGetSeconds(cmDuration)
        guard seconds.isFinite, seconds >= 0 else { return }
        
        durations[songID] = seconds
    }
}


enum DurationFormatter {
    static func format(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
