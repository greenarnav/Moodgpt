# Implementing Google Sign-In After CocoaPods Installation

After running `pod install` and opening the `.xcworkspace` file, follow these steps to implement Google Sign-In in your app:

## 1. Update GoogleAuthService.swift

Replace the placeholder implementation with this real implementation:

```swift
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
```

## 2. Update OnboardingView.swift

1. Uncomment the GoogleSignIn import:
```swift
import GoogleSignIn
```

2. Uncomment the GoogleAuthService:
```swift
@StateObject private var googleAuthService = GoogleAuthService.shared
```

3. Uncomment the loading indicator:
```swift
if googleAuthService.isLoading {
    ProgressView()
        .scaleEffect(1.5)
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .edgesIgnoringSafeArea(.all)
}
```

4. Uncomment the onReceive block:
```swift
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
```

5. Update the handleGoogleSignIn method by uncommenting the implementation:
```swift
func handleGoogleSignIn() {
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
}
```

6. Uncomment the email section in finalizeProfile:
```swift
// If user signed in with Google, get their email
if isGoogleSignIn, let email = googleAuthService.currentUser?.profile?.email {
    profile.email = email
}
```

## 3. Update Info.plist with Google Sign-In Configuration

Ensure your Info.plist includes:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Replace `YOUR_CLIENT_ID` with your actual Google client ID.

## 4. Handle Authentication in AppDelegate or SceneDelegate

Add the following method to handle sign-in callbacks:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
}
``` 