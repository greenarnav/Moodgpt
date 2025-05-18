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
