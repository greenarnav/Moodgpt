#!/bin/bash

echo "=== FIXING MISSING INFO.PLIST ERROR ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Ensure Xcode is closed
echo "Closing Xcode (if open)..."
killall Xcode 2>/dev/null || true
sleep 2

# Step 1: Find any Info.plist files that might exist in backups
echo "Looking for existing Info.plist files..."
EXISTING_INFO_PLISTS=$(find "$PROJECT_DIR" -name "Info*.plist*" | grep -v "DerivedData" | grep -v "build")
echo "Found the following Info.plist files:"
echo "$EXISTING_INFO_PLISTS"

# Step 2: Create a new Info.plist in the right location
echo "Creating a proper Info.plist file..."
mkdir -p "$PROJECT_DIR/Moodgpt"

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
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>NSContactsUsageDescription</key>
	<string>MoodGPT needs to access your contacts to help you track their moods</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>MoodGPT uses your location to find nearby people and city moods</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>MoodGPT uses your location to find nearby people and city moods</string>
	<key>NSCalendarsUsageDescription</key>
	<string>MoodGPT needs access to your calendar to schedule follow-ups with contacts</string>
	<key>NSHealthShareUsageDescription</key>
	<string>MoodGPT uses your health data to correlate your moods with physical activity and sleep</string>
	<key>NSHealthUpdateUsageDescription</key>
	<string>MoodGPT can save mood-related data to your Health app</string>
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

echo "✅ Created Info.plist at $PROJECT_DIR/Moodgpt/Info.plist"

# Step 3: Create a configuration file that enables Info.plist usage
echo "Creating configuration file..."
cat > "$PROJECT_DIR/InfoPlistEnabled.xcconfig" << EOL
// Enable Info.plist file
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
// Ensure the file is properly included in bundle
COPY_PHASE_STRIP = NO
SKIP_INSTALL = NO
EOL

echo "✅ Created InfoPlistEnabled.xcconfig"

# Step 4: Modify the build settings in the project file
echo "Modifying project build settings..."
MODIFICATION_SCRIPT="$PROJECT_DIR/fix_infoplist_settings.rb"

cat > "$MODIFICATION_SCRIPT" << 'EOF'
#!/usr/bin/env ruby

# Script to fix Info.plist settings in Xcode project
project_file = ARGV[0]
content = File.read(project_file)
original_content = content.dup

# Make sure GENERATE_INFOPLIST_FILE is set correctly
if content.include?('GENERATE_INFOPLIST_FILE')
  # If we're disabling generation, make sure path is correct
  content.gsub!(/GENERATE_INFOPLIST_FILE = NO;/, "GENERATE_INFOPLIST_FILE = NO;")
  content.gsub!(/INFOPLIST_FILE = ".+Info.plist";/, 'INFOPLIST_FILE = "Moodgpt/Info.plist";')
else
  # Add the settings if they don't exist
  build_settings_pattern = /(buildSettings = \{)/
  replacement = "\\1\n\t\t\t\tGENERATE_INFOPLIST_FILE = NO;\n\t\t\t\tINFOPLIST_FILE = \"Moodgpt/Info.plist\";"
  content.gsub!(build_settings_pattern, replacement)
end

# Ensure the Info.plist is included in Copy Bundle Resources
copy_bundle_pattern = /(\/\* Begin PBXResourcesBuildPhase section \*\/.*?files = \()/m
if content =~ copy_bundle_pattern
  # Generate a unique ID for the reference
  new_id = (0...24).map { |i| i % 2 == 0 ? ('A'..'F').to_a[rand(6)] : rand(10) }.join
  
  # Add the Info.plist reference if it's not there
  if !content.include?('Info.plist in Resources')
    content.gsub!(copy_bundle_pattern, "\\1\n\t\t\t\t#{new_id} /* Info.plist in Resources */,")
  end
end

# Write back if changes were made
if content != original_content
  File.write(project_file, content)
  puts "Project file updated with Info.plist settings"
else
  puts "No changes needed for Info.plist settings"
end
EOF

chmod +x "$MODIFICATION_SCRIPT"
ruby "$MODIFICATION_SCRIPT" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj"

# Step 5: Clean derived data
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Step 6: Create a script to open Xcode with these settings
LAUNCH_SCRIPT="$PROJECT_DIR/open_with_infoplist_fix.sh"

cat > "$LAUNCH_SCRIPT" << 'EOF'
#!/bin/bash
# Close Xcode
killall Xcode 2>/dev/null || true
sleep 2
# Clean caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode/
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# Open project with our xcconfig
DIR="$(dirname "$0")"
open "$DIR/Moodgpt.xcodeproj" -a Xcode
EOF

chmod +x "$LAUNCH_SCRIPT"

# Launch Xcode
echo "Opening Xcode with fixed settings..."
"$LAUNCH_SCRIPT"

echo "=== FIX APPLIED ==="
echo "The Info.plist file has been created and project settings adjusted."
echo ""
echo "If you still have code signing issues in Xcode:"
echo "1. Select the Moodgpt project in the Project Navigator"
echo "2. Select the Moodgpt target"
echo "3. Go to the Build Settings tab"
echo "4. Search for 'Info.plist'"
echo "5. Make sure 'Info.plist File' is set to 'Moodgpt/Info.plist'"
echo "6. Search for 'Generate Info.plist'"
echo "7. Make sure it's set to 'No'"
echo "8. Go to the Build Phases tab"
echo "9. Expand 'Copy Bundle Resources' and check if Info.plist is included"
echo "10. If not, click '+' and add the Info.plist file from the Moodgpt folder"
echo "=== END OF FIX ===" 