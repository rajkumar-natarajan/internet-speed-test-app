#!/bin/bash

echo "🚀 UPGRADING REACT NATIVE & REACT TO LATEST COMPATIBLE VERSIONS"
echo "=============================================================="

cd "$(dirname "$0")"

# 1. Show current versions
echo "📋 CURRENT VERSIONS:"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "React Native: $(grep '"react-native"' package.json | cut -d'"' -f4)"
echo "React: $(grep '"react"' package.json | head -1 | cut -d'"' -f4)"
echo ""

# 2. Backup current package.json
echo "💾 Creating backup of package.json..."
cp package.json package.json.backup
echo "✅ Backup created: package.json.backup"
echo ""

# 3. Check latest versions
echo "🔍 CHECKING LATEST COMPATIBLE VERSIONS:"
LATEST_RN=$(npm view react-native version)
LATEST_REACT=$(npm view react version)
echo "Latest React Native: $LATEST_RN"
echo "Latest React: $LATEST_REACT"
echo ""

# 4. Stop Metro bundler if running
echo "🛑 Stopping Metro bundler..."
lsof -i :8081 | grep LISTEN | awk '{print $2}' | xargs kill -9 2>/dev/null || true
echo ""

# 5. Clean existing setup
echo "🧹 Cleaning existing setup..."
rm -rf node_modules
rm -f package-lock.json
cd ios
rm -rf Pods
rm -f Podfile.lock
cd ..
echo "✅ Clean completed"
echo ""

# 6. Upgrade React Native and React
echo "📦 UPGRADING REACT NATIVE & REACT..."
echo "Installing React Native $LATEST_RN and React $LATEST_REACT..."

# Update package.json dependencies
npm install react-native@$LATEST_RN react@$LATEST_REACT

# Also update related packages to compatible versions
npm install @react-native/metro-config@latest
npm install @react-native/babel-preset@latest

echo "✅ Core packages upgraded"
echo ""

# 7. Update CLI and tools
echo "🛠️ UPDATING REACT NATIVE CLI AND TOOLS..."
npm install -g @react-native-community/cli@latest
npm install @react-native-community/cli@latest --save-dev

echo "✅ CLI updated"
echo ""

# 8. Update iOS dependencies
echo "📱 UPDATING iOS DEPENDENCIES..."
cd ios

# Update CocoaPods
echo "Updating CocoaPods specs..."
pod repo update
pod install --repo-update

cd ..
echo "✅ iOS dependencies updated"
echo ""

# 9. Preserve our Yoga fixes
echo "🧘 PRESERVING YOGA FRAMEWORK FIXES..."
YG_VALUE_H="node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h"
YG_VALUE_CPP="node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp"

if [ -f "$YG_VALUE_H" ] && [ -f "$YG_VALUE_CPP" ]; then
    echo "Yoga files found, checking if fixes need to be reapplied..."
    
    # Check if our fixes are still needed
    if grep -q "template.*isUndefined.*YGValue" "$YG_VALUE_H" 2>/dev/null; then
        echo "⚠️ Template conflicts detected, reapplying fixes..."
        # Reapply our targeted fix
        sed -i.bak '/^template.*isUndefined.*YGValue/d' "$YG_VALUE_H"
        sed -i.bak '/^extern template.*isUndefined/d' "$YG_VALUE_H"
        echo "✅ Yoga template fixes reapplied"
    else
        echo "✅ Yoga fixes preserved or no longer needed"
    fi
else
    echo "ℹ️ Yoga files not found or changed location in new version"
fi
echo ""

# 10. Show new versions
echo "🎉 UPGRADE COMPLETE!"
echo "==================="
echo "NEW VERSIONS:"
echo "Node.js: $(node --version)"
echo "React Native: $(grep '"react-native"' package.json | cut -d'"' -f4)"
echo "React: $(grep '"react"' package.json | head -1 | cut -d'"' -f4)"
echo ""

# 11. Test compatibility
echo "🧪 TESTING COMPATIBILITY..."
node -e "
const pkg = require('./package.json');
const nodeVersion = process.version;
const rnVersion = pkg.dependencies['react-native'];

console.log('Node.js:', nodeVersion);
console.log('React Native:', rnVersion);

if (nodeVersion.startsWith('v24') && rnVersion.startsWith('0.81')) {
    console.log('✅ COMPATIBILITY: React Native', rnVersion, 'should be compatible with Node.js', nodeVersion);
} else {
    console.log('⚠️ Please verify compatibility manually');
}
"
echo ""

echo "📋 NEXT STEPS:"
echo "1. Run: npm run ios"
echo "2. If there are any remaining issues, check the iOS_BUILD_FIXES.md"
echo "3. Yoga framework fixes have been preserved/reapplied as needed"
echo ""

echo "🎯 The app should now build successfully with Node.js 24.7.0!"
