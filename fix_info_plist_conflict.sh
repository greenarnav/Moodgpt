#!/bin/bash

echo "=== Fixing Info.plist conflict ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Create a backup of the project file
if [ ! -f "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.bak" ]; then
  echo "Creating backup of project file..."
  cp "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.bak"
fi

# Create a configuration file to disable automatic Info.plist generation
echo "Creating configuration file..."
cat > "$PROJECT_DIR/NoGenerateInfoPlist.xcconfig" << EOL
// Disable automatic Info.plist generation
GENERATE_INFOPLIST_FILE = NO
// Use our existing Info.plist
INFOPLIST_FILE = Moodgpt/Info.plist
EOL

# Clean derived data
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

echo "=== Solution Steps ==="
echo "1. Open Xcode by clicking on Moodgpt.xcodeproj"
echo "2. Go to Project Settings > Build Settings"
echo "3. Look for 'Info.plist File' setting"
echo "4. Make sure it's set to 'Moodgpt/Info.plist' and nothing else"
echo "5. Look for 'Generate Info.plist File' and set to NO"
echo "6. Alternatively, select the project in Xcode"
echo "7. Go to Info tab and click '+' to add a configuration file"
echo "8. Add the created NoGenerateInfoPlist.xcconfig file"
echo ""
echo "This should fix the 'Multiple commands produce Info.plist' error."
echo "=== End of Fix ===" 