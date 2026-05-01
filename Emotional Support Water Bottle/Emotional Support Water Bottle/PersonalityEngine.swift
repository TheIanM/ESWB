//
//  PersonalityEngine.swift
//  Emotional Support Water Bottle
//
//  Loads personality JSON files, picks random messages, supports mood-aware selection.
//

import Foundation

// MARK: - Models

struct Personality: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let messages: [String]
    var moodResponses: [String: [String]]?
    
    /// Available personalities (hardcoded list matching bundled JSON files)
    static let allIDs = [
        "excited-dog",
        "gentle-parenting",
        "quotable-water",
        "passive-aggressive",
        "emotional-support",
        "water-facts"
    ]
}

// MARK: - Engine

class PersonalityEngine {
    
    private var loadedPersonalities: [String: Personality] = [:]
    private var recentMessages: [String] = []
    private let maxRecent = 5  // avoid repeating the last N messages
    
    /// Load a personality from bundled JSON
    func load(personalityID: String) -> Personality? {
        // Return cached if available
        if let cached = loadedPersonalities[personalityID] {
            return cached
        }
        
        guard let url = Bundle.main.url(
            forResource: personalityID,
            withExtension: "json",
            subdirectory: "Personalities"
        ) else {
            #if DEBUG
            print("[PersonalityEngine] Could not find JSON for: \(personalityID)")
            #endif
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let personality = try JSONDecoder().decode(Personality.self, from: data)
            loadedPersonalities[personalityID] = personality
            return personality
        } catch {
            #if DEBUG
            print("[PersonalityEngine] Failed to decode \(personalityID): \(error)")
            #endif
            return nil
        }
    }
    
    /// Load all available personalities
    func loadAll() -> [Personality] {
        Personality.allIDs.compactMap { load(personalityID: $0) }
    }
    
    /// Get a random message for the given personality
    func randomMessage(personalityID: String) -> String {
        guard let personality = load(personalityID: personalityID),
              !personality.messages.isEmpty else {
            return "Time to drink water! 💧"
        }
        
        // Filter out recently used messages to avoid repeats
        let available = personality.messages.filter { !recentMessages.contains($0) }
        let pool = available.isEmpty ? personality.messages : available
        
        let message = pool.randomElement()!
        recentMessages.append(message)
        if recentMessages.count > maxRecent {
            recentMessages.removeFirst()
        }
        
        return message
    }
    
    /// Get a mood-aware message (only for Emotional Support personality)
    func moodMessage(mood: String) -> String {
        guard let personality = load(personalityID: "emotional-support"),
              let responses = personality.moodResponses,
              let moodMessages = responses[mood],
              !moodMessages.isEmpty else {
            return randomMessage(personalityID: "emotional-support")
        }
        
        let available = moodMessages.filter { !recentMessages.contains($0) }
        let pool = available.isEmpty ? moodMessages : available
        
        let message = pool.randomElement()!
        recentMessages.append(message)
        if recentMessages.count > maxRecent {
            recentMessages.removeFirst()
        }
        
        return message
    }
}
