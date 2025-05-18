import Foundation
import SwiftUI
import GoogleSignIn

class GoogleAuthService: ObservableObject {
    static let shared = GoogleAuthService()
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: GIDGoogleUser?
    @Published var error: Error?
    @Published var isLoading: Bool = false
    
    init() {
        // Check if user was previously signed in
        restorePreviousSignIn()
    }
    
    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            DispatchQueue.main.async {
                if let user = user {
                    self?.isSignedIn = true
                    self?.currentUser = user
                    
                    // Save the Google user profile to the app's UserProfile
                    self?.updateUserProfile(from: user)
                } else if let error = error {
                    self?.error = error
                    self?.isSignedIn = false
                } else {
                    self?.isSignedIn = false
                }
            }
        }
    }
    
    func signIn(presentingViewController: UIViewController? = nil, completion: @escaping (Bool) -> Void) {
        guard let presentingViewController = presentingViewController ?? UIApplication.shared.windows.first?.rootViewController else {
            completion(false)
            return
        }
        
        isLoading = true
        
        // Configure the sign-in process
        let signInConfig = GIDConfiguration(clientID: "YOUR_CLIENT_ID") // Replace with your actual client ID
        
        GIDSignIn.sharedInstance.signIn(
            with: signInConfig,
            presenting: presentingViewController
        ) { [weak self] user, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let user = user {
                    self?.isSignedIn = true
                    self?.currentUser = user
                    self?.updateUserProfile(from: user)
                    completion(true)
                } else {
                    self?.error = error
                    self?.isSignedIn = false
                    completion(false)
                }
            }
        }
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        GIDSignIn.sharedInstance.signOut()
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isSignedIn = false
            self?.currentUser = nil
            
            // Clear Google-specific data from UserProfile
            self?.clearUserProfile()
            
            completion(true)
        }
    }
    
    private func updateUserProfile(from googleUser: GIDGoogleUser) {
        // Get user profile information
        if let name = googleUser.profile?.name,
           let email = googleUser.profile?.email {
            
            // Update UserDefaults with Google profile info
            UserDefaults.standard.set(name, forKey: "userName")
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set(true, forKey: "isGoogleSignIn")
            
            // If there's a profile picture URL, you can handle it here
            if let profilePictureURL = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString {
                UserDefaults.standard.set(profilePictureURL, forKey: "userProfilePictureURL")
            }
        }
    }
    
    private func clearUserProfile() {
        // Don't clear the userName as it might have been set manually
        UserDefaults.standard.set(false, forKey: "isGoogleSignIn")
    }
}

// MARK: - Google Sign In Button
struct GoogleSignInButton: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    var action: () -> Void
    
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.style = colorScheme == .dark ? .wide : .standard
        button.colorScheme = colorScheme == .dark ? .dark : .light
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
        uiView.colorScheme = colorScheme == .dark ? .dark : .light
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        var action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
    }
}

// Custom Google Sign In Button that matches the app's visual style
struct CustomGoogleSignInButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
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