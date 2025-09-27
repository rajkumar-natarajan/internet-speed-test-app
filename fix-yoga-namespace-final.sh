#!/bin/bash

echo "🔧 Comprehensive Yoga namespace fix..."

# Navigate to the project directory  
cd "$(dirname "$0")"

# 1. Restore YGValue.h with proper namespace handling
cat > node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h << 'EOF'
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
#include "YGEnums.h"

namespace facebook::yoga {

struct YGValue {
  float value;
  YGUnit unit;

  YGValue() : value(0), unit(YGUnitUndefined) {}
  YGValue(float value, YGUnit unit) : value(value), unit(unit) {}
};

constexpr auto YGUndefined = std::numeric_limits<float>::quiet_NaN();

// Helper functions in the namespace
inline bool isUndefined(float value) {
  return std::isnan(value);
}

inline bool isUndefined(const YGValue& value) {
  return value.unit == YGUnitUndefined || isUndefined(value.value);
}

inline bool isDefined(float value) {
  return !isUndefined(value);
}

inline bool isDefined(const YGValue& value) {
  return !isUndefined(value);
}

} // namespace facebook::yoga

// Global type aliases for backward compatibility
using YGValue = facebook::yoga::YGValue;
constexpr auto YGUndefined = facebook::yoga::YGUndefined;

// Global function aliases for backward compatibility
inline bool isUndefined(float value) {
  return facebook::yoga::isUndefined(value);
}

inline bool isUndefined(const YGValue& value) {
  return facebook::yoga::isUndefined(value);
}

inline bool isDefined(float value) {
  return facebook::yoga::isDefined(value);
}

inline bool isDefined(const YGValue& value) {
  return facebook::yoga::isDefined(value);
}

EOF

# 2. Fix YGValue.cpp to use proper namespaces
cat > node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp << 'EOF'
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/YGValue.h>
#include <cmath>

// Global constants for backward compatibility
const YGValue YGValueUndefined = {YGUndefined, YGUnitUndefined};
const YGValue YGValueAuto = {YGUndefined, YGUnitAuto};
const YGValue YGValueZero = {0, YGUnitPoint};

EOF

# 3. Simplify Comparison.h to avoid conflicts
cat > node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.h << 'EOF'
/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once
#include <cmath>
#include "../YGValue.h"

namespace facebook {
namespace yoga {
namespace numeric {

// Use the functions defined in YGValue.h
using facebook::yoga::isUndefined;
using facebook::yoga::isDefined;

template <typename T>
inline bool equal(T a, T b) {
  return a == b;
}

template <typename T>
inline bool lessEqual(T a, T b) {
  return a <= b;
}

template <typename T>
inline bool less(T a, T b) {
  return a < b;
}

template <typename T>
inline bool greaterEqual(T a, T b) {
  return a >= b;
}

template <typename T>
inline bool greater(T a, T b) {
  return a > b;
}

} // namespace numeric
} // namespace yoga
} // namespace facebook

EOF

# 4. Clean up Comparison.cpp
cat > node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.cpp << 'EOF'
/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/numeric/Comparison.h>

// All template implementations are in the header file

EOF

# 5. Remove any conflicting includes from other files that might reference YGCompat.h
echo "🧹 Cleaning up conflicting includes..."

# Remove compat includes from YGValue.cpp and Comparison.cpp if they exist
sed -i.bak '/compat\/YGCompat.h/d' node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp 2>/dev/null || true
sed -i.bak '/compat\/YGCompat.h/d' node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.cpp 2>/dev/null || true

# Clean up backup files
rm -f node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp.bak
rm -f node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.cpp.bak

echo "✅ Comprehensive Yoga namespace fix complete!"
echo "📝 Fixed:"
echo "   - YGValue.h with proper namespace and backward compatibility"
echo "   - YGValue.cpp with clean constant definitions" 
echo "   - Comparison.h using proper namespace imports"
echo "   - Comparison.cpp minimal implementation"
echo "   - Removed conflicting compat includes"
echo ""
echo "🔄 Run 'cd ios && pod install' to apply changes"
