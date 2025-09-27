#!/bin/bash

echo "🔧 Fixing Yoga template conflicts..."

# Navigate to the project directory
cd "$(dirname "$0")"

# 1. Fix YGValue.h to avoid redefinition conflicts
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

} // namespace facebook::yoga

EOF

# 2. Fix Comparison.h to properly handle template declarations
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

// General template declaration
template <typename T>
bool isUndefined(T value);

// Specialized implementations
template <>
inline bool isUndefined(float value) {
  return std::isnan(value);
}

template <>
inline bool isUndefined(YGValue value) {
  return value.unit == YGUnitUndefined || isUndefined(value.value);
}

template <typename T>
inline bool isDefined(T value) {
  return !isUndefined(value);
}

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

# 3. Update Comparison.cpp to match the header
cat > node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.cpp << 'EOF'
/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/numeric/Comparison.h>
#include <yoga/YGValue.h>
#include <cmath>

// Template specializations are defined in the header file as inline functions
// This file can remain minimal as the implementations are in the header

EOF

# 4. Update YGValue.cpp to remove conflicting definitions
cat > node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp << 'EOF'
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/YGValue.h>
#include <yoga/numeric/Comparison.h>
#include <cmath>

// YGValue constants - defined in global scope for backward compatibility
const YGValue YGValueUndefined = {facebook::yoga::YGUndefined, YGUnitUndefined};
const YGValue YGValueAuto = {facebook::yoga::YGUndefined, YGUnitAuto};
const YGValue YGValueZero = {0, YGUnitPoint};

EOF

# 5. Create a compatibility header for any remaining issues
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/compat
cat > node_modules/react-native/ReactCommon/yoga/yoga/compat/YGCompat.h << 'EOF'
/*
 * Yoga Compatibility Header for C++20
 * Resolves namespace and template conflicts
 */

#pragma once

#include <yoga/YGEnums.h>
#include <cmath>

// Forward declarations to avoid circular dependencies
namespace facebook {
namespace yoga {
struct YGValue;
namespace numeric {
template <typename T> bool isUndefined(T value);
template <typename T> bool isDefined(T value);
}
}
}

// Global aliases for backward compatibility
using facebook::yoga::YGValue;
using facebook::yoga::numeric::isUndefined;
using facebook::yoga::numeric::isDefined;

EOF

echo "✅ Yoga template conflicts fixed!"
echo "📝 Files updated:"
echo "   - YGValue.h (removed conflicting inline functions)"
echo "   - Comparison.h (proper template specializations)"
echo "   - Comparison.cpp (minimal implementation)"
echo "   - YGValue.cpp (clean constant definitions)"
echo "   - YGCompat.h (compatibility layer)"
echo ""
echo "🔄 Run 'cd ios && pod install' to apply changes"
