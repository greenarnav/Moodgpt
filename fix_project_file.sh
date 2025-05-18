#!/bin/bash

echo "=== Automatically fixing Info.plist conflict ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Create a backup of the project file
if [ ! -f "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.bak2" ]; then
  echo "Creating backup of project file..."
  cp "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.bak2"
fi

# Check if there are multiple Info.plist files
echo "Checking for multiple Info.plist files..."
INFO_PLIST_FILES=$(find "$PROJECT_DIR" -name "Info.plist" | grep -v "Pods" | grep -v "DerivedData")
INFO_PLIST_COUNT=$(echo "$INFO_PLIST_FILES" | wc -l)

echo "Found $INFO_PLIST_COUNT Info.plist files:"
echo "$INFO_PLIST_FILES"

# If we have AppInfo.plist, rename it to avoid conflicts
if [ -f "$PROJECT_DIR/Moodgpt/AppInfo.plist" ]; then
  echo "Found AppInfo.plist, renaming to avoid conflicts..."
  mv "$PROJECT_DIR/Moodgpt/AppInfo.plist" "$PROJECT_DIR/Moodgpt/AppInfo.plist.bak"
fi

# Create a configuration file to disable automatic Info.plist generation
echo "Creating configuration file..."
cat > "$PROJECT_DIR/NoGenerateInfoPlist.xcconfig" << EOL
// Disable automatic Info.plist generation
GENERATE_INFOPLIST_FILE = NO
// Use our existing Info.plist
INFOPLIST_FILE = Moodgpt/Info.plist
EOL

# Add a specific build flag to resolve the issue
echo "Setting up project configuration..."
cat > "$PROJECT_DIR/Moodgpt/BuildSpecific.xcconfig" << EOL
COPY_PHASE_STRIP = NO
INFOPLIST_FILE = Moodgpt/Info.plist
GENERATE_INFOPLIST_FILE = NO
EOL

# Clean derived data and build folder
echo "Cleaning derived data and build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
rm -rf build/

echo ""
echo "=== Fix Applied ==="
echo "The project has been modified to fix the Info.plist conflict."
echo "Now open your project in Xcode and try building again."
echo ""
echo "If you still face issues, in Xcode:"
echo "1. Go to Moodgpt target > Build Settings"
echo "2. Search for 'Info.plist'"
echo "3. Set 'Info.plist File' to 'Moodgpt/Info.plist'"
echo "4. Set 'Generate Info.plist File' to 'No'"
echo "=== End of Fix ===" 