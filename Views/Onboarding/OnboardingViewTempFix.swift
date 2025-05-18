import SwiftUI

// TEMPORARY FIX: Comment out GoogleSignIn until package is installed
// import GoogleSignIn

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
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // TEMPORARY FIX: Comment out GoogleAuthService until package is installed
    // @StateObject private var googleAuthService = GoogleAuthService.shared
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
            
            // TEMPORARY FIX: Comment out loading indicator until GoogleSignIn is installed
            /*
            if googleAuthService.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
                    .edgesIgnoringSafeArea(.all)
            }
            */
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Sign-In Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        // TEMPORARY FIX: Comment out Google user handling until package is installed
        /*
        .onReceive(googleAuthService.$currentUser) { user in
            if let user = user {
                if let email = user.profile?.email {
                    // User successfully signed in with Google
                    self.isGoogleSignIn = true
                    
                    // If the user has a name from Google, use it
                    if let googleName = user.profile?.name {
                        self.name = googleName
                    }
                    
                    // If the user has a given name, use it for the username suggestion
                    if let givenName = user.profile?.givenName?.lowercased() {
                        self.username = givenName
                    }
                    
                    // Move to the next step automatically if we're on step 1
                    if currentStep == 1 {
                        withAnimation {
                            currentStep = 2
                        }
                    }
                }
            }
        }
        */
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
            
            // Placeholder Google Sign In Button - temporarily modified
            Button(action: {
                // TEMPORARY FIX: Comment out Google sign-in until package is installed
                // handleGoogleSignIn()
                
                // Show an alert instead
                alertMessage = "Google Sign-In is currently being set up. Please try again later."
                showAlert = true
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
    
    // ... rest of original file content ...
    
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
        
        // Request permissions right after onboarding completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Trigger permission requests via notification
            NotificationCenter.default.post(name: NSNotification.Name("RequestPermissions"), object: nil)
        }
        
        // Make sure we set the binding to trigger the onChange in MoodgptApp
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
    
    // TEMPORARY FIX: Modified Google sign-in handling until package is installed
    func handleGoogleSignIn() {
        alertMessage = "Google Sign-In is currently being set up. Please try again later."
        showAlert = true
        
        // Original code commented out until GoogleSignIn is installed
        /*
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            alertMessage = "Cannot access root view controller"
            showAlert = true
            return
        }
        
        // Call the Google Sign-In service
        googleAuthService.signIn(presentingViewController: rootViewController) { success in
            if !success {
                if let error = googleAuthService.error {
                    alertMessage = "Sign-in failed: \(error.localizedDescription)"
                } else {
                    alertMessage = "Sign-in failed for unknown reason"
                }
                showAlert = true
            }
        }
        */
    }
    
    func finalizeProfile() {
        profile.name = name
        profile.username = username
        profile.isGoogleSignIn = isGoogleSignIn
        
        // TEMPORARY FIX: Comment out email setting until GoogleSignIn is installed
        /*
        // If user signed in with Google, get their email
        if isGoogleSignIn, let email = googleAuthService.currentUser?.profile?.email {
            profile.email = email
        }
        */
        
        // Save selected interests from categories
        var selectedInterestsList: [Interest] = []
        for interestName in selectedInterests {
            selectedInterestsList.append(Interest(name: interestName, icon: getIconForInterest(interestName)))
        }
        profile.interests = selectedInterestsList
        
        // Save profile
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
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        UserDefaults.standard.set(profile.name, forKey: "userName")
        UserDefaults.standard.set(profile.username, forKey: "userUsername")
        
        // Save Google Sign-In state and email if available
        UserDefaults.standard.set(profile.isGoogleSignIn, forKey: "isGoogleSignIn")
        if !profile.email.isEmpty {
            UserDefaults.standard.set(profile.email, forKey: "userEmail")
        }
    }
}

// Placeholder extension for View to support placeholder text
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

// MARK: - Supporting Models
struct InterestCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let subcategories: [String]
}

// Add any other supporting view structures that were in the original file 