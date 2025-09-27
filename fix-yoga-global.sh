#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# 1. Create missing helper functions in YGMacros.h
cat << 'EOF' > node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h.fixed
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

// Define global helper functions to avoid namespace issues
namespace facebook {
namespace yoga {

// Define isUndefined, isDefined, and isinf in the facebook::yoga namespace
inline bool isUndefined(float value) {
  return std::isnan(value);
}

inline bool isDefined(float value) {
  return !std::isnan(value);
}

inline bool isinf(float value) {
  return std::isinf(value);
}

} // namespace yoga
} // namespace facebook

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
// Therefor when transpiled it may cause invalid access to the vector.
#define YG_ENUM_BEGIN(name) NS_ENUM(int, name)
#define YG_ENUM_END(name)
#else
#define YG_ENUM_BEGIN(name) enum name
#define YG_ENUM_END(name) name
#endif

#ifdef __GNUC__
#define YG_DEPRECATED __attribute__((deprecated))
#elif defined(_MSC_VER)
#define YG_DEPRECATED __declspec(deprecated)
#else
#define YG_DEPRECATED
#endif

#if __cplusplus > 201402L
#define YG_FALLTHROUGH [[fallthrough]]
#elif defined(__clang__)
#define YG_FALLTHROUGH [[clang::fallthrough]]
#elif defined(__GNUC__) && __GNUC__ >= 7
#define YG_FALLTHROUGH [[gnu::fallthrough]]
#else
#define YG_FALLTHROUGH
#endif

#define YGAssert(condition, message) // noop
EOF

# Create a symlink directory for the fix
mkdir -p fix-yoga

# 2. Create missing numeric namespace implementation
cat << 'EOF' > fix-yoga/YogaHelpers.h
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once
#include <cmath>
#include <yoga/YGValue.h>

namespace facebook {
namespace yoga {
namespace numeric {

// Forward declarations for template specializations
template <typename T>
bool isUndefined(T value);

template <>
inline bool isUndefined(float value) {
  return std::isnan(value);
}

template <>
inline bool isUndefined(YGValue value) {
  return value.unit == YGUnitUndefined;
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

// Also define these in the facebook::yoga namespace for backward compatibility
inline bool isUndefined(float value) {
  return std::isnan(value);
}

inline bool isDefined(float value) {
  return !std::isnan(value);
}

inline bool isinf(float value) {
  return std::isinf(value);
}

} // namespace yoga
} // namespace facebook
EOF

# 3. Create a patching script that will apply all the fixes
cat << 'EOF' > fix-yoga-includes.sh
#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Create the helper header
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/helpers
cp fix-yoga/YogaHelpers.h node_modules/react-native/ReactCommon/yoga/yoga/helpers/

# Update YGMacros.h with our fixed version
cp node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h.backup
cp node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h.fixed node_modules/react-native/ReactCommon/yoga/yoga/YGMacros.h

# Add include for helpers in all relevant files
for file in $(find node_modules/react-native/ReactCommon/yoga -name "*.cpp" -o -name "*.h"); do
  # Skip our helper file and backup files
  if [[ "$file" == *"YogaHelpers.h"* ]] || [[ "$file" == *".backup"* ]] || [[ "$file" == *".fixed"* ]]; then
    continue
  fi
  
  # Add include for our helpers
  sed -i.bak '/#include <yoga\/YGMacros.h>/a\
#include <yoga/helpers/YogaHelpers.h>' "$file"
  
  # Remove backup file
  rm -f "${file}.bak"
done

# Copy the helpers to the Pods directory
mkdir -p ios/Pods/Headers/Private/Yoga/yoga/helpers
cp fix-yoga/YogaHelpers.h ios/Pods/Headers/Private/Yoga/yoga/helpers/

# Add include for helpers in all Pod header files
for file in $(find ios/Pods/Headers/Private/Yoga -name "*.h"); do
  # Skip our helper file and backup files
  if [[ "$file" == *"YogaHelpers.h"* ]] || [[ "$file" == *".backup"* ]]; then
    continue
  fi
  
  # Add include for our helpers
  sed -i.bak '/#include <yoga\/YGMacros.h>/a\
#include <yoga/helpers/YogaHelpers.h>' "$file"
  
  # Remove backup file
  rm -f "${file}.bak"
done

echo "All Yoga includes have been fixed!"
EOF

chmod +x fix-yoga-includes.sh

echo "Created fix-yoga-includes.sh script to fix all Yoga namespace issues."
echo "Run ./fix-yoga-includes.sh to apply the fixes."
