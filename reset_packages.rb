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
