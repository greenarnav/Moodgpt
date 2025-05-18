#!/bin/bash

echo "=== DIRECT PROJECT FILE FIX ==="
echo "This script will try to fix the Xcode project file directly"

# Close Xcode to prevent conflicts
echo "Closing Xcode (if open)..."
killall Xcode 2>/dev/null || true
sleep 2

# Get project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)
PROJECT_FILE="$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj"

# Backup the project file
echo "Creating backup of project file..."
cp "$PROJECT_FILE" "$PROJECT_FILE.backup_$(date +%Y%m%d_%H%M%S)"

# Create a safer duplicate that we'll use for analysis
TEMP_PROJECT="$PROJECT_DIR/project.pbxproj.temp"
cp "$PROJECT_FILE" "$TEMP_PROJECT"

echo "Analyzing project file to identify duplicate build phases..."

# 1. Find Info.plist related build phases
INFO_PLIST_REFS=$(grep -n "Info.plist" "$TEMP_PROJECT" | grep -v "comment" | sort -r)
echo "Found $(echo "$INFO_PLIST_REFS" | wc -l | xargs) references to Info.plist"

# 2. Create a modification script
MODIFICATION_SCRIPT="$PROJECT_DIR/modify_project.rb"
cat > "$MODIFICATION_SCRIPT" << 'EOF'
#!/usr/bin/env ruby

# Simple script to clean Xcode project file
project_file = ARGV[0]
content = File.read(project_file)

# Store the original content for comparison
original_content = content.dup

# Track copy file phases for Info.plist
info_plist_phases = []
copy_phases = []

# Find PBXBuildFile sections with Info.plist
content.scan(/([0-9A-F]{24}) \/\* Info\.plist in/) do |match|
  info_plist_phases << match[0]
end

puts "Found #{info_plist_phases.size} Info.plist references in build phases"

# Keep only one Info.plist reference
if info_plist_phases.size > 1
  puts "Removing duplicate Info.plist build phase references"
  keep = info_plist_phases.first
  info_plist_phases[1..-1].each do |phase_id|
    # Remove the entire build file reference
    content.gsub!(/\s*#{phase_id} \/\* Info\.plist in.+?;\n/m, "")
  end
end

# Find duplicate copy phases
content.scan(/([\da-f]{24}) \/\* CopyFiles \*\/.*?{(.*?)}}/m) do |match|
  copy_phases << [match[0], match[1]]
end

puts "Found #{copy_phases.size} copy file phases"

# Check for duplicate output paths in copy phases
output_paths = {}
copy_phases.each do |phase_id, phase_content|
  if phase_content =~ /dstPath = "(.+?)";/
    path = $1
    output_paths[path] ||= []
    output_paths[path] << phase_id
  end
end

# Remove duplicate copy phases with the same output path
output_paths.each do |path, phase_ids|
  if phase_ids.size > 1
    puts "Found duplicate copy phases for path: #{path}"
    # Keep the first one, remove others
    phase_ids[1..-1].each do |phase_id|
      # Remove the entire copy phase
      content.gsub!(/\s*#{phase_id} \/\* CopyFiles \*\/.*?{.*?}}/m, "")
    end
  end
end

# Ensure Info.plist is not being generated
content.gsub!(/GENERATE_INFOPLIST_FILE = YES;/, "GENERATE_INFOPLIST_FILE = NO;")

# Fix common issues with Info.plist path
content.gsub!(/INFOPLIST_FILE = ".+Info.plist";/, 'INFOPLIST_FILE = "Moodgpt/Info.plist";')

# Write the modified content back if changes were made
if content != original_content
  File.write(project_file, content)
  puts "Project file modified successfully"
else
  puts "No modifications needed"
end
EOF

# Make the script executable
chmod +x "$MODIFICATION_SCRIPT"

# Run the modification script
echo "Applying fix to project file..."
ruby "$MODIFICATION_SCRIPT" "$PROJECT_FILE"

# Clean derived data
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

# Create an xcconfig file to ensure proper settings
echo "Creating configuration file..."
cat > "$PROJECT_DIR/FinalFix.xcconfig" << EOL
// Fix for multiple commands produce Info.plist
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = Moodgpt/Info.plist
COPY_PHASE_STRIP = NO
SKIP_INSTALL = YES
// Additional settings to prevent similar issues
PRODUCT_BUNDLE_IDENTIFIER = com.yourdomain.Moodgpt
EOL

echo "Opening project in Xcode..."
open "$PROJECT_DIR/Moodgpt.xcodeproj"

echo "=== Fix Applied ==="
echo "Recommendations:"
echo "1. In Xcode, go to Product > Clean Build Folder"
echo "2. Go to File > Project Settings > Build System and select 'New Build System'"
echo "3. Select the Moodgpt project in the navigator"
echo "4. Go to the Info tab > Configurations"
echo "5. Add the FinalFix.xcconfig configuration to both Debug and Release"
echo "6. Go to Build Phases and check for duplicate entries in Copy Bundle Resources"
echo "7. Ensure there's only one Info.plist being used"
echo "=== End of Fix ===" 