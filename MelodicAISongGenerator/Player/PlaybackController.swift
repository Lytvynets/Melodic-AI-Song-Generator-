//
//  PlaybackController.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//

import Foundation
import AVFoundation
internal import Combine

@MainActor
final class PlaybackController: NSObject, ObservableObject {
    
    @Published private(set) var currentSong: SavedSong?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    
    var onTrackFinished: ((SavedSong) -> Void)?
    
    private var player: AVAudioPlayer?
    private var delegateProxy: PlayerDelegateProxy?
    private var progressTimer: Timer?
    
    
    func play(_ song: SavedSong, url: URL) {
        stopTimer()
        
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            let proxy = PlayerDelegateProxy { [weak self] in
                self?.handleFinish()
            }
            newPlayer.delegate = proxy
            
            newPlayer.play()
            
            player = newPlayer
            delegateProxy = proxy
            currentSong = song
            duration = newPlayer.duration
            currentTime = 0
            isPlaying = true
            startTimer()
        } catch {
            print("Не вдалося відтворити трек: \(error.localizedDescription)")
        }
    }

    
    func togglePlayPause() {
        guard let player else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopTimer()
        } else {
            player.play()
            isPlaying = true
            startTimer()
        }
    }
    
    
    func stop() {
        player?.stop()
        player = nil
        delegateProxy = nil
        currentSong = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        stopTimer()
    }

    
    func advance(by offset: Int, in songs: [SavedSong], resolve fileURL: (SavedSong) -> URL) {
        guard let current = currentSong,
              let index = songs.firstIndex(where: { $0.id == current.id }) else { return }
        
        let newIndex = index + offset
        guard songs.indices.contains(newIndex) else { return }
        
        let next = songs[newIndex]
        play(next, url: fileURL(next))
    }

    
    func seek(to time: TimeInterval) {
        guard let player else { return }
        let clamped = min(max(0, time), player.duration)
        player.currentTime = clamped
        currentTime = clamped
    }

    
    func seek(toProgress progress: Double) {
        seek(to: duration * min(max(0, progress), 1))
    }
    
    
    private func handleFinish() {
        isPlaying = false
        stopTimer()
        if let song = currentSong {
            onTrackFinished?(song)
        }
    }
    
    
    private func startTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.currentTime = self.player?.currentTime ?? 0
            }
        }
    }
    
    
    private func stopTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}


private final class PlayerDelegateProxy: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.onFinish()
        }
    }
}
