#!/bin/bash

echo "=== Fixing Duplicate Build Phases ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Backup the project file
echo "Creating backup of project file..."
cp "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.fixphases"

# Create a special configuration file that prevents Info.plist copy phases
echo "Creating configuration file..."
cat > "$PROJECT_DIR/PreventCopyPhases.xcconfig" << EOL
// Disable Info.plist generation
GENERATE_INFOPLIST_FILE = NO
// Use our existing Info.plist
INFOPLIST_FILE = Moodgpt/Info.plist
// Prevent copy phases for resources
SKIP_INSTALL = YES
// Optimization
COPY_PHASE_STRIP = NO
EOL

# Remove package-related caches completely
echo "Removing package caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf "$PROJECT_DIR/Moodgpt.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/"
rm -rf "$PROJECT_DIR/Moodgpt.xcodeproj/xcuserdata/"
rm -rf "$PROJECT_DIR/SourcePackages/"

# Clean derived data completely
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Create a direct launch script for Xcode with clean slate
echo "Creating clean launch script..."
cat > "$PROJECT_DIR/open_clean_project.sh" << EOL
#!/bin/bash
# Kill any running Xcode instances
killall Xcode || true
# Wait a moment
sleep 2
# Clear caches
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
# Launch Xcode with project
open "$PROJECT_DIR/Moodgpt.xcodeproj" -a Xcode
EOL

# Make it executable
chmod +x "$PROJECT_DIR/open_clean_project.sh"

echo "=== Instructions ==="
echo "To fix the issue:"
echo "1. Close Xcode completely if it's open"
echo "2. Run ./open_clean_project.sh to open a clean project"
echo "3. When Xcode opens, go to Product > Clean Build Folder"
echo "4. Go to File > Swift Packages > Reset Package Caches"
echo "5. Select the Moodgpt project in the navigator"
echo "6. Go to the Build Settings tab"
echo "7. Search for 'Info.plist' and ensure 'Generate Info.plist File' is set to NO"
echo "8. Search for 'Copy Files' or 'Copy Bundle Resources' in the Build Phases tab"
echo "9. If there are duplicate Info.plist entries, remove all but one"
echo ""
echo "Alternatively:"
echo "1. Consider removing GoogleSignIn package completely"
echo "2. Clean the project"
echo "3. Then add it back using File > Add Packages"
echo "=== End of Fix ===" 