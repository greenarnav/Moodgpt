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
