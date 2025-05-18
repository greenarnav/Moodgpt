import Foundation
import Combine

struct EmotionDetails {
    let id: UUID
    let contactId: UUID
    let primaryEmotion: Emotion
    let emotionIntensity: Double
    let secondaryEmotions: [Emotion]
    let moodTriggers: [String]
    let recentMoodChanges: [EmotionChange]
    let timestamp: Date
    
    struct EmotionChange: Identifiable {
        let id = UUID()
        let fromEmotion: Emotion
        let toEmotion: Emotion
        let timestamp: Date
        let reason: String?
    }
}

class EmotionAPI {
    static let shared = EmotionAPI()
    
    private init() {}
    
    // Fetch detailed emotions for a contact
    func fetchDetailedEmotions(for contactId: UUID) -> AnyPublisher<EmotionDetails, Error> {
        // In a real app, this would make a network request
        // For demo purposes, we're simulating an API call with a delay
        return Future<EmotionDetails, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Generate mock data based on contactId
                let details = self.generateMockEmotionDetails(for: contactId)
                promise(.success(details))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Generate mock emotion data
    private func generateMockEmotionDetails(for contactId: UUID) -> EmotionDetails {
        // Use the contact ID to ensure consistent results for the same contact
        let idString = contactId.uuidString
        let hashValue = idString.hash
        
        // Use the hash to determine the primary emotion (make it consistent for the same contact)
        let emotions = Emotion.allCases
        let primaryEmotionIndex = abs(hashValue) % emotions.count
        let primaryEmotion = emotions[primaryEmotionIndex]
        
        // Generate secondary emotions (different from primary)
        var secondaryEmotions: [Emotion] = []
        let secondaryCount = abs((hashValue / 100) % 3) + 1 // 1-3 secondary emotions
        
        var availableEmotions = emotions.filter { $0 != primaryEmotion }
        for _ in 0..<secondaryCount {
            if let emotion = availableEmotions.randomElement(),
               let index = availableEmotions.firstIndex(of: emotion) {
                secondaryEmotions.append(emotion)
                availableEmotions.remove(at: index)
            }
        }
        
        // Generate mood triggers
        let allTriggers = [
            "Work stress", "Family gathering", "Good news", "Financial concerns",
            "Health issues", "Social media", "Weather", "Traffic", "Conversation",
            "Music", "Food", "Sleep quality", "Exercise", "Achievement", "Failure"
        ]
        
        let triggerCount = abs((hashValue / 1000) % 4) + 1 // 1-4 triggers
        var moodTriggers: [String] = []
        
        for i in 0..<triggerCount {
            let index = abs((hashValue + i * 100) % allTriggers.count)
            moodTriggers.append(allTriggers[index])
        }
        
        // Generate recent mood changes
        let changeCount = abs((hashValue / 10000) % 3) + 1 // 1-3 changes
        var recentMoodChanges: [EmotionDetails.EmotionChange] = []
        
        for i in 0..<changeCount {
            let fromIndex = abs((hashValue + i * 1000) % emotions.count)
            let fromEmotion = emotions[fromIndex]
            
            // Ensure toEmotion is the primary one for the most recent change
            let toEmotion = i == 0 ? primaryEmotion : emotions[(fromIndex + 1) % emotions.count]
            
            let reasons = [
                "After receiving good news",
                "Following a stressful meeting",
                "After talking with friends",
                "Due to weather changes",
                "Following a conversation",
                nil // Sometimes no reason is captured
            ]
            
            let reasonIndex = abs((hashValue + i * 5000) % reasons.count)
            let reason = reasons[reasonIndex]
            
            let hoursAgo = (i + 1) * 12 // Each change is 12 hours older than the previous
            let timestamp = Calendar.current.date(byAdding: .hour, value: -hoursAgo, to: Date()) ?? Date()
            
            recentMoodChanges.append(
                EmotionDetails.EmotionChange(
                    fromEmotion: fromEmotion,
                    toEmotion: toEmotion,
                    timestamp: timestamp,
                    reason: reason
                )
            )
        }
        
        return EmotionDetails(
            id: UUID(),
            contactId: contactId,
            primaryEmotion: primaryEmotion,
            emotionIntensity: Double(abs(hashValue % 100)) / 100.0, // 0.0-1.0
            secondaryEmotions: secondaryEmotions,
            moodTriggers: moodTriggers,
            recentMoodChanges: recentMoodChanges,
            timestamp: Date()
        )
    }
} 