#!/bin/bash

# Print step information
echo "Step 1: Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

# Ensure our Info.plist is correct
echo "Step 2: Restoring original Info.plist..."
cat > /Users/test/Desktop/newnew/Moodgpt/Moodgpt/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>\$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>\$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>\$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>\$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
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
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>NSContactsUsageDescription</key>
	<string>MoodGPT needs access to your contacts to show their mood based on location.</string>
	<key>NSHealthShareUsageDescription</key>
	<string>MoodGPT accesses your health data to understand how your physical activity and health metrics relate to your mood. Your data is kept private and is only used to enhance your experience.</string>
	<key>NSHealthUpdateUsageDescription</key>
	<string>MoodGPT will update your health data with mood information to help you track your emotional well-being over time.</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>MoodGPT needs your location to show your city's mood and nearby contacts.</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>MoodGPT needs your location to show your city's mood and nearby contacts.</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>MoodGPT uses your location to show emotional patterns in your city and connect you with contacts nearby.</string>
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
					<string>\$(PRODUCT_MODULE_NAME).SceneDelegate</string>
				</dict>
			</array>
		</dict>
	</dict>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UIBackgroundModes</key>
	<array>
		<string>fetch</string>
		<string>remote-notification</string>
		<string>processing</string>
	</array>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
		<string>healthkit</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
</dict>
</plist>
EOF

# Create an Xcode config file that will be applied during building
echo "Step 3: Creating Xcode config file..."
cat > /Users/test/Desktop/newnew/Moodgpt/NoGenerateInfoPlist.xcconfig << EOF
// This prevents Xcode from generating a default Info.plist
GENERATE_INFOPLIST_FILE = NO 
INFOPLIST_FILE = Moodgpt/Info.plist
EOF

# Remove any Package.swift file
echo "Step 4: Removing package files..."
rm -f /Users/test/Desktop/newnew/Moodgpt/Package.swift

# Remove Moodgpt.app from the Products directory if it exists
echo "Step 5: Cleaning build products..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*/Build/Products/Debug-iphonesimulator/Moodgpt.app

# Attempt to build the project with new settings
echo "Step 6: Building project..."
cd /Users/test/Desktop/newnew/Moodgpt 
xcodebuild clean -project Moodgpt.xcodeproj -scheme Moodgpt -sdk iphonesimulator

echo "Done! Now try opening the project in Xcode and building it manually." 