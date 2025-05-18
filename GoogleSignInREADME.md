# Google Sign-In Integration for MoodGPT

This document provides instructions on how to complete the Google Sign-In setup for the MoodGPT application.

## Prerequisites

1. You need a Google Cloud Platform account
2. You need to create a project in the Google Cloud Console
3. Xcode and CocoaPods installed on your development machine

## Setup Steps

### 1. Create a Google Cloud Platform Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sign-In API for your project

### 2. Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Select "External" user type (unless you're using a Google Workspace account)
3. Fill in the required app information
4. Add the scopes you need (typically "email" and "profile")
5. Add test users if in testing mode

### 3. Create OAuth Client ID

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select "iOS" as the application type
4. Enter your bundle identifier (must match your Xcode project)
5. Save the Client ID for later use

### 4. Update Your Code

1. Open the `GoogleAuthService.swift` file
2. Replace `YOUR_CLIENT_ID` with the actual Client ID you obtained in step 3:

```swift
let signInConfig = GIDConfiguration(clientID: "YOUR_ACTUAL_CLIENT_ID_HERE")
```

3. Also update the same in `MoodgptApp.swift`:

```swift
private func configureGoogleSignIn() {
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "YOUR_ACTUAL_CLIENT_ID_HERE")
}
```

4. Update the `Info.plist` file to include your client ID in the URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_ACTUAL_CLIENT_ID_HERE</string>
        </array>
    </dict>
</array>
```

### 5. Install Dependencies

Make sure you have installed the GoogleSignIn SDK using Swift Package Manager:

1. In Xcode, go to File > Add Packages...
2. Enter the URL: https://github.com/google/GoogleSignIn-iOS
3. Select the version and click "Add Package"

## Testing the Integration

1. Build and run the app
2. Go to the onboarding flow and tap "Sign in with Google"
3. You should see the Google Sign-In sheet appear
4. After signing in, your Google account information should be used to pre-fill the user's name and username

## Troubleshooting

- If the Sign-In button doesn't appear, check that the GoogleSignIn SDK is properly installed
- If you get an error about the client ID, ensure you've correctly replaced all instances of "YOUR_CLIENT_ID"
- If the callback URL isn't working, verify that your URL scheme in Info.plist matches your client ID
- For network errors, check your internet connection and that your GCP project has the correct APIs enabled

## Additional Resources

- [Google Sign-In for iOS Documentation](https://developers.google.com/identity/sign-in/ios/start-integrating)
- [GIDSignIn Class Reference](https://developers.google.com/identity/sign-in/ios/reference/Classes/GIDSignIn)
- [Google Cloud Console](https://console.cloud.google.com/) 