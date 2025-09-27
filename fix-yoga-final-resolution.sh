#!/bin/bash

echo "🔧 Final Yoga conflict resolution..."

cd "$(dirname "$0")"

# 1. Clean up YGMacros.h - restore original without our conflicting functions
cat > node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h << 'EOF'
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#ifdef __cplusplus
#include <cmath>
#define YG_EXTERN_C_BEGIN extern "C" {
#define YG_EXTERN_C_END }
#else
#define YG_EXTERN_C_BEGIN
#define YG_EXTERN_C_END
#endif

#ifdef _WINDLL
#define YG_EXPORT __declspec(dllexport)
#elif defined(_WIN32)
#define YG_EXPORT __declspec(dllimport)
#else
#define YG_EXPORT
#endif

#ifdef NS_ENUM
// Cannot use NSInteger as NSInteger has a different size than int (which is the
// default size of an enum).
#define YG_ENUM_BEGIN(name) NS_ENUM(int, name)
#define YG_ENUM_END(name)
#else
#define YG_ENUM_BEGIN(name) enum name
#define YG_ENUM_END(name) name
#endif

EOF

# 2. Fix YGValue.h to be the single source of truth for isUndefined functions
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

// Helper functions - the single source of truth
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

// Global aliases for backward compatibility - only if not already defined
#ifndef YOGA_GLOBAL_ALIASES_DEFINED
#define YOGA_GLOBAL_ALIASES_DEFINED

using YGValue = facebook::yoga::YGValue;
constexpr auto YGUndefined = facebook::yoga::YGUndefined;

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

#endif // YOGA_GLOBAL_ALIASES_DEFINED

EOF

# 3. Clean up YGValue.cpp
cat > node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp << 'EOF'
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/YGValue.h>

// Global constants for backward compatibility
const YGValue YGValueUndefined = {YGUndefined, YGUnitUndefined};
const YGValue YGValueAuto = {YGUndefined, YGUnitAuto};
const YGValue YGValueZero = {0, YGUnitPoint};

EOF

# 4. Clean up Comparison.h to use YGValue functions
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

// Import functions from parent namespace to avoid redefinition
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

# 5. Clean up Comparison.cpp
cat > node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.cpp << 'EOF'
/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/numeric/Comparison.h>

// All implementations are in the header

EOF

# 6. Remove any stray YogaHelpers.h files that might conflict
echo "🧹 Removing conflicting helper files..."
find ios/Pods -name "YogaHelpers.h" -delete 2>/dev/null || true
rm -rf node_modules/react-native/ReactCommon/yoga/yoga/helpers 2>/dev/null || true
rm -rf node_modules/react-native/ReactCommon/yoga/yoga/compat 2>/dev/null || true

echo "✅ Final Yoga conflict resolution complete!"
echo "📝 Actions taken:"
echo "   - Restored clean YGMacros.h without conflicting functions"
echo "   - Made YGValue.h the single source of truth for isUndefined/isDefined"
echo "   - Added include guards to prevent redefinition"
echo "   - Fixed Comparison.h to use proper namespace imports"
echo "   - Removed all conflicting helper files"
echo ""
echo "🔄 Run 'cd ios && pod install' to apply changes"
