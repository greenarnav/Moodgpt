# Google Sign-In Installation Instructions

## Overview
This guide will help you add Google Sign-In to your MoodGPT app to fix the "No such module 'GoogleSignIn'" error.

## Option 1: Using Swift Package Manager (Recommended)

1. Open your project in Xcode
2. Go to File > Add Packages...
3. In the search bar, paste the following URL:
   ```
   https://github.com/google/GoogleSignIn-iOS
   ```
4. Select the "GoogleSignIn-iOS" package
5. Choose "Up to Next Major Version" and ensure it's set to version 7.0.0 or later
6. Click "Add Package"
7. When prompted to select packages, make sure both "GoogleSignIn" and "GoogleSignInSwift" are selected
8. Click "Add Package" to complete the installation

## Option 2: Using CocoaPods

If you prefer CocoaPods:

1. Make sure you have CocoaPods installed on your system
2. Create or open your Podfile in the project root directory
3. Add the following lines to your Podfile:
   ```ruby
   pod 'GoogleSignIn', '~> 7.0.0'
   ```
4. Save the Podfile
5. Run `pod install` in the terminal from your project directory
6. Open the .xcworkspace file that CocoaPods created

## Configuring your App

After adding the package, you need to configure your app:

1. Make sure your Info.plist contains the necessary configuration for Google Sign-In:
   - Your app's bundle ID matches what you set up in the Google Cloud Console
   - The URL schemes for your reversed client ID are configured

2. Create a GoogleService-Info.plist file through the Google Cloud Console if you don't have one already

3. Set up your AppDelegate or SceneDelegate to handle the authentication callback by adding:
   ```swift
   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
       return GIDSignIn.sharedInstance.handle(url)
   }
   ```

## Test the Integration

Once you've completed these steps, build and run your app. The "No such module 'GoogleSignIn'" error should be resolved.

## Help and Support

If you encounter any issues, refer to the official documentation:
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios/start-integrating) 