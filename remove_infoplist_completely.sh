#!/bin/bash

echo "=== AGGRESSIVE INFO.PLIST FIX ==="

# Close Xcode first
echo "Closing Xcode if it's running..."
killall Xcode 2>/dev/null || true
sleep 1

cd "$(dirname "$0")"
PROJECT_FILE="Moodgpt.xcodeproj/project.pbxproj"

# Backup the project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup_$(date +%Y%m%d%H%M%S)"
echo "✅ Backed up project file"

# Direct file modification approach
echo "Directly modifying project file to remove Info.plist from build phases..."

# Create a sed script to remove Info.plist from all build phases
cat > remove_infoplist.sed << 'EOL'
# Remove any line containing "Info.plist" that's part of a PBXBuildFile section
/\/* Info\.plist in/ d

# Remove any reference to Info.plist in the PBXResourcesBuildPhase section
/PBXResourcesBuildPhase/,/\);/ {
  /Info\.plist/ d
}
EOL

# Apply the sed script
sed -i.bak -f remove_infoplist.sed "$PROJECT_FILE"
echo "✅ Removed Info.plist references from build phases"

# Ensure correct Info.plist settings in all build configurations
echo "Setting correct Info.plist settings in all build configurations..."

# Create a simple Ruby script to fix the project file more comprehensively
cat > fix_infoplist_settings.rb << 'EOL'
#!/usr/bin/ruby

require 'pathname'

PROJ_FILE = ARGV[0]
content = File.read(PROJ_FILE)

# Remove any Info.plist reference from PBXBuildFile sections
content.gsub!(/[0-9A-F]{24} \/\* Info\.plist.*?\*\/.*?;\n/, '')

# Remove any Info.plist fileRef from Resources build phase
resources_pattern = /(\/\* Begin PBXResourcesBuildPhase.*?\*\/.*?files = \()(.+?)(\);)/m
content.gsub!(resources_pattern) do |match|
  start, files, ending = $1, $2, $3
  # Remove any file reference to Info.plist
  files = files.gsub(/[0-9A-F]{24} \/\* Info\.plist.*?\*\/,?\s*/, '')
  # Clean up any trailing commas
  files = files.gsub(/,\s*\Z/, '')
  "#{start}#{files}#{ending}"
end

# Update all build configurations to have consistent Info.plist settings
debug_configs = content.scan(/\/\* Debug \*\/ = \{.*?buildSettings = \{(.*?)\};/m)
release_configs = content.scan(/\/\* Release \*\/ = \{.*?buildSettings = \{(.*?)\};/m)

# Process all configuration sections
all_configs = debug_configs + release_configs
all_configs.each do |match|
  section = match[0]
  
  # Make sure GENERATE_INFOPLIST_FILE is NO in all configurations
  if section.include?('GENERATE_INFOPLIST_FILE')
    content.gsub!(/GENERATE_INFOPLIST_FILE = YES/, 'GENERATE_INFOPLIST_FILE = NO')
  else
    # If GENERATE_INFOPLIST_FILE is missing, add it to the buildSettings section
    content.gsub!(/(buildSettings = \{)/, '\1' + "\n\t\t\t\tGENERATE_INFOPLIST_FILE = NO;")
  end
  
  # Make sure INFOPLIST_FILE is set correctly in all configurations
  if section.include?('INFOPLIST_FILE')
    content.gsub!(/INFOPLIST_FILE = .*?;/, 'INFOPLIST_FILE = Moodgpt/Info.plist;')
  else
    # If INFOPLIST_FILE is missing, add it to the buildSettings section
    content.gsub!(/(buildSettings = \{)/, '\1' + "\n\t\t\t\tINFOPLIST_FILE = Moodgpt/Info.plist;")
  end
end

# Write the modified content back to the project file
File.write(PROJ_FILE, content)
puts "✅ Updated all build configurations with correct Info.plist settings"
EOL

chmod +x fix_infoplist_settings.rb

# Run the Ruby script
echo "Running comprehensive fix script..."
ruby fix_infoplist_settings.rb "$PROJECT_FILE"

# Create a global xcconfig file
echo "Creating global xcconfig file with correct Info.plist settings..."
cat > "Moodgpt.xcodeproj/xcshareddata/xcschemes/InfoPlist.xcconfig" << 'EOL'
// Force correct Info.plist settings
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
EOL
mkdir -p "Moodgpt.xcodeproj/xcshareddata/xcschemes"
echo "✅ Created global xcconfig with Info.plist settings"

# Switch to legacy build system
echo "Switching to Legacy Build System which handles Info.plist better..."
mkdir -p "Moodgpt.xcodeproj/project.xcworkspace/xcshareddata"
cat > "Moodgpt.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings" << 'EOL'
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
echo "✅ Switched to Legacy Build System"

# Clean Xcode caches and derived data
echo "Cleaning Xcode caches and derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/DerivedData/Moodgpt-*
echo "✅ Cleaned Xcode caches and derived data"

# Create a script to open Xcode with a clean slate
cat > open_fixed_xcode.sh << 'EOL'
#!/bin/bash

# Close Xcode if running
killall Xcode 2>/dev/null || true
sleep 1

# Remove any lingering Xcode workspace state
rm -rf Moodgpt.xcodeproj/project.xcworkspace/xcuserdata
rm -rf Moodgpt.xcodeproj/xcuserdata

# Clean derived data one more time
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

# Open the project
open Moodgpt.xcodeproj

echo "
======================= IMPORTANT =======================
In Xcode:

1. Clean the build folder: Product > Clean Build Folder
2. Manual check these settings:
   - Select Project > Target > Build Phases
   - Make sure Info.plist is NOT in Copy Bundle Resources
   - Go to Build Settings
   - Make sure INFOPLIST_FILE = Moodgpt/Info.plist
   - Make sure GENERATE_INFOPLIST_FILE = NO

3. If still having issues:
   - Try Product > Clean Build Folder again
   - Try building with Command + B
======================= IMPORTANT =======================
"
EOL

chmod +x open_fixed_xcode.sh
echo "✅ Created script to open fixed Xcode project"

echo "=== FIX COMPLETED ==="
echo "Run the following command to open the fixed Xcode project:"
echo "./open_fixed_xcode.sh" 