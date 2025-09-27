#!/bin/bash

echo "🔧 Fixing Hermes framework permission issues and rebuilding iOS..."

# Navigate to project directory
cd "$(dirname "$0")"

# 1. Clean all build artifacts
echo "🧹 Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/InternetSpeedTestApp-*
rm -rf ios/build
rm -rf ios/Pods
rm -rf ios/InternetSpeedTestApp.xcworkspace

# 2. Reset npm cache and node_modules
echo "📦 Resetting Node.js dependencies..."
npm cache clean --force
rm -rf node_modules
npm ci

# 3. Reset Metro bundler cache
echo "🚇 Clearing Metro bundler cache..."
npx react-native start --reset-cache --port=8081 &
METRO_PID=$!
sleep 3
kill $METRO_PID 2>/dev/null || true

# 4. Clean and reinstall CocoaPods
echo "☕ Reinstalling CocoaPods dependencies..."
cd ios
pod cache clean --all
pod repo update
pod install --clean-install

# 5. Fix potential permission issues in advance
echo "🔒 Preemptively fixing potential permission issues..."
chmod -R 755 ~/Library/Developer/Xcode/DerivedData/ 2>/dev/null || true
chmod -R 755 ./build 2>/dev/null || true

# 6. Create a Hermes-specific fix for permission issues
cat > fix_hermes_permissions.sh << 'EOF'
#!/bin/bash
# Fix Hermes framework permissions during build
DERIVED_DATA_PATH=~/Library/Developer/Xcode/DerivedData/InternetSpeedTestApp-*/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/hermes-engine/Pre-built
if [ -d "$DERIVED_DATA_PATH" ]; then
    echo "Fixing Hermes framework permissions..."
    chmod -R 755 "$DERIVED_DATA_PATH" 2>/dev/null || true
    find "$DERIVED_DATA_PATH" -name "*.plist" -exec chmod 644 {} \; 2>/dev/null || true
    find "$DERIVED_DATA_PATH" -name "hermes" -exec chmod 755 {} \; 2>/dev/null || true
fi
EOF

chmod +x fix_hermes_permissions.sh

echo "✅ Clean rebuild preparation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Run: npm run ios"
echo "   2. If you get Hermes permission errors again, run: ./ios/fix_hermes_permissions.sh"
echo "   3. Then retry: npm run ios"
