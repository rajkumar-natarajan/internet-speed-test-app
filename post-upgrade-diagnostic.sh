#!/bin/bash

echo "🔍 POST-UPGRADE DIAGNOSTIC"
echo "========================="

cd "$(dirname "$0")"

# 1. Verify versions
echo "📋 CURRENT VERSIONS:"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "React Native: $(grep '"react-native"' package.json | cut -d'"' -f4)"
echo "React: $(grep '"react"' package.json | head -1 | cut -d'"' -f4)"
echo ""

# 2. Check if the upgrade broke anything
echo "🔍 CHECKING PACKAGE INTEGRITY:"
if npm list react-native react >/dev/null 2>&1; then
    echo "✅ Core packages installed correctly"
else
    echo "❌ Package installation issues detected"
    npm list react-native react
fi
echo ""

# 3. Check Yoga files after upgrade
echo "🧘 YOGA FRAMEWORK STATUS:"
YG_VALUE_H="node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h"
YG_VALUE_CPP="node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp"

if [ -f "$YG_VALUE_H" ]; then
    echo "✅ YGValue.h exists"
    # Check for problematic content
    if grep -q "template.*isUndefined.*YGValue" "$YG_VALUE_H" 2>/dev/null; then
        echo "❌ Template conflicts still present"
        echo "Lines with conflicts:"
        grep -n "template.*isUndefined.*YGValue" "$YG_VALUE_H" || true
    else
        echo "✅ No template conflicts detected"
    fi
else
    echo "❌ YGValue.h missing"
fi

if [ -f "$YG_VALUE_CPP" ]; then
    echo "✅ YGValue.cpp exists"
else
    echo "❌ YGValue.cpp missing"
fi
echo ""

# 4. Quick build test to see error pattern
echo "🔨 QUICK BUILD TEST:"
cd ios

# Test just dependency resolution first
echo "Testing dependency resolution..."
if xcodebuild -workspace InternetSpeedTestApp.xcworkspace -scheme InternetSpeedTestApp -configuration Debug -destination id=71189EA8-5CF8-4FA1-87DE-C754210AAFF3 -dry-run build >/dev/null 2>&1; then
    echo "✅ Dependency resolution successful"
else
    echo "❌ Dependency resolution failed"
fi

# Try to build with a short timeout to catch early errors
echo "Testing compilation (10 second sample)..."
( 
    xcodebuild -workspace InternetSpeedTestApp.xcworkspace -scheme InternetSpeedTestApp -configuration Debug -destination id=71189EA8-5CF8-4FA1-87DE-C754210AAFF3 build 2>&1 &
    BUILD_PID=$!
    sleep 10
    kill $BUILD_PID 2>/dev/null
    wait $BUILD_PID 2>/dev/null
) | grep -E "(error|Error|failed|Failed)" | head -5 || echo "No immediate errors detected"

echo ""
echo "🎯 ANALYSIS COMPLETE"
