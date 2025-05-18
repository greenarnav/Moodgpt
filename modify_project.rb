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
