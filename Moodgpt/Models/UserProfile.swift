import Foundation

struct UserProfile {
    var name: String = ""
    var username: String = ""
    var email: String = ""
    var isGoogleSignIn: Bool = false
    var interests: [Interest] = []
    var sportPreferences: [Sport] = []
    
    static let shared = UserProfile()
}

struct Interest: Identifiable {
    var id = UUID()
    var name: String
    var icon: String
}

struct Sport: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var isSelected: Bool = false
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