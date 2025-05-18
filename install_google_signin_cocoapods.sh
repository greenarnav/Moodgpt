#!/bin/bash

# Script to install Google Sign-In using CocoaPods
echo "================================================"
echo "  Installing Google Sign-In using CocoaPods  "
echo "================================================"

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "CocoaPods not found. Installing CocoaPods..."
    sudo gem install cocoapods
else
    echo "CocoaPods is already installed"
fi

# Move to project directory
cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"
echo "Project directory: $PROJECT_DIR"

# Clean derived data
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
echo "✓ Derived data cleaned"

# Create backup of project if needed
if [ ! -f "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.backup" ]; then
    echo "Creating backup of Xcode project..."
    cp "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.backup"
    echo "✓ Project backup created"
fi

# Install pods
echo "Installing pods..."
pod install

# Check if pod install was successful
if [ $? -eq 0 ]; then
    echo "✓ Pods installed successfully"
    
    # Modify GoogleAuthService to use the real implementation after installation
    echo "To enable GoogleSignIn in your code:"
    echo "1. Open Moodgpt.xcworkspace (NOT Moodgpt.xcodeproj)"
    echo "2. Uncomment the GoogleSignIn imports in your files"
    echo "3. Build and run the app"
    
    # Open the workspace
    echo "Opening Xcode workspace..."
    open Moodgpt.xcworkspace
else
    echo "❌ Error installing pods. Please check the error messages above."
fi

echo "================================================" 