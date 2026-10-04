//
//  NotificationManager.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 20.08.2026.
//

import Foundation
import UserNotifications


final class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    
    func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        return settings.authorizationStatus == .authorized
    }
    
    
    func sendSongGeneratedNotification(title: String) {
        
        let content = UNMutableNotificationContent()
        content.title = "Your song is ready 🎵"
        content.body = "\(title) has finished generating."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "song-generated-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    
    func disableNotifications() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
}
