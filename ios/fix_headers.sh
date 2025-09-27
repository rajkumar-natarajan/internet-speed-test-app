#!/bin/bash

# Fix for permission issues
echo "Fixing permissions for DerivedData..."
chmod -R 755 ~/Library/Developer/Xcode/DerivedData

# Create directory structure if it doesn't exist
mkdir -p /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Headers/Public/Yoga/Yoga

# Copy YGValue.h if it doesn't exist
if [ ! -f /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Headers/Public/Yoga/Yoga/YGValue.h ]; then
    echo "Creating YGValue.h..."
    cat > /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Headers/Public/Yoga/Yoga/YGValue.h << 'EOF'
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <cmath>
#include <cstdint>
#include <limits>

namespace facebook::yoga {

struct YGValue {
  float value;
  int unit;
};

constexpr auto YGUndefined = std::numeric_limits<float>::quiet_NaN();

inline bool isUndefined(float value) {
  return std::isnan(value);
}

inline bool isUndefined(const YGValue& value) {
  return isUndefined(value.value);
}

} // namespace facebook::yoga
EOF
fi

# Ensure our YogaHelpers.h is in place
echo "Creating YogaHelpers.h..."
cat > /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Headers/Public/Yoga/YogaHelpers.h << 'EOF'
#pragma once

#include "Yoga/YGValue.h"
#include <cmath>

// Helper functions to bridge namespace issues
namespace {
  // Global namespace helper for isUndefined
  template <typename T>
  bool isUndefined(T value) {
    return facebook::yoga::isUndefined(value);
  }
  
  // Global namespace helper for isinf
  template <typename T>
  bool isinf(T value) {
    return std::isinf(value);
  }
}

// Helper in facebook::yoga namespace
namespace facebook::yoga {
  // Explicit template specializations for isUndefined
  template bool isUndefined<YGValue>(YGValue value);
}
EOF

# Fix CachedMeasurement.h
echo "Fixing CachedMeasurement.h..."
if [ -f /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/YGStyle/CachedMeasurement.h ]; then
  sed -i '' '1s/^/#include "YogaHelpers.h"\n/' /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/YGStyle/CachedMeasurement.h
fi

# Fix FloatOptional.h
echo "Fixing FloatOptional.h..."
if [ -f /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/YGStyle/FloatOptional.h ]; then
  sed -i '' '1s/^/#include "YogaHelpers.h"\n/' /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/YGStyle/FloatOptional.h
fi

# Fix StyleLength.h
echo "Fixing StyleLength.h..."
if [ -f /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/YGStyle/StyleLength.h ]; then
  sed -i '' '1s/^/#include "YogaHelpers.h"\n/' /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/YGStyle/StyleLength.h
fi

# Fix CompactValue.h
echo "Fixing CompactValue.h..."
if [ -f /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/algorithm/CompactValue.h ]; then
  sed -i '' '1s/^/#include "YogaHelpers.h"\n/' /Users/rajkumarnatarajan/Desktop/coding/Ishaan/app/InternetSpeedTestApp/ios/Pods/Yoga/yoga/algorithm/CompactValue.h
fi

echo "Header fixes completed!"
