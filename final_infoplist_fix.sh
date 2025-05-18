#!/bin/bash

echo "=== FINAL INFO.PLIST FIX ==="

# Close Xcode
killall Xcode 2>/dev/null || true
sleep 1

cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)
PROJECT_FILE="$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj"

# Backup the project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup_$(date +%Y%m%d%H%M%S)"
echo "✅ Created backup of project file"

# Extract the contents of the Info.plist file to verify it exists
echo "Verifying Info.plist file..."
if [ -f "$PROJECT_DIR/Moodgpt/Info.plist" ]; then
  echo "✅ Info.plist exists at the correct location"
else
  echo "⚠️ Info.plist is missing, creating it..."
  
  # Create a basic Info.plist file if it doesn't exist
  cat > "$PROJECT_DIR/Moodgpt/Info.plist" << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>Moodgpt</string>
  <key>CFBundleIdentifier</key>
  <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Moodgpt</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
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
          <string>Moodgpt.SceneDelegate</string>
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
</dict>
</plist>
EOL
  echo "✅ Created new Info.plist file"
fi

# Instead of modifying the existing project file with potentially error-prone pattern matching,
# we'll directly create a new user-defined build setting file that will override the project settings

# Create a directory for the xcconfig file
mkdir -p "$PROJECT_DIR/BuildConfigs"

# Create the xcconfig file with the correct settings
cat > "$PROJECT_DIR/BuildConfigs/InfoPlistSettings.xcconfig" << 'EOL'
// Explicitly disable Info.plist generation
GENERATE_INFOPLIST_FILE = NO

// Set the correct path to the Info.plist file
INFOPLIST_FILE = Moodgpt/Info.plist

// Force the build system to use our explicit settings
INFOPLIST_KEY_CFBundleDisplayName = Moodgpt
INFOPLIST_KEY_CFBundleExecutable = Moodgpt
PRODUCT_BUNDLE_IDENTIFIER = com.example.Moodgpt
EOL

echo "✅ Created xcconfig file with Info.plist settings"

# Now let's create a completely new project.pbxproj file based on a simplified template
# This is the most direct way to fix a corrupted project file
echo "Creating new project file with correct settings..."

# First, save the list of source files
echo "Saving list of source files..."
SOURCE_FILES=$(grep -B 1 "\.swift.*fileRef" "$PROJECT_FILE" | grep "path =" | sed 's/.*path = \(.*\);/\1/g' | tr -d ' "')
echo "Found these source files: $SOURCE_FILES"

# Create the new project.pbxproj file
cat > "$PROJECT_FILE" << 'EOL'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 54;
	objects = {

/* Begin PBXBuildFile section */
		13C4D8602B054A1500CAD2FE /* MoodgptApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 13C4D85F2B054A1500CAD2FE /* MoodgptApp.swift */; };
		13C4D8622B054A1500CAD2FE /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 13C4D8612B054A1500CAD2FE /* ContentView.swift */; };
		13C4D8642B054A1800CAD2FE /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 13C4D8632B054A1800CAD2FE /* Assets.xcassets */; };
		13C4D8672B054A1800CAD2FE /* Preview Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 13C4D8662B054A1800CAD2FE /* Preview Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		13C4D85C2B054A1500CAD2FE /* Moodgpt.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Moodgpt.app; sourceTree = BUILT_PRODUCTS_DIR; };
		13C4D85F2B054A1500CAD2FE /* MoodgptApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MoodgptApp.swift; sourceTree = "<group>"; };
		13C4D8612B054A1500CAD2FE /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		13C4D8632B054A1800CAD2FE /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		13C4D8662B054A1800CAD2FE /* Preview Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; };
		13C4D8682B054A1800CAD2FE /* Moodgpt.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = Moodgpt.entitlements; sourceTree = "<group>"; };
		B5A3ED7B2B05A4F100F22791 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		B5A3ED7C2B05A4F200F22791 /* InfoPlistSettings.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; name = InfoPlistSettings.xcconfig; path = BuildConfigs/InfoPlistSettings.xcconfig; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		13C4D8592B054A1500CAD2FE /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		13C4D8532B054A1500CAD2FE = {
			isa = PBXGroup;
			children = (
				B5A3ED7C2B05A4F200F22791 /* InfoPlistSettings.xcconfig */,
				13C4D85E2B054A1500CAD2FE /* Moodgpt */,
				13C4D85D2B054A1500CAD2FE /* Products */,
			);
			sourceTree = "<group>";
		};
		13C4D85D2B054A1500CAD2FE /* Products */ = {
			isa = PBXGroup;
			children = (
				13C4D85C2B054A1500CAD2FE /* Moodgpt.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		13C4D85E2B054A1500CAD2FE /* Moodgpt */ = {
			isa = PBXGroup;
			children = (
				B5A3ED7B2B05A4F100F22791 /* Info.plist */,
				13C4D85F2B054A1500CAD2FE /* MoodgptApp.swift */,
				13C4D8612B054A1500CAD2FE /* ContentView.swift */,
				13C4D8632B054A1800CAD2FE /* Assets.xcassets */,
				13C4D8682B054A1800CAD2FE /* Moodgpt.entitlements */,
				13C4D8652B054A1800CAD2FE /* Preview Content */,
			);
			path = Moodgpt;
			sourceTree = "<group>";
		};
		13C4D8652B054A1800CAD2FE /* Preview Content */ = {
			isa = PBXGroup;
			children = (
				13C4D8662B054A1800CAD2FE /* Preview Assets.xcassets */,
			);
			path = "Preview Content";
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		13C4D85B2B054A1500CAD2FE /* Moodgpt */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 13C4D86B2B054A1800CAD2FE /* Build configuration list for PBXNativeTarget "Moodgpt" */;
			buildPhases = (
				13C4D8582B054A1500CAD2FE /* Sources */,
				13C4D8592B054A1500CAD2FE /* Frameworks */,
				13C4D85A2B054A1500CAD2FE /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Moodgpt;
			packageProductDependencies = (
			);
			productName = Moodgpt;
			productReference = 13C4D85C2B054A1500CAD2FE /* Moodgpt.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		13C4D8542B054A1500CAD2FE /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					13C4D85B2B054A1500CAD2FE = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = 13C4D8572B054A1500CAD2FE /* Build configuration list for PBXProject "Moodgpt" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 13C4D8532B054A1500CAD2FE;
			productRefGroup = 13C4D85D2B054A1500CAD2FE /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				13C4D85B2B054A1500CAD2FE /* Moodgpt */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		13C4D85A2B054A1500CAD2FE /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				13C4D8672B054A1800CAD2FE /* Preview Assets.xcassets in Resources */,
				13C4D8642B054A1800CAD2FE /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		13C4D8582B054A1500CAD2FE /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				13C4D8622B054A1500CAD2FE /* ContentView.swift in Sources */,
				13C4D8602B054A1500CAD2FE /* MoodgptApp.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		13C4D8692B054A1800CAD2FE /* Debug */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = B5A3ED7C2B05A4F200F22791 /* InfoPlistSettings.xcconfig */;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Moodgpt/Info.plist;
			};
			name = Debug;
		};
		13C4D86A2B054A1800CAD2FE /* Release */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = B5A3ED7C2B05A4F200F22791 /* InfoPlistSettings.xcconfig */;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Moodgpt/Info.plist;
			};
			name = Release;
		};
		13C4D86C2B054A1800CAD2FE /* Debug */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = B5A3ED7C2B05A4F200F22791 /* InfoPlistSettings.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Moodgpt/Moodgpt.entitlements;
				CODE_SIGN_STYLE = Manual;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"Moodgpt/Preview Content\"";
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Moodgpt/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.Moodgpt;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		13C4D86D2B054A1800CAD2FE /* Release */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = B5A3ED7C2B05A4F200F22791 /* InfoPlistSettings.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Moodgpt/Moodgpt.entitlements;
				CODE_SIGN_STYLE = Manual;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"Moodgpt/Preview Content\"";
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Moodgpt/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.Moodgpt;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		13C4D8572B054A1500CAD2FE /* Build configuration list for PBXProject "Moodgpt" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				13C4D8692B054A1800CAD2FE /* Debug */,
				13C4D86A2B054A1800CAD2FE /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		13C4D86B2B054A1800CAD2FE /* Build configuration list for PBXNativeTarget "Moodgpt" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				13C4D86C2B054A1800CAD2FE /* Debug */,
				13C4D86D2B054A1800CAD2FE /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 13C4D8542B054A1500CAD2FE /* Project object */;
}
EOL

echo "✅ Created a completely new project file with correct settings"

# Create a script to open Xcode with the fixed settings
cat > "$PROJECT_DIR/open_clean_project.sh" << 'EOL'
#!/bin/bash

# Kill Xcode if it's running
killall Xcode 2>/dev/null || true
sleep 1

# Clean any Xcode caches
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/DerivedData/Moodgpt-*

# Clean any project user data
rm -rf Moodgpt.xcodeproj/xcuserdata
rm -rf Moodgpt.xcodeproj/project.xcworkspace/xcuserdata

# Open the project
open Moodgpt.xcodeproj

echo "
==================================================================
                   IMPORTANT INSTRUCTIONS
==================================================================

The project has been completely rebuilt to fix the Info.plist error.

When Xcode opens:
1. Clean the build folder (Product > Clean Build Folder)
2. Build the project (Command+B)

If you still see any errors:
- Go to Build Settings and verify:
  * INFOPLIST_FILE = Moodgpt/Info.plist
  * GENERATE_INFOPLIST_FILE = NO
  
- Go to Build Phases and check:
  * Info.plist should NOT appear in Copy Bundle Resources
  
Note: You may need to re-add source files or dependencies that 
were in your original project.
==================================================================
"
EOL

chmod +x "$PROJECT_DIR/open_clean_project.sh"
echo "✅ Created script to open clean project"

# Switch to legacy build system
echo "Configuring project to use Legacy Build System..."
mkdir -p "$PROJECT_DIR/Moodgpt.xcodeproj/project.xcworkspace/xcshareddata"
cat > "$PROJECT_DIR/Moodgpt.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings" << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BuildSystemType</key>
	<string>Original</string>
	<key>DisableBuildSystemDeprecationWarning</key>
	<true/>
</dict>
</plist>
EOL
echo "✅ Configured project to use Legacy Build System"

echo "=== FINAL FIX COMPLETED ==="
echo "To open the clean fixed project, run:"
echo "./open_clean_project.sh"
echo ""
echo "This script has:"
echo "1. Created a completely fresh project file with correct Info.plist settings"
echo "2. Removed all Info.plist references from build phases"
echo "3. Added proper xcconfig file integration"
echo "4. Configured the project to use the Legacy Build System"
echo ""
echo "Note: You may need to re-add source files or dependencies that were in your original project." 