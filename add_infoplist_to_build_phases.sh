#!/bin/bash

echo "=== Adding Info.plist to Build Phases ==="

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Ensure Xcode is closed
echo "Closing Xcode (if open)..."
killall Xcode 2>/dev/null || true
sleep 2

# Create modification script to add to build phases
MODIFY_SCRIPT="$PROJECT_DIR/add_to_build_phases.rb"
cat > "$MODIFY_SCRIPT" << 'EOF'
#!/usr/bin/env ruby

# Script to ensure Info.plist is included in build phases
project_file = ARGV[0]
content = File.read(project_file)
original_content = content.dup

# Make sure Info.plist settings are correct (not using variables)
content.gsub!(/INFOPLIST_FILE = "([^"]+)";/) do |match|
  if $1 != "Moodgpt/Info.plist"
    'INFOPLIST_FILE = "Moodgpt/Info.plist";'
  else
    match
  end
end

# Make sure it's included in Copy Bundle Resources
resources_section_pattern = /(\/\* Begin PBXResourcesBuildPhase section \*\/.*?files = \()/m

if content =~ resources_section_pattern
  # Check if Info.plist is already in resources
  if !content.include?('Info.plist in Resources')
    # Generate a unique ID for the reference (24 chars hex)
    new_id = (0...24).map { |i| i % 2 == 0 ? ('A'..'F').to_a[rand(6)] : rand(10) }.join
    
    # Add the reference to the resources build phase
    content.gsub!(resources_section_pattern, "\\1\n\t\t\t\t#{new_id} /* Info.plist in Resources */,")
    
    # Also need to add a file reference if it doesn't exist
    if !content.include?('Info.plist */ = {isa = PBXFileReference;')
      file_ref_id = (0...24).map { |i| i % 2 == 0 ? ('A'..'F').to_a[rand(6)] : rand(10) }.join
      
      # Add file reference
      file_refs_pattern = /(\/\* Begin PBXFileReference section \*\/)/
      content.gsub!(file_refs_pattern, "\\1\n\t\t#{file_ref_id} /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; };")
      
      # Add to PBXBuildFile section
      build_file_id = (0...24).map { |i| i % 2 == 0 ? ('A'..'F').to_a[rand(6)] : rand(10) }.join
      
      build_files_pattern = /(\/\* Begin PBXBuildFile section \*\/)/
      content.gsub!(build_files_pattern, "\\1\n\t\t#{build_file_id} /* Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = #{file_ref_id} /* Info.plist */; };")
      
      # Use the build file ID in the resources section
      content.gsub!(/#{new_id} \/\* Info\.plist in Resources \*\//, "#{build_file_id} /* Info.plist in Resources */")
    end
  end
end

# Update build settings to make sure they're correct
build_settings_pattern = /(buildSettings = \{[^\}]*?)(INFOPLIST_FILE = "[^"]+";)/m
if content =~ build_settings_pattern
  content.gsub!(build_settings_pattern, '\1INFOPLIST_FILE = "Moodgpt/Info.plist";')
else
  # If INFOPLIST_FILE isn't set at all, add it to build settings
  build_settings_pattern = /(buildSettings = \{)/
  content.gsub!(build_settings_pattern, '\1\n\t\t\t\tINFOPLIST_FILE = "Moodgpt/Info.plist";')
end

# Make sure Info.plist generation is disabled
if content.include?('GENERATE_INFOPLIST_FILE = YES')
  content.gsub!(/GENERATE_INFOPLIST_FILE = YES/, 'GENERATE_INFOPLIST_FILE = NO')
elsif !content.include?('GENERATE_INFOPLIST_FILE = NO')
  # Add the setting if it doesn't exist
  build_settings_pattern = /(buildSettings = \{)/
  content.gsub!(build_settings_pattern, '\1\n\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
end

# Write back if changes were made
if content != original_content
  File.write(project_file, content)
  puts "✅ Project file updated to include Info.plist in build phases and fix settings"
else
  puts "✅ No changes needed - Info.plist is already properly set up"
end
EOF

chmod +x "$MODIFY_SCRIPT"

# Run the script
echo "Modifying project file to include Info.plist in build phases..."
ruby "$MODIFY_SCRIPT" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj"

# Create a configuration file to ensure Info.plist is properly used
echo "Creating configuration file to fix Info.plist setup..."
cat > "$PROJECT_DIR/InfoPlistConfig.xcconfig" << EOL
// Use a physical Info.plist file instead of generating one
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist

// Make sure it gets included in the bundle
COPY_PHASE_STRIP = NO
SKIP_INSTALL = NO

// Code signing settings to avoid issues
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = 
EOL

# Clean any stale build data
echo "Cleaning build data..."
rm -rf "$PROJECT_DIR/build"
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

# Create a script to open Xcode with fixed settings
echo "Creating a script to launch Xcode with fixed settings..."
LAUNCH_SCRIPT="$PROJECT_DIR/open_fixed_project.sh"
cat > "$LAUNCH_SCRIPT" << 'EOF'
#!/bin/bash
# Close any running Xcode instances
killall Xcode 2>/dev/null || true
sleep 2
# Clean Xcode caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode/
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
# Launch Xcode with the project
DIR="$(dirname "$0")"
open "$DIR/Moodgpt.xcodeproj" -a Xcode
EOF

chmod +x "$LAUNCH_SCRIPT"

# Launch Xcode
echo "Launching Xcode with fixed settings..."
"$LAUNCH_SCRIPT"

echo "=== FIX APPLIED ==="
echo "Info.plist has been added to build phases and project settings have been fixed."
echo ""
echo "To fix the code signing issue in Xcode:"
echo "1. Select the Moodgpt project in the navigator"
echo "2. Select the Moodgpt target"
echo "3. Go to the Build Settings tab"
echo "4. Click '+' at the top left of the settings panel and select 'Add User-Defined Setting'"
echo "5. Add 'INFOPLIST_FILE' with value 'Moodgpt/Info.plist'"
echo "6. Go to the Build Phases tab"
echo "7. Expand 'Copy Bundle Resources'"
echo "8. If Info.plist is not listed, click '+' and add 'Moodgpt/Info.plist'"
echo "9. Clean build folder (Product > Clean Build Folder)"
echo "10. Build the project again"
echo ""
echo "If you still have issues, try:"
echo "1. Go to File > Project Settings"
echo "2. Set 'Build System' to 'Legacy Build System'"
echo "3. Close and reopen the project"
echo "=== END OF FIX ===" 