//
//  FreeGenerationLimiter.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 22.08.2026.
//


import Foundation

enum FreeGenerationLimiter {
    private static let dailyLimit = 3
    private static let countKey = "freeGenerationsToday"
    private static let dateKey = "freeGenerationsDate"

    static func canGenerate() -> Bool {
        resetIfNewDay()
        return UserDefaults.standard.integer(forKey: countKey) < dailyLimit
    }

    static func remainingToday() -> Int {
        resetIfNewDay()
        return max(0, dailyLimit - UserDefaults.standard.integer(forKey: countKey))
    }

    static func recordGeneration() {
        resetIfNewDay()
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: countKey) + 1, forKey: countKey)
    }

    private static func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: dateKey) as? Date ?? .distantPast
        if !Calendar.current.isDate(lastDate, inSameDayAs: today) {
            UserDefaults.standard.set(0, forKey: countKey)
            UserDefaults.standard.set(today, forKey: dateKey)
        }
    }
}
