import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep = 0
    @State private var name = ""
    @State private var username = ""
    @State private var isGoogleSignIn = false
    @State private var selectedInterests: [String] = []
    @State private var expandedCategory: String? = nil
    @State private var isComplete = false
    
    @State private var profile = UserProfile()
    
    // Interest categories and subcategories
    let categories = [
        InterestCategory(name: "Sports", icon: "sportscourt.fill", 
                        subcategories: ["NFL", "NBA", "MLB", "Soccer", "NHL", "Cricket", "Tennis", "Golf", "F1 Racing", "UFC", "Boxing"]),
        InterestCategory(name: "News", icon: "newspaper.fill", 
                        subcategories: ["Weather", "History", "Politics", "Health", "General News", "Business", "Technology", "Science"]),
        InterestCategory(name: "Music", icon: "music.note", 
                        subcategories: ["Pop", "Hip-Hop/Rap", "Country", "Latino Music", "R&B/Soul", "Rock", "EDM", "Classical", "Jazz", "K-Pop"]),
        InterestCategory(name: "Entertainment", icon: "film.fill", 
                        subcategories: ["Industry News", "Digital Creators", "Movies", "Celebrity", "TV Shows", "Gaming", "Anime", "Broadway"]),
        InterestCategory(name: "Lifestyle", icon: "heart.fill", 
                        subcategories: ["Parenting", "DIY & Home", "Travel", "Fitness & Wellness", "Food", "Fashion", "Beauty", "Design"]),
        InterestCategory(name: "Technology", icon: "desktopcomputer", 
                        subcategories: ["AI", "Programming", "Gadgets", "Web Development", "Mobile Apps", "Blockchain", "Cyber Security"]),
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Progress indicator and Skip button
                HStack {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { step in
                            Circle()
                                .fill(currentStep >= step ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Skip for now") {
                        completeOnboarding()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 16, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Main content
                VStack(spacing: 30) {
                    switch currentStep {
                    case 0:
                        welcomeView
                    case 1:
                        nameUsernameView
                    case 2:
                        interestsView
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                if currentStep > 0 {
                                    currentStep -= 1
                                }
                            }
                        }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            nextStep()
                        }
                    }) {
                        Text(currentStep == 2 ? "Finish" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isNextEnabled ? Color.blue : Color.blue.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .disabled(!isNextEnabled)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Sub Views
    
    var welcomeView: some View {
        VStack(spacing: 30) {
            Image(systemName: "face.smiling.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            Text("Welcome to MoodGPT")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Track moods of your contacts and get connected with your city's emotional pulse")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    var nameUsernameView: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Tell us about yourself")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Name")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("", text: $name)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .placeholder(when: name.isEmpty) {
                        Text("Enter your name").foregroundColor(.white.opacity(0.5))
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose a Username")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("", text: $username)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .placeholder(when: username.isEmpty) {
                        Text("@username").foregroundColor(.white.opacity(0.5))
                    }
            }
            
            // Google Sign In Button
            Button(action: {
                // In a real app, implement Google Sign In
                isGoogleSignIn = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("Sign in with Google")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    var interestsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Your Interests")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Choose topics that interest you")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 4)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(categories, id: \.name) { category in
                        CategoryView(
                            category: category,
                            isExpanded: expandedCategory == category.name,
                            selectedInterests: $selectedInterests,
                            onToggle: {
                                withAnimation {
                                    if expandedCategory == category.name {
                                        expandedCategory = nil
                                    } else {
                                        expandedCategory = category.name
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    var isNextEnabled: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            // Allow empty fields since we have a skip button now
            return true
        case 2:
            // No minimum required selections since we have a skip button
            return true
        default:
            return false
        }
    }
    
    func nextStep() {
        if currentStep < 2 {
            currentStep += 1
        } else {
            completeOnboarding()
        }
    }
    
    func completeOnboarding() {
        finalizeProfile()
        
        // Make sure we set the binding to trigger the onChange in MoodgptApp
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
    
    func finalizeProfile() {
        profile.name = name
        profile.username = username
        profile.isGoogleSignIn = isGoogleSignIn
        
        // Save selected interests from categories
        var selectedInterestsList: [Interest] = []
        for interestName in selectedInterests {
            selectedInterestsList.append(Interest(name: interestName, icon: getIconForInterest(interestName)))
        }
        profile.interests = selectedInterestsList
        
        // In a real app, save profile to UserDefaults or a database
        saveProfileToUserDefaults(profile)
    }
    
    // Get an appropriate icon for an interest
    func getIconForInterest(_ interest: String) -> String {
        // Map specific subcategories to icons
        let iconMapping: [String: String] = [
            "NFL": "football.fill",
            "NBA": "basketball.fill",
            "MLB": "baseball.fill",
            "Soccer": "soccerball",
            "NHL": "hockey.puck.fill",
            "Cricket": "cricket.ball",
            "Weather": "cloud.sun.fill",
            "Politics": "building.columns.fill",
            "Pop": "music.note",
            "Hip-Hop/Rap": "beats.headphones",
            "Movies": "film.fill",
            "DIY & Home": "hammer.fill",
            "Travel": "airplane",
            "Fitness & Wellness": "figure.walk"
        ]
        
        // Return mapped icon or a default one
        return iconMapping[interest] ?? "star.fill"
    }
    
    // Save profile to UserDefaults (simplified)
    func saveProfileToUserDefaults(_ profile: UserProfile) {
        // In a real app, you would use proper encoding/decoding
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        UserDefaults.standard.set(profile.name, forKey: "userName")
        UserDefaults.standard.set(profile.username, forKey: "userUsername")
    }
}

// MARK: - Supporting Views and Models

struct InterestCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let subcategories: [String]
}

struct CategoryView: View {
    let category: InterestCategory
    let isExpanded: Bool
    @Binding var selectedInterests: [String]
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Category header
            Button(action: onToggle) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
            }
            
            // Subcategories
            if isExpanded {
                VStack(spacing: 2) {
                    ForEach(category.subcategories, id: \.self) { subcategory in
                        SubcategoryButton(
                            title: subcategory,
                            isSelected: selectedInterests.contains(subcategory),
                            onToggle: {
                                toggleSelection(subcategory)
                            }
                        )
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            // Show more functionality would go here
                        }) {
                            HStack {
                                Text("Show more")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                }
                .padding(.leading, 8)
            }
        }
    }
    
    private func toggleSelection(_ subcategory: String) {
        if selectedInterests.contains(subcategory) {
            selectedInterests.removeAll { $0 == subcategory }
        } else {
            selectedInterests.append(subcategory)
        }
    }
}

struct SubcategoryButton: View {
    let title: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
            )
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
} 