#!/bin/bash

echo "🔍 COMPREHENSIVE iOS BUILD DIAGNOSTIC"
echo "===================================="

cd "$(dirname "$0")"

# 1. Environment Check
echo "📱 ENVIRONMENT STATUS:"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"  
echo "React Native CLI: $(npx react-native --version)"
echo "CocoaPods: $(pod --version)"
echo "Xcode: $(xcodebuild -version | head -1)"
echo ""

# 2. Project Validation
echo "📂 PROJECT VALIDATION:"
if [ ! -f "package.json" ]; then
    echo "❌ package.json not found"
    exit 1
fi
echo "✅ package.json exists"

if [ ! -f "ios/Podfile" ]; then
    echo "❌ iOS Podfile not found"
    exit 1
fi
echo "✅ iOS Podfile exists"

if [ ! -d "ios/InternetSpeedTestApp.xcworkspace" ]; then
    echo "❌ Xcode workspace not found"
    exit 1
fi
echo "✅ Xcode workspace exists"

if [ ! -d "node_modules" ]; then
    echo "❌ node_modules not found"
    exit 1
fi
echo "✅ node_modules exists"
echo ""

# 3. Dependency Check
echo "🔗 DEPENDENCY STATUS:"
echo "React Native version: $(grep '"react-native"' package.json)"
echo "React version: $(grep '"react"' package.json | head -1)"
echo ""

# 4. Metro Bundler Check
echo "🚇 METRO BUNDLER STATUS:"
if lsof -i :8081 | grep LISTEN >/dev/null 2>&1; then
    echo "✅ Metro bundler is running on port 8081"
else
    echo "❌ Metro bundler not running"
fi
echo ""

# 5. iOS Simulator Check
echo "📱 SIMULATOR STATUS:"
if xcrun simctl list devices | grep "iPhone 16 Pro.*Booted" >/dev/null 2>&1; then
    echo "✅ iPhone 16 Pro simulator is booted"
else
    echo "⚠️ iPhone 16 Pro simulator not booted"
    echo "Available simulators:"
    xcrun simctl list devices | grep iPhone | head -3
fi
echo ""

# 6. Yoga Files Check
echo "🧘 YOGA FRAMEWORK STATUS:"
YG_VALUE_H="node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h"
YG_VALUE_CPP="node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp"

if [ -f "$YG_VALUE_H" ]; then
    echo "✅ YGValue.h exists"
    if grep -q "isUndefined" "$YG_VALUE_H"; then
        echo "⚠️ YGValue.h contains potential conflicting definitions"
    else
        echo "✅ YGValue.h appears clean"
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

# 7. CocoaPods Status
echo "☕ COCOAPODS STATUS:"
cd ios
if [ -f "Podfile.lock" ]; then
    echo "✅ Podfile.lock exists"
    echo "Pod count: $(grep '^  - ' Podfile.lock | wc -l | tr -d ' ')"
else
    echo "❌ Podfile.lock missing"
fi

if [ -d "Pods" ]; then
    echo "✅ Pods directory exists"
else
    echo "❌ Pods directory missing"
fi
echo ""

# 8. Build Attempt with Error Capture
echo "🔨 BUILD TEST:"
echo "Attempting minimal build test..."

# Try to build just the Yoga target specifically
echo "Testing Yoga framework compilation..."
if xcodebuild -workspace InternetSpeedTestApp.xcworkspace -scheme InternetSpeedTestApp -configuration Debug -destination id=71189EA8-5CF8-4FA1-87DE-C754210AAFF3 -target Yoga build 2>/tmp/yoga_build_error.log >/dev/null; then
    echo "✅ Yoga target builds successfully"
else
    echo "❌ Yoga target build failed"
    echo "Last 5 error lines:"
    tail -5 /tmp/yoga_build_error.log 2>/dev/null || echo "No error log generated"
fi

# Try full build with timeout
echo "Testing full app build (with 60s timeout)..."
timeout 60 xcodebuild -workspace InternetSpeedTestApp.xcworkspace -scheme InternetSpeedTestApp -configuration Debug -destination id=71189EA8-5CF8-4FA1-87DE-C754210AAFF3 build 2>/tmp/full_build_error.log >/dev/null

BUILD_RESULT=$?
if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ Full build successful!"
elif [ $BUILD_RESULT -eq 124 ]; then
    echo "⏰ Build timed out after 60 seconds"
else
    echo "❌ Build failed with exit code $BUILD_RESULT"
    echo "Last 10 error lines:"
    tail -10 /tmp/full_build_error.log 2>/dev/null | grep -E "(error:|Error:|ERROR)" | head -5 || echo "No specific errors found in log"
fi

echo ""
echo "🏁 DIAGNOSTIC COMPLETE"
echo "Check /tmp/yoga_build_error.log and /tmp/full_build_error.log for detailed errors"
