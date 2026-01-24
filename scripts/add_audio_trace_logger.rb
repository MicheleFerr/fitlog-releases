#!/usr/bin/env ruby

# Script to add AudioTraceLogger.swift to Xcode project
# Safer than manual .pbxproj editing

require 'xcodeproj'

# Paths
project_path = File.expand_path('../ios/Runner.xcworkspace/xcshareddata/xcschemes', __dir__)
project_file = File.expand_path('../ios/Runner.xcodeproj', __dir__)
file_to_add = 'ios/Runner/Managers/AudioTraceLogger.swift'

puts "🔧 Adding AudioTraceLogger.swift to Xcode project..."
puts "Project: #{project_file}"
puts "File: #{file_to_add}"

# Open project
begin
  project = Xcodeproj::Project.open(project_file)
rescue => e
  puts "❌ Error opening project: #{e.message}"
  puts "⚠️  Fallback: Install xcodeproj gem first:"
  puts "   gem install xcodeproj"
  exit 1
end

# Find Runner target
target = project.targets.find { |t| t.name == 'Runner' }
if target.nil?
  puts "❌ Error: Runner target not found"
  exit 1
end

# Find Managers group
managers_group = project.main_group.find_subpath('Runner/Managers', true)
if managers_group.nil?
  puts "❌ Error: Runner/Managers group not found"
  exit 1
end

# Check if file already exists in project
existing_file = managers_group.files.find { |f| f.path == 'AudioTraceLogger.swift' }

if existing_file
  puts "✅ AudioTraceLogger.swift already in project"
else
  # Add file reference
  file_ref = managers_group.new_file(file_to_add)

  # Add to build phase
  target.source_build_phase.add_file_reference(file_ref)

  puts "✅ Added AudioTraceLogger.swift to project"
end

# Save project
project.save

puts "✅ Project saved successfully"
puts ""
puts "Next steps:"
puts "1. Open Xcode: open ios/Runner.xcworkspace"
puts "2. Build project: Product → Build (⌘B)"
puts "3. Verify AudioTraceLogger.swift in Project Navigator"

