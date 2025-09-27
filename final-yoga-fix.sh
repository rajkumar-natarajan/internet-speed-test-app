#!/bin/bash

echo "🔧 Final fix for React Native iOS build issues"

# Step 1: Create a comprehensive Yoga compatibility header
echo "📦 Creating Yoga compatibility header..."
mkdir -p /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/node_modules/react-native/ReactCommon/yoga/yoga/compat

cat > /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/node_modules/react-native/ReactCommon/yoga/yoga/compat/YGCompat.h << 'EOF'
/*
 * Yoga Compatibility Layer for C++20
 * Provides global namespace aliases for backward compatibility
 */

#pragma once

#include "../YGEnums.h"
#include "../YGValue.h"

// Make all facebook::yoga types available in global namespace
using facebook::yoga::YGAlign;
using facebook::yoga::YGUnit;
using facebook::yoga::YGValue;

// Make all constants available in global namespace  
using facebook::yoga::YGUndefined;
using facebook::yoga::YGUnitUndefined;
using facebook::yoga::YGUnitPoint;
using facebook::yoga::YGUnitPercent;
using facebook::yoga::YGUnitAuto;
using facebook::yoga::YGUnitFitContent;
using facebook::yoga::YGUnitMaxContent;
using facebook::yoga::YGUnitStretch;

using facebook::yoga::YGAlignAuto;
using facebook::yoga::YGAlignFlexStart;
using facebook::yoga::YGAlignCenter;
using facebook::yoga::YGAlignFlexEnd;
using facebook::yoga::YGAlignStretch;
using facebook::yoga::YGAlignBaseline;
using facebook::yoga::YGAlignSpaceBetween;
using facebook::yoga::YGAlignSpaceAround;
using facebook::yoga::YGAlignSpaceEvenly;

// Forward declare missing enum types to prevent compiler errors
enum YGBoxSizing { YGBoxSizingBorderBox = 0, YGBoxSizingContentBox = 1 };
enum YGDimension { YGDimensionWidth = 0, YGDimensionHeight = 1 };
enum YGDirection { YGDirectionInherit = 0, YGDirectionLTR = 1, YGDirectionRTL = 2 };
enum YGDisplay { YGDisplayFlex = 0, YGDisplayNone = 1 };
enum YGEdge { YGEdgeLeft = 0, YGEdgeTop = 1, YGEdgeRight = 2, YGEdgeBottom = 3, YGEdgeStart = 4, YGEdgeEnd = 5, YGEdgeHorizontal = 6, YGEdgeVertical = 7, YGEdgeAll = 8 };
enum YGErrata { YGErrataAll = 0, YGErrataNone = 1 };
enum YGExperimentalFeature { YGExperimentalFeatureWebFlexBasis = 0, YGExperimentalFeatureAbsolutePercentageAgainstPaddingEdge = 1, YGExperimentalFeatureFixJNILocalRefOverflows = 2 };
enum YGFlexDirection { YGFlexDirectionColumn = 0, YGFlexDirectionColumnReverse = 1, YGFlexDirectionRow = 2, YGFlexDirectionRowReverse = 3 };
enum YGJustify { YGJustifyFlexStart = 0, YGJustifyCenter = 1, YGJustifyFlexEnd = 2, YGJustifySpaceBetween = 3, YGJustifySpaceAround = 4, YGJustifySpaceEvenly = 5 };
enum YGLogLevel { YGLogLevelError = 0, YGLogLevelWarn = 1, YGLogLevelInfo = 2, YGLogLevelDebug = 3, YGLogLevelVerbose = 4, YGLogLevelFatal = 5 };
enum YGMeasureMode { YGMeasureModeUndefined = 0, YGMeasureModeExactly = 1, YGMeasureModeAtMost = 2 };
enum YGNodeType { YGNodeTypeDefault = 0, YGNodeTypeText = 1 };
enum YGOverflow { YGOverflowVisible = 0, YGOverflowHidden = 1, YGOverflowScroll = 2 };
enum YGPositionType { YGPositionTypeStatic = 0, YGPositionTypeRelative = 1, YGPositionTypeAbsolute = 2 };
enum YGWrap { YGWrapNoWrap = 0, YGWrapWrap = 1, YGWrapWrapReverse = 2 };

EOF

# Step 2: Add the compatibility header to all Yoga C++ files
echo "🔗 Adding compatibility header includes..."
find /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/node_modules/react-native/ReactCommon/yoga/yoga -name "*.cpp" -exec sed -i '' '1i\
#include "compat/YGCompat.h"
' {} \;

# Step 3: Clean and rebuild
echo "🧹 Cleaning build artifacts..."
cd /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios
rm -rf build/
rm -rf ~/Library/Developer/Xcode/DerivedData/InternetSpeedTestApp-*

echo "✅ Final Yoga compatibility fixes applied!"
echo "🚀 Run: npm run ios"
