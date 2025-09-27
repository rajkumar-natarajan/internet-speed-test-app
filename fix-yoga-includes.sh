#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Create the helper header
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/helpers
cp fix-yoga/YogaHelpers.h node_modules/react-native/ReactCommon/yoga/yoga/helpers/

# Update YGMacros.h with our fixed version
cp node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h.backup
cp node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h.fixed node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h

# Add include for helpers in all relevant files
for file in $(find node_modules/react-native/ReactCommon/yoga -name "*.cpp" -o -name "*.h"); do
  # Skip our helper file and backup files
  if [[ "$file" == *"YogaHelpers.h"* ]] || [[ "$file" == *".backup"* ]] || [[ "$file" == *".fixed"* ]]; then
    continue
  fi
  
  # Add include for our helpers
  sed -i.bak '/#include <yoga\/YGMacros.h>/a\
#include <yoga/helpers/YogaHelpers.h>' "$file"
  
  # Remove backup file
  rm -f "${file}.bak"
done

# Copy the helpers to the Pods directory
mkdir -p ios/Pods/Headers/Private/Yoga/yoga/helpers
cp fix-yoga/YogaHelpers.h ios/Pods/Headers/Private/Yoga/yoga/helpers/

# Add include for helpers in all Pod header files
for file in $(find ios/Pods/Headers/Private/Yoga -name "*.h"); do
  # Skip our helper file and backup files
  if [[ "$file" == *"YogaHelpers.h"* ]] || [[ "$file" == *".backup"* ]]; then
    continue
  fi
  
  # Add include for our helpers
  sed -i.bak '/#include <yoga\/YGMacros.h>/a\
#include <yoga/helpers/YogaHelpers.h>' "$file"
  
  # Remove backup file
  rm -f "${file}.bak"
done

echo "All Yoga includes have been fixed!"
