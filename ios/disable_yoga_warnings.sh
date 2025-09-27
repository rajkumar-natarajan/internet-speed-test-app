#!/bin/bash

# Navigate to the Pods project
cd /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods

# Find all Yoga source files and modify their compiler flags
find . -name "*.cpp" -path "*/yoga/*" -exec sed -i '' '1i\
#pragma clang diagnostic ignored "-Wall"\
#pragma clang diagnostic ignored "-Wdocumentation"\
#pragma clang diagnostic ignored "-Wunknown-pragmas"\
#pragma clang diagnostic ignored "-Wundefined-func-template"\
' {} \;

find . -name "*.h" -path "*/yoga/*" -exec sed -i '' '1i\
#pragma clang diagnostic ignored "-Wall"\
#pragma clang diagnostic ignored "-Wdocumentation"\
#pragma clang diagnostic ignored "-Wunknown-pragmas"\
#pragma clang diagnostic ignored "-Wundefined-func-template"\
' {} \;

echo "Disabled warnings for all Yoga files"
