#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Create the missing directory structure
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/numeric

# Create the missing header file
cat << 'EOF' > node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.h
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

template <typename T>
bool isUndefined(T value);

// Explicit template specialization declarations
template <>
bool isUndefined(float value);

template <>
bool isUndefined(YGValue value);

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

echo "Missing header file created successfully."

# Create an implementation file for Comparison.cpp
cat << 'EOF' > node_modules/react-native/ReactCommon/yoga/yoga/numeric/Comparison.cpp
/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/numeric/Comparison.h>
#include <yoga/YGValue.h>
#include <cmath>

namespace facebook {
namespace yoga {
namespace numeric {

template <>
bool isUndefined(float value) {
  return std::isnan(value);
}

template <>
bool isUndefined(YGValue value) {
  return value.unit == YGUnitUndefined;
}

} // namespace numeric
} // namespace yoga
} // namespace facebook
EOF

echo "Created implementation file for numeric comparisons."

# Create a fixed version of YGValue.cpp
cat << 'EOF' > node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp.fixed
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <yoga/YGValue.h>
#include <yoga/numeric/Comparison.h>
#include <cmath>

// YGValue constants - defined outside of any namespace
const YGValue YGValueUndefined = {YGUndefined, YGUnitUndefined};
const YGValue YGValueAuto = {YGUndefined, YGUnitAuto};
const YGValue YGValueZero = {0, YGUnitPoint};

// Need to make YGValue visible in the facebook::yoga::numeric namespace
namespace facebook {
namespace yoga {
namespace numeric {

// Use the struct definition from the global scope
using ::YGValue;

// Template specializations
template <>
bool isUndefined(float value) {
  return std::isnan(value);
}

template <>
bool isUndefined(YGValue value) {
  return value.unit == YGUnitUndefined;
}

} // namespace numeric
} // namespace yoga
} // namespace facebook
EOF

# Backup the original file and replace it with the fixed version
cp node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp.backup
cp node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp.fixed node_modules/react-native/ReactCommon/yoga/yoga/YGValue.cpp

echo "Fixed YGValue.cpp with proper template specializations."

# Fix permissions for Hermes frameworks
sudo chmod -R 777 ~/Library/Developer/Xcode/DerivedData/InternetSpeedTestApp-*/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/hermes-engine

echo "Permissions fixed for Hermes framework."

# Explicitly set build directory permissions
sudo chmod -R 777 ~/Library/Developer/Xcode/DerivedData/InternetSpeedTestApp-*

echo "All permissions fixed."
