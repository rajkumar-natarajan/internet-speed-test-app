#!/bin/bash
# Fix Hermes framework permissions during build
DERIVED_DATA_PATH=~/Library/Developer/Xcode/DerivedData/InternetSpeedTestApp-*/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/hermes-engine/Pre-built
if [ -d "$DERIVED_DATA_PATH" ]; then
    echo "Fixing Hermes framework permissions..."
    chmod -R 755 "$DERIVED_DATA_PATH" 2>/dev/null || true
    find "$DERIVED_DATA_PATH" -name "*.plist" -exec chmod 644 {} \; 2>/dev/null || true
    find "$DERIVED_DATA_PATH" -name "hermes" -exec chmod 755 {} \; 2>/dev/null || true
fi
