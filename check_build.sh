#!/bin/bash

# Check for build failures in the DerivedData directory
cd ~/Library/Developer/Xcode/DerivedData/
latest_dir=$(ls -td InternetSpeedTestApp-* | head -1)
if [ -z "$latest_dir" ]; then
  echo "No InternetSpeedTestApp build directory found"
  exit 1
fi

cd "$latest_dir"
echo "Checking build logs in $latest_dir"

# Check for compilation errors
if [ -f "Logs/Build/LogStoreManifest.plist" ]; then
  echo "Build logs exist, checking for errors..."
  
  # Find the latest log file
  latest_log=$(find Logs/Build -name "*.xcactivitylog" -type f -exec stat -f "%m %N" {} \; | sort -nr | head -1 | cut -d' ' -f2-)
  
  if [ -n "$latest_log" ]; then
    echo "Latest build log: $latest_log"
    echo "Extracting log content..."
    
    # Extract log content (xcactivitylog is a compressed binary file)
    # We'll look for common error indicators
    extracted_log=$(xcrun log export "$latest_log" --predicate 'eventType == "logEvent"' --style compact)
    
    # Search for error indicators
    if echo "$extracted_log" | grep -q "error:"; then
      echo "Build errors found:"
      echo "$extracted_log" | grep -A 2 -B 2 "error:" | head -20
    else
      echo "No obvious errors found in the build log."
    fi
  else
    echo "No build log files found"
  fi
else
  echo "No build logs exist yet"
fi

# Check build status
if [ -d "Build/Products/Debug-iphonesimulator" ]; then
  echo "Debug build products directory exists"
  if [ -d "Build/Products/Debug-iphonesimulator/InternetSpeedTestApp.app" ]; then
    echo "App bundle exists - build may have succeeded!"
  else
    echo "App bundle doesn't exist - build likely failed"
  fi
else
  echo "Debug build products directory doesn't exist - build may still be in progress or failed"
fi
