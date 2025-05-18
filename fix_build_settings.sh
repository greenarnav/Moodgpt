#!/bin/bash

# Comprehensive fix for "Multiple commands produce Info.plist" error in Xcode
echo "=========================================================="
echo "     FIX FOR 'MULTIPLE COMMANDS PRODUCE INFO.PLIST'      "
echo "=========================================================="

cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Step 1: Back up the project file
echo "Step 1: Creating backup of project file..."
if [ ! -f "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.original" ]; then
  cp "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj.original"
  echo "✅ Project file backed up"
else
  echo "✅ Backup already exists"
fi

# Step 2: Check for multiple Info.plist files
echo "Step 2: Checking for multiple Info.plist files..."
INFO_PLIST_FILES=$(find "$PROJECT_DIR" -name "Info.plist" | grep -v "Pods" | grep -v "DerivedData")
INFO_PLIST_COUNT=$(echo "$INFO_PLIST_FILES" | wc -l | xargs)

echo "Found $INFO_PLIST_COUNT Info.plist files:"
echo "$INFO_PLIST_FILES"

# Step 3: Create a dedicated folder for Info.plist files
echo "Step 3: Creating a dedicated folder for Info.plist files..."
mkdir -p "$PROJECT_DIR/InfoPlists"

# Step 4: Move all Info.plist files to the dedicated folder with unique names
echo "Step 4: Organizing Info.plist files..."
counter=1
while read -r plist_file; do
  if [ -n "$plist_file" ]; then
    filename=$(basename "$plist_file")
    dirname=$(dirname "$plist_file")
    dirname_short=$(basename "$dirname")
    
    # Don't move the main Info.plist
    if [ "$plist_file" != "$PROJECT_DIR/Moodgpt/Info.plist" ]; then
      cp "$plist_file" "$PROJECT_DIR/InfoPlists/${dirname_short}_${filename}.bak"
      echo "Copied $plist_file to $PROJECT_DIR/InfoPlists/${dirname_short}_${filename}.bak"
      
      # If it's not the main Info.plist, rename it to avoid conflicts
      if [ "$plist_file" != "$PROJECT_DIR/Moodgpt/Info.plist" ]; then
        mv "$plist_file" "${plist_file}.bak"
        echo "Renamed $plist_file to ${plist_file}.bak"
      fi
    else
      echo "Keeping main Info.plist at $plist_file"
    fi
    
    counter=$((counter + 1))
  fi
done <<< "$INFO_PLIST_FILES"

# Step 5: Create an xcconfig file to override the build settings
echo "Step 5: Creating build configuration file..."
cat > "$PROJECT_DIR/InfoPlistFix.xcconfig" << EOL
// Fix for "Multiple commands produce Info.plist" error
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
INFOPLIST_KEY_UILaunchScreen_Generation = NO
INFOPLIST_OUTPUT_FORMAT = binary
EOL

echo "✅ Created InfoPlistFix.xcconfig"

# Step 6: Clean the build and derived data folders
echo "Step 6: Cleaning build artifacts and derived data..."
rm -rf "$PROJECT_DIR/build"
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
echo "✅ Build artifacts and derived data cleaned"

# Step 7: Create a consolidated Info.plist if needed
echo "Step 7: Ensuring Info.plist is properly set up..."
if [ ! -s "$PROJECT_DIR/Moodgpt/Info.plist" ]; then
  echo "Main Info.plist is empty or doesn't exist. Creating one..."
  
  # Create a basic Info.plist with essential keys
  cat > "$PROJECT_DIR/Moodgpt/Info.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<false/>
		<key>UISceneConfigurations</key>
		<dict>
			<key>UIWindowSceneSessionRoleApplication</key>
			<array>
				<dict>
					<key>UISceneConfigurationName</key>
					<string>Default Configuration</string>
					<key>UISceneDelegateClassName</key>
					<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
				</dict>
			</array>
		</dict>
	</dict>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
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
</dict>
</plist>
EOL
  echo "✅ Created basic Info.plist"
else
  echo "✅ Main Info.plist exists and has content"
fi

echo "=========================================================="
echo "Fix completed! To apply this fix:"
echo "1. Open Xcode project"
echo "2. Go to Project > Info tab > Configurations"
echo "3. Click on (+) under 'Debug' and select 'InfoPlistFix.xcconfig'"
echo "4. Click on (+) under 'Release' and select 'InfoPlistFix.xcconfig'"
echo "5. Build your project"
echo ""
echo "If you still face issues, manually set in Project > Build Settings:"
echo "- GENERATE_INFOPLIST_FILE = NO"
echo "- INFOPLIST_FILE = Moodgpt/Info.plist"
echo "==========================================================" 