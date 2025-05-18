#!/usr/bin/env ruby
require 'xcodeproj'

# Path to the Xcode project
project_path = 'Moodgpt.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
main_target = project.targets.find { |target| target.name == 'Moodgpt' }

if main_target.nil?
  puts "Target 'Moodgpt' not found."
  exit 1
end

info_plist_path = 'Moodgpt/Info.plist'

# Remove Info.plist from Copy Bundle Resources build phase
resources_phase = main_target.resources_build_phase
resources_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path == info_plist_path
    puts "Removing Info.plist from Copy Bundle Resources build phase..."
    resources_phase.remove_build_file(build_file)
  end
end

# Add INFOPLIST_FILE build setting if it doesn't exist
main_target.build_configurations.each do |config|
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['INFOPLIST_FILE'] = info_plist_path
  puts "Updated build settings for configuration: #{config.name}"
end

# Save the changes
project.save
puts "Project updated successfully." 