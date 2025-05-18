import Foundation

struct UserProfile {
    var id: String = UUID().uuidString
    var name: String = ""
    var username: String = ""
    var email: String = ""
    var isGoogleSignIn: Bool = false
    var interests: [Interest] = []
    var sportPreferences: [Sport] = []
    
    static let shared = UserProfile()
}

struct Interest: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var isSelected: Bool = false
}

struct Sport: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var isSelected: Bool = false
}

// All available interests
extension Interest {
    static let all: [Interest] = [
        Interest(name: "Sports", icon: "sportscourt.fill"),
        Interest(name: "Politics", icon: "building.columns.fill"),
        Interest(name: "Fashion", icon: "tshirt.fill"),
        Interest(name: "Technology", icon: "desktopcomputer"),
        Interest(name: "Movies", icon: "film.fill"),
        Interest(name: "Music", icon: "music.note"),
        Interest(name: "Books", icon: "book.fill"),
        Interest(name: "Travel", icon: "airplane"),
        Interest(name: "Food", icon: "fork.knife"),
        Interest(name: "Art", icon: "paintpalette.fill"),
        Interest(name: "Gaming", icon: "gamecontroller.fill"),
        Interest(name: "Photography", icon: "camera.fill"),
        Interest(name: "Science", icon: "atom"),
        Interest(name: "Health", icon: "heart.fill"),
        Interest(name: "Fitness", icon: "figure.walk"),
        Interest(name: "Business", icon: "briefcase.fill"),
        Interest(name: "Education", icon: "graduationcap.fill"),
        Interest(name: "Environment", icon: "leaf.fill"),
        Interest(name: "History", icon: "clock.fill"),
        Interest(name: "Psychology", icon: "brain.head.profile"),
        Interest(name: "Religion", icon: "hands.pray.fill"),
        Interest(name: "Philosophy", icon: "lightbulb.fill"),
        Interest(name: "News", icon: "newspaper.fill"),
        Interest(name: "Social Media", icon: "network"),
        Interest(name: "DIY", icon: "hammer.fill"),
        Interest(name: "Cooking", icon: "cooktop.fill"),
        Interest(name: "Languages", icon: "text.bubble.fill"),
        Interest(name: "Dance", icon: "figure.dance"),
        Interest(name: "Theater", icon: "theatermasks.fill"),
        Interest(name: "Pets", icon: "pawprint.fill"),
        Interest(name: "Nature", icon: "leaf.fill"),
        Interest(name: "Cars", icon: "car.fill"),
        Interest(name: "Investing", icon: "chart.line.uptrend.xyaxis"),
        Interest(name: "Real Estate", icon: "building.2.fill"),
        Interest(name: "Comedy", icon: "face.smiling.fill"),
        Interest(name: "Podcasts", icon: "mic.fill"),
        Interest(name: "Meditation", icon: "sparkles"),
        Interest(name: "Yoga", icon: "figure.mind.and.body"),
        Interest(name: "Astrology", icon: "star.fill"),
        Interest(name: "Volunteering", icon: "heart.circle.fill")
    ]
}

// All sports
extension Sport {
    static let all: [Sport] = [
        Sport(name: "Football", icon: "football.fill"),
        Sport(name: "Basketball", icon: "basketball.fill"),
        Sport(name: "Baseball", icon: "baseball.fill"),
        Sport(name: "Soccer", icon: "soccerball"),
        Sport(name: "Tennis", icon: "tennis.racket"),
        Sport(name: "Golf", icon: "figure.golf"),
        Sport(name: "Hockey", icon: "hockey.puck.fill"),
        Sport(name: "Volleyball", icon: "volleyball.fill"),
        Sport(name: "Cricket", icon: "cricket.ball"),
        Sport(name: "Rugby", icon: "rugby.ball"),
        Sport(name: "Swimming", icon: "figure.pool.swim"),
        Sport(name: "Cycling", icon: "bicycle"),
        Sport(name: "Running", icon: "figure.run"),
        Sport(name: "Boxing", icon: "figure.boxing"),
        Sport(name: "MMA", icon: "figure.martial.arts"),
        Sport(name: "Skiing", icon: "figure.skiing.downhill"),
        Sport(name: "Snowboarding", icon: "snowboard"),
        Sport(name: "Skateboarding", icon: "skateboard"),
        Sport(name: "Surfing", icon: "surfboard"),
        Sport(name: "Table Tennis", icon: "figure.table.tennis")
    ]
} 