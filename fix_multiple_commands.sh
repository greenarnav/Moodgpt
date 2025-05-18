#!/bin/bash

echo "=== FIXING MULTIPLE COMMANDS PRODUCE INFO.PLIST ERROR ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)
PROJECT_FILE="$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj"

# Backup the project file first
cp "$PROJECT_FILE" "$PROJECT_FILE.backup_$(date +%Y%m%d%H%M%S)"
echo "✅ Created backup of project file"

# First approach: Ensure Info.plist is not included in Copy Files build phase
echo "Removing Info.plist from Copy Bundle Resources build phase if present..."

# Create a simple Ruby script to fix the project file
cat > fix_multiple_commands.rb << 'EOL'
#!/usr/bin/ruby

require 'pathname'

PROJ_FILE = ARGV[0]
content = File.read(PROJ_FILE)

# Look for the PBXResourcesBuildPhase section
resources_section = content.scan(/.*PBXResourcesBuildPhase.*?files\s*=\s*\((.*?)\);/m)
if resources_section.any?
  resources = resources_section[0][0]
  
  # Check if Info.plist is referenced in the resources section
  if resources.include?('Info.plist')
    puts "Found Info.plist reference in resources build phase..."
    # Remove the Info.plist reference line from the resources section
    modified_resources = resources.gsub(/\n\s*[A-F0-9]{24}\s*\/\*\s*Info\.plist.*?\*\/,\s*/, "\n")
    
    # Replace the original resources section with our modified version
    content.sub!(resources, modified_resources)
    puts "✅ Removed Info.plist reference from resources build phase"
    
    # Write the modified content back to the project file
    File.write(PROJ_FILE, content)
    puts "✅ Updated project file"
  else
    puts "Info.plist not found in resources build phase."
  end
else
  puts "Could not locate resources build phase in project file."
end

# Make sure the Info.plist is correctly referenced in the build settings
puts "Checking build configurations to ensure Info.plist is properly configured..."
has_changes = false

# Look for the XCBuildConfiguration sections
content = File.read(PROJ_FILE)
content.scan(/\/\* Debug \*\/.*?buildSettings = \{(.*?)\};/m).each do |match|
  build_settings = match[0]
  
  # Check if GENERATE_INFOPLIST_FILE is present and set to YES
  if build_settings.include?('GENERATE_INFOPLIST_FILE') && build_settings.include?('= YES')
    content.gsub!(/GENERATE_INFOPLIST_FILE = YES/, 'GENERATE_INFOPLIST_FILE = NO')
    has_changes = true
    puts "✅ Set GENERATE_INFOPLIST_FILE to NO in a build configuration"
  end
end

# If changes were made, write back to the file
if has_changes
  File.write(PROJ_FILE, content)
  puts "✅ Updated build settings in project file"
end

# Final check for settings
puts "Verifying Info.plist settings are correctly defined in build settings..."
missing_settings = false

# Ensure INFOPLIST_FILE is present
if !content.include?('INFOPLIST_FILE = Moodgpt/Info.plist')
  puts "⚠️ INFOPLIST_FILE setting not found or incorrect"
  missing_settings = true
else
  puts "✅ INFOPLIST_FILE is correctly set"
end

if missing_settings
  puts "Creating configuration file with correct Info.plist settings..."
  # This will be picked up in the parent script
  exit(1)
else
  exit(0)
end
EOL

chmod +x fix_multiple_commands.rb

# Run the Ruby script
echo "Running fix script to modify project file..."
ruby fix_multiple_commands.rb "$PROJECT_FILE"

# Create a configuration file to ensure Info.plist settings are correct
echo "Creating configuration file with correct Info.plist settings..."
cat > "$PROJECT_DIR/InfoPlist.xcconfig" << EOL
// Info.plist Configuration
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
EOL

echo "✅ Created InfoPlist.xcconfig with correct settings"

# Clean derived data to force a fresh build
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

echo "✅ Cleaned derived data"

# Create a script to launch Xcode with the correct configuration
cat > "$PROJECT_DIR/open_fixed_project.sh" << 'EOL'
#!/bin/bash

# Close Xcode if running
killall Xcode 2>/dev/null

# Clean Xcode caches
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/DerivedData/Moodgpt-*

# Open the project
open "$(dirname "$0")/Moodgpt.xcodeproj"

cat << "INSTRUCTIONS"

======================= INSTRUCTIONS =======================
After Xcode opens:

1. Select the Moodgpt project in the navigator
2. Select the Moodgpt target
3. Go to Build Phases tab
4. Expand "Copy Bundle Resources"
5. If Info.plist is listed, REMOVE IT by selecting and clicking the - button
6. Go to Build Settings tab
7. Search for "Info.plist"
8. Ensure these settings:
   - Info.plist File = Moodgpt/Info.plist
   - Generate Info.plist File = NO
9. Clean the build folder (Product > Clean Build Folder)
10. Build the project

If you still get the same error:
- Go to File > Project Settings
- Change Build System to "Legacy Build System"
- Try building again
======================= INSTRUCTIONS =======================

INSTRUCTIONS
EOL

chmod +x "$PROJECT_DIR/open_fixed_project.sh"

echo "=== FIX COMPLETED ==="
echo "To open the fixed project with instructions:"
echo "./open_fixed_project.sh"
echo ""
echo "The script has:"
echo "1. Removed Info.plist from Copy Bundle Resources if present"
echo "2. Set GENERATE_INFOPLIST_FILE = NO in build settings"
echo "3. Created InfoPlist.xcconfig with the correct settings"
echo "4. Cleaned derived data to ensure a fresh build"
echo ""
echo "Follow the instructions in the open_fixed_project.sh script to complete the fix." 