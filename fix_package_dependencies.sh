#!/bin/bash

echo "=== FIXING PACKAGE DEPENDENCY ISSUES ==="
echo "This script will fix Swift Package Manager dependency issues"

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

# Ensure Xcode is closed
echo "Closing Xcode (if open)..."
killall Xcode 2>/dev/null || true
sleep 2

# Clean all SPM caches
echo "Cleaning Swift Package Manager caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf "$PROJECT_DIR/SourcePackages"
rm -rf "$PROJECT_DIR/.build"

# Remove package references from workspace
echo "Removing package references from workspace..."
rm -rf "$PROJECT_DIR/Moodgpt.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
rm -rf "$PROJECT_DIR/Moodgpt.xcodeproj/xcuserdata"

# Create a package resolver force reset script
RESOLVER_SCRIPT="$PROJECT_DIR/reset_packages.rb"
cat > "$RESOLVER_SCRIPT" << 'EOF'
#!/usr/bin/env ruby

# Script to remove package references from Xcode project
project_file = ARGV[0]
content = File.read(project_file)

# Store original content
original_content = content.dup

# Look for Swift Package references
if content =~ /\/\* XCRemoteSwiftPackageReference section \*\//
  puts "Found Swift Package references, removing duplicates..."
  
  # Get the section
  package_section_match = content.match(/(\/\* Begin XCRemoteSwiftPackageReference section \*\/.*?\/\* End XCRemoteSwiftPackageReference section \*\/)/m)
  
  if package_section_match
    package_section = package_section_match[1]
    
    # Find all package references
    package_refs = {}
    package_section.scan(/([0-9A-F]{24}) \/\* XCRemoteSwiftPackageReference "([^"]+)" \*\/.*?\{.*?repositoryURL = "([^"]+)";/m) do |id, name, url|
      package_refs[url] ||= []
      package_refs[url] << id
    end
    
    # Look for duplicates
    package_refs.each do |url, ids|
      if ids.size > 1
        puts "Found duplicate package references for #{url}"
        keep_id = ids.first
        
        # Remove duplicates
        ids[1..-1].each do |id|
          # Remove the package reference
          content.gsub!(/\s*#{id} \/\* XCRemoteSwiftPackageReference.*?\n.*?\n.*?\n.*?\n.*?\};/m, "")
          
          # Also remove any package product dependency referencing this
          content.gsub!(/packageProductDependencies = \(.*?#{id}.*?\);/m) do |match|
            # Keep the structure but remove the specific reference
            match.gsub(/\s*#{id} \/\* [^*]+\*\/,?/, "")
          end
        end
      end
    end
  end
end

# Clean up any problematic package references
# This section helps fix the "unable to load transferred PIF" error
package_references = []
content.scan(/packageReferences = \((.*?)\);/m) do |match|
  refs_section = match[0]
  # Collect all package references
  refs_section.scan(/([0-9A-F]{24}) \/\* [^*]+ \*\//) do |ref_id|
    package_references << ref_id[0]
  end
end

# Check for duplicate package dependencies
if content =~ /\/\* XCSwiftPackageProductDependency section \*\//
  dependency_section_match = content.match(/(\/\* Begin XCSwiftPackageProductDependency section \*\/.*?\/\* End XCSwiftPackageProductDependency section \*\/)/m)
  
  if dependency_section_match
    dependency_section = dependency_section_match[1]
    
    # Find package dependencies
    dependencies = {}
    dependency_section.scan(/([0-9A-F]{24}) \/\* [^*]+ \*\/.*?package = ([0-9A-F]{24}).*?product = "([^"]+)"/m) do |id, package_id, product|
      key = "#{package_id}:#{product}"
      dependencies[key] ||= []
      dependencies[key] << id
    end
    
    # Remove duplicates
    dependencies.each do |key, ids|
      if ids.size > 1
        puts "Found duplicate package dependency for #{key}"
        # Keep first one, remove others
        ids[1..-1].each do |id|
          content.gsub!(/\s*#{id} \/\* [^*]+ \*\/.*?};/m, "")
        end
      end
    end
  end
end

# Write back if changes were made
if content != original_content
  File.write(project_file, content)
  puts "Project file updated to fix package dependency issues"
else
  puts "No package dependency issues found"
end
EOF

# Make the script executable
chmod +x "$RESOLVER_SCRIPT"

# Run the script
echo "Removing duplicate package references..."
ruby "$RESOLVER_SCRIPT" "$PROJECT_DIR/Moodgpt.xcodeproj/project.pbxproj"

# Clean derived data thoroughly
echo "Cleaning derived data thoroughly..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Create a script to reopen Xcode with clean state
REOPEN_SCRIPT="$PROJECT_DIR/clean_open_xcode.sh"
cat > "$REOPEN_SCRIPT" << 'EOF'
#!/bin/bash
# Close Xcode
killall Xcode 2>/dev/null || true
sleep 2
# Clean caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode/
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# Open project
open "$(dirname "$0")/Moodgpt.xcodeproj"
EOF

chmod +x "$REOPEN_SCRIPT"

echo "=== Fix Applied ==="
echo "To complete the fix:"
echo "1. Run ./clean_open_xcode.sh to open your project with a clean state"
echo "2. In Xcode, go to File > Swift Packages > Reset Package Caches"
echo "3. If prompted to resolve packages, click 'Resolve'"
echo "4. Go to Product > Clean Build Folder"
echo "5. Build the project"
echo ""
echo "If you still have issues:"
echo "1. Close Xcode"
echo "2. Open the project navigator"
echo "3. Expand the 'Package Dependencies' section"
echo "4. Right-click on GoogleSignIn and select 'Remove Package'"
echo "5. Build once without the package"
echo "6. Then add it back with File > Add Packages"
echo "=== End of Fix ===" 