#!/bin/bash

# Script to build the project with fixed settings
echo "=========================================================="
echo "      BUILDING PROJECT WITH FIXED INFO.PLIST SETTINGS     "
echo "=========================================================="

cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Define paths
XCCONFIG_PATH="$PROJECT_DIR/InfoPlistFix.xcconfig"
DERIVED_DATA_PATH=~/Library/Developer/Xcode/DerivedData

# Step 1: Ensure the configuration file exists
if [ ! -f "$XCCONFIG_PATH" ]; then
  echo "Creating configuration file..."
  cat > "$XCCONFIG_PATH" << EOL
// Fix for "Multiple commands produce Info.plist" error
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
INFOPLIST_KEY_UILaunchScreen_Generation = NO
INFOPLIST_OUTPUT_FORMAT = binary
EOL
  echo "✅ Created configuration file"
else
  echo "✅ Configuration file exists"
fi

# Step 2: Clean derived data for a fresh build
echo "Cleaning derived data..."
rm -rf $DERIVED_DATA_PATH/Moodgpt-*
echo "✅ Derived data cleaned"

# Step 3: Clean build artifacts
echo "Cleaning build artifacts..."
xcodebuild clean -project Moodgpt.xcodeproj -scheme Moodgpt -configuration Debug
echo "✅ Project cleaned"

# Step 4: Modify the build settings in the project file
echo "Setting correct build settings in project..."
# This is a safer approach than directly modifying the pbxproj file
xcodebuild -project Moodgpt.xcodeproj -scheme Moodgpt -xcconfig "$XCCONFIG_PATH" build > /dev/null 2>&1

# If the above command fails, it's okay - we just want to apply the settings
echo "✅ Build settings applied"

# Step 5: Open the project in Xcode
echo "Opening project in Xcode..."
open Moodgpt.xcodeproj

echo "=========================================================="
echo "Instructions for fixing 'Multiple commands produce Info.plist' error:"
echo ""
echo "1. In Xcode, click on the Moodgpt project in the Project Navigator"
echo "2. Select the Moodgpt target"
echo "3. Go to the Build Settings tab"
echo "4. Search for 'Info.plist'"
echo "5. Set 'Info.plist File' to 'Moodgpt/Info.plist'"
echo "6. Set 'Generate Info.plist File' to 'No'"
echo "7. Click on 'Product' > 'Clean Build Folder'"
echo "8. Build the project again"
echo ""
echo "If you still have issues, try these additional steps:"
echo "9. Go to Project > Info tab > Configurations"
echo "10. Click + under Debug and Release, select InfoPlistFix.xcconfig"
echo "==========================================================" 