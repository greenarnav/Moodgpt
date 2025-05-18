#!/bin/bash

echo "=== RECOVERING CORRUPTED PROJECT FILE ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)
PROJECT_FILE="$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj"

# Check for backups
echo "Checking for backup files..."
BACKUPS=$(find "$PROJECT_DIR/Moodgpt.xcodeproj" -name "project.pbxproj.*" | sort -r)

if [ -n "$BACKUPS" ]; then
    echo "Found these backup files:"
    echo "$BACKUPS"
    
    # Use the first (most recent) backup
    LATEST_BACKUP=$(echo "$BACKUPS" | head -n 1)
    echo "Restoring from: $LATEST_BACKUP"
    cp "$LATEST_BACKUP" "$PROJECT_FILE"
    echo "✅ Project file restored from backup"
else
    echo "No backup files found. Attempting to create a new project file..."
    
    # Download a template project.pbxproj file and customize it
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
		B5A3ED7C2B05A4F100F22791 /* Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = B5A3ED7B2B05A4F100F22791 /* Info.plist */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		13C4D85C2B054A1500CAD2FE /* Moodgpt.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Moodgpt.app; sourceTree = BUILT_PRODUCTS_DIR; };
		13C4D85F2B054A1500CAD2FE /* MoodgptApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MoodgptApp.swift; sourceTree = "<group>"; };
		13C4D8612B054A1500CAD2FE /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		13C4D8632B054A1800CAD2FE /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		13C4D8662B054A1800CAD2FE /* Preview Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; };
		13C4D8682B054A1800CAD2FE /* Moodgpt.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = Moodgpt.entitlements; sourceTree = "<group>"; };
		B5A3ED7B2B05A4F100F22791 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
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
				B5A3ED7C2B05A4F100F22791 /* Info.plist in Resources */,
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
    echo "✅ Created a new project.pbxproj file based on a template"
fi

# Clean any corrupted workspace files
echo "Cleaning workspace caches and derived data..."
rm -rf "$PROJECT_DIR/Moodgpt.xcodeproj/project.xcworkspace/xcuserdata"
rm -rf "$PROJECT_DIR/Moodgpt.xcodeproj/xcuserdata"
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# Create a clean launch script
echo "Creating a script to launch the fixed project..."
LAUNCH_SCRIPT="$PROJECT_DIR/open_repaired_project.sh"
cat > "$LAUNCH_SCRIPT" << 'EOF'
#!/bin/bash
# Close Xcode if running
killall Xcode 2>/dev/null || true
sleep 1
# Open project
DIR="$(dirname "$0")"
open "$DIR/Moodgpt.xcodeproj" -a Xcode
EOF

chmod +x "$LAUNCH_SCRIPT"

echo "=== RECOVERY PROCESS COMPLETED ==="
echo "Project file has been recovered. You can now open it with:"
echo "./open_repaired_project.sh"
echo ""
echo "Important Notes:"
echo "1. This recovery process created a simplified project structure."
echo "2. You may need to re-add your source files to the project."
echo "3. Make sure Info.plist is correctly configured in build settings."
echo "4. You may need to re-add any dependencies or packages."
echo ""
echo "If the project still won't open, as a last resort:"
echo "1. Create a new Xcode project"
echo "2. Manually copy over source files"
echo "3. Configure settings from scratch"
echo "=== END OF RECOVERY PROCESS ===" 