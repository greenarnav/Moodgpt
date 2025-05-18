#!/bin/bash

# Script to fix Google Sign-In integration for MoodGPT app
echo "================================================"
echo "      MoodGPT Google Sign-In Integration Fix    "
echo "================================================"

# Move to project directory
cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"
echo "Project directory: $PROJECT_DIR"

# Check if we need to create a temporary fix for OnboardingView
if [ -f "$PROJECT_DIR/Moodgpt/Views/Onboarding/OnboardingView.swift" ]; then
  echo "Creating temporary version of OnboardingView without GoogleSignIn import..."
  cp "$PROJECT_DIR/Views/Onboarding/OnboardingViewTempFix.swift" "$PROJECT_DIR/Moodgpt/Views/Onboarding/OnboardingView.swift"
  echo "✓ Temporary OnboardingView created"
fi

# Clean the build folder to remove any cached files
echo "Cleaning build folder..."
xcodebuild clean -project Moodgpt.xcodeproj -scheme Moodgpt > /dev/null 2>&1
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
echo "✓ Build folder cleaned"

# Create a Swift Package for Google Sign-In
echo "Creating Package.swift for Google Sign-In..."
cat > Package.swift << 'EOF'
// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "MoodGPTDependencies",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MoodGPTDependencies",
            targets: ["MoodGPTDependenciesTarget"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git",
            from: "7.0.0"
        ),
    ],
    targets: [
        .target(
            name: "MoodGPTDependenciesTarget",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ],
            path: "Sources"
        ),
    ]
)
EOF

# Make sure the Sources directory exists
mkdir -p Sources
echo "// Placeholder" > Sources/Placeholder.swift

echo "✓ Package.swift created"

# Open installation instructions
echo "Opening installation instructions..."
open GoogleSignInInstallation.md

# Provide next steps
echo ""
echo "Next steps:"
echo "1. Open your Xcode project with: open Moodgpt.xcodeproj"
echo "2. Follow the instructions in GoogleSignInInstallation.md to add Google Sign-In SDK"
echo "3. After the package is installed, uncomment the GoogleSignIn imports and related code"
echo "4. Build and run your app"
echo ""
echo "For questions or issues, refer to the installation guide."
echo "================================================" 