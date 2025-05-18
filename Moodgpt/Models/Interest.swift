import Foundation

struct Interest: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var isSelected: Bool = false

    // All available interests (combined from both models)
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
        Interest(name: "Volunteering", icon: "heart.circle.fill"),
        Interest(name: "Finance", icon: "dollarsign.circle.fill"),
        Interest(name: "Writing", icon: "pencil")
    ]
} 