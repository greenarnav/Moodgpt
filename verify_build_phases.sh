#!/bin/bash

echo "===== VERIFYING PROJECT BUILD PHASES ====="
cd "$(dirname "$0")"
PROJECT_FILE="Moodgpt.xcodeproj/project.pbxproj"

echo "Checking for all occurrences of Info.plist in the project file..."
grep -n "Info.plist" "$PROJECT_FILE"

echo ""
echo "Here are the build phases in your project:"
grep -A 2 "buildPhases = (" "$PROJECT_FILE"

echo ""
echo "===== MANUAL STEPS TO COMPLETE IN XCODE ====="
echo "1. Open Xcode and select the Moodgpt project"
echo "2. Select the Moodgpt target"
echo "3. Go to Build Phases tab"
echo "4. Expand 'Copy Bundle Resources'"
echo "5. If Info.plist is still there, remove it by selecting it and clicking the - button"
echo "6. Go to Build Settings tab"
echo "7. Make sure 'Info.plist File' is set to 'Moodgpt/Info.plist'"
echo "8. Make sure 'Generate Info.plist File' is set to 'NO'"
echo "9. Clean the build folder (Product > Clean Build Folder)"
echo "10. Build the project (Command+B)"
echo ""
echo "If the error persists:"
echo "- Try using the Legacy Build System (File > Project Settings > Build System)"
echo "- If using CocoaPods or SPM, make sure they don't add a duplicate Info.plist"
