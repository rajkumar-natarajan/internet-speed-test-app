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
