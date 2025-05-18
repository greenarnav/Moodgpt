#!/bin/bash

echo "=== FIXING INFO.PLIST DUPLICATION IN BUILD PHASES ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_FILE="Moodgpt.xcodeproj/project.pbxproj"

# Make a backup first
cp "$PROJECT_FILE" "$PROJECT_FILE.backup_$(date +%Y%m%d%H%M%S)"
echo "✅ Created backup of project file"

# First, let's check if the Info.plist is included in the Resources build phase
echo "Checking if Info.plist is in Resources build phase..."
INFOPLIST_IN_RESOURCES=$(grep -A 20 "Resources.*buildPhase" "$PROJECT_FILE" | grep -B 20 "runOnlyForDeploymentPostprocessing" | grep -c "Info.plist.*fileRef")

if [ "$INFOPLIST_IN_RESOURCES" -gt 0 ]; then
    echo "Found Info.plist in Resources build phase. Removing it..."
    
    # We'll create a temporary file to process the project file
    TEMP_FILE=$(mktemp)
    
    # This pattern looks for a line containing "Info.plist in Resources" and removes it plus the associated build file entry
    cat "$PROJECT_FILE" | awk '
    BEGIN { skip = 0; print_line = 1; }
    /Resources.*buildPhase/ { in_resources = 1; }
    /runOnlyForDeploymentPostprocessing/ { if (in_resources == 1) in_resources = 0; }
    /Info.plist.*fileRef/ { if (in_resources == 1) { skip = 1; } }
    { if (skip == 0 && print_line == 1) print $0; }
    /;$/ { if (skip == 1) { skip = 0; print_line = 0; } }
    /^\t\t/ { if (print_line == 0) print_line = 1; }
    ' > "$TEMP_FILE"
    
    # Replace the original file with our modified version
    mv "$TEMP_FILE" "$PROJECT_FILE"
    echo "✅ Removed Info.plist from Resources build phase"
else
    echo "Info.plist is not in Resources build phase. Checking other build phases..."
fi

# Make sure the Info.plist setting is correctly defined in the project and target settings
echo "Updating build settings to correctly reference the Info.plist..."

# Create an xcconfig file to set the correct Info.plist settings
cat > InfoPlistSettings.xcconfig << 'EOL'
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
EOL

echo "✅ Created InfoPlistSettings.xcconfig with correct settings"

# Clean derived data to ensure fresh build
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
echo "✅ Cleaned derived data"

# Create a script to verify build phases
cat > verify_build_phases.sh << 'EOL'
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
EOL

chmod +x verify_build_phases.sh
echo "✅ Created verification script at verify_build_phases.sh"

echo "=== FIX COMPLETED ==="
echo "The Info.plist duplication issue should be fixed. To verify:"
echo "1. Run ./verify_build_phases.sh to check build phases"
echo "2. Open Xcode and build the project"
echo ""
echo "If the error persists, follow the manual steps listed in the verification script." 