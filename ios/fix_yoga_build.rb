#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

# Path to the Pods project
pods_project_path = '/Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Pods.xcodeproj'

# Open the project
project = Xcodeproj::Project.open(pods_project_path)

# Find the Yoga target
yoga_target = project.targets.find { |target| target.name == 'Yoga' }

if yoga_target
  puts "Found Yoga target"

  # Modify build settings for each build configuration
  yoga_target.build_configurations.each do |config|
    # Disable warnings treated as errors
    config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
    config.build_settings['SWIFT_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
    config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
    
    # Set C++ standard to C++17 instead of C++20
    config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'

    # Add additional header search paths
    header_search_paths = config.build_settings['HEADER_SEARCH_PATHS'] || '$(inherited)'
    unless header_search_paths.include?('$(PODS_ROOT)/Headers/Public/Yoga')
      header_search_paths += ' $(PODS_ROOT)/Headers/Public/Yoga'
    end
    config.build_settings['HEADER_SEARCH_PATHS'] = header_search_paths
    
    # Inhibit all warnings
    config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    
    puts "Modified build settings for configuration: #{config.name}"
  end

  # Save the project
  project.save
  puts "Saved Pods project with modified Yoga build settings"
else
  puts "Yoga target not found in the Pods project"
end
