#!/bin/bash

# Delete derived data for Moodgpt
echo "Deleting derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

# Clean the project
echo "Cleaning the project..."
xcodebuild clean -project Moodgpt.xcodeproj -scheme Moodgpt

# Find all Info.plist files in the project
echo "Finding Info.plist files..."
find . -name "Info.plist" -not -path "*/TempFiles/*" -not -path "*/Moodgpt/Info.plist"

# Update build settings
echo "Creating updated build settings..."
cat > BuildFix.xcconfig << EOF
// Fix for duplicate Info.plist issue
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
INFOPLIST_KEY_UILaunchScreen_Generation = NO
INFOPLIST_KEY_UIApplicationSceneManifest_Generation = NO
EOF

echo "Build settings updated."
echo "Ready to build with:"
echo "xcodebuild -project Moodgpt.xcodeproj -scheme Moodgpt -xcconfig BuildFix.xcconfig build" 