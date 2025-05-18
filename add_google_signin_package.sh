#!/bin/bash

# Step 1: Ensure Info.plist exists
echo "Ensuring Info.plist exists..."
if [ ! -f "/Users/test/Desktop/newnew/Moodgpt/Moodgpt/Info.plist" ]; then
  if [ -f "/Users/test/Desktop/newnew/Moodgpt/TempFiles/InfoPlists/GoogleInfo.plist" ]; then
    cp "/Users/test/Desktop/newnew/Moodgpt/TempFiles/InfoPlists/GoogleInfo.plist" "/Users/test/Desktop/newnew/Moodgpt/Moodgpt/Info.plist"
  else
    echo "Error: Cannot find Info.plist in backup location. Please manually add Info.plist."
    exit 1
  fi
fi

# Step 2: Create a SwiftPM compatible Package.swift file
echo "Creating Package.swift file for Google Sign-In..."
cat > "/Users/test/Desktop/newnew/Moodgpt/GoogleSignInPackage.swift" << EOF
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GoogleSignIn",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "GoogleSignIn", targets: ["GoogleSignInTarget"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GoogleSignInTarget",
            dependencies: [],
            path: "Sources"
        )
    ]
)
EOF

# Step 3: Create instructions for manual addition of the package
echo "Creating instruction file for adding Google Sign-In package..."
cat > "/Users/test/Desktop/newnew/Moodgpt/GoogleSignInInstallation.md" << EOF
# Adding Google Sign-In to Your Project

## Option 1: Using Swift Package Manager (Recommended)

1. Open your project in Xcode
2. Go to File > Add Packages...
3. In the search bar, paste: \`https://github.com/google/GoogleSignIn-iOS\`
4. Select the latest version (or specify a version constraint)
5. Click "Add Package"
6. Select both "GoogleSignIn" and "GoogleSignInSwift" libraries 
7. Click "Add Package" to complete installation

## Option 2: Using CocoaPods

1. If you prefer CocoaPods, add these lines to your Podfile:
   \`\`\`ruby
   pod 'GoogleSignIn', '~> 7.0'
   \`\`\`
2. Run \`pod install\` in your terminal
3. Open the .xcworkspace file instead of the .xcodeproj file

## Post-Installation

1. Make sure your Info.plist has the GoogleSignIn URL scheme:
   \`\`\`xml
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
   \`\`\`

2. Update the GoogleAuthService.swift file with your actual client ID.

## Testing Installation

After adding the package, test the installation by building the project.
EOF

echo "=========================================================="
echo "To fix the 'No such module GoogleSignIn' error, please:"
echo "1. Open your project in Xcode"
echo "2. Follow the instructions in GoogleSignInInstallation.md"
echo "   to add the Google Sign-In package to your project"
echo "3. Build the project to verify the fix worked"
echo "==========================================================" 