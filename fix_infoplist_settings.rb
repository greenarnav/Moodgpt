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
