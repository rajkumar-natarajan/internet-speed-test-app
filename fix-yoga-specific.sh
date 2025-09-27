#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Create the directory structure for our helper
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/helpers

# Create a helper file with the necessary functions
cat << 'EOF' > node_modules/react-native/ReactCommon/yoga/yoga/helpers/YogaHelpers.h
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

// Helper functions in the facebook::yoga namespace
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

echo "Created YogaHelpers.h in node_modules/react-native/ReactCommon/yoga/yoga/helpers/"

# Create patches for specific files

# 1. Fix CachedMeasurement.h
cat << 'EOF' > ios/Pods/Headers/Private/Yoga/yoga/node/CachedMeasurement.h.fixed
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <cmath>
#include <yoga/YGMacros.h>
#include <yoga/enums/Dimension.h>
#include <yoga/enums/MeasureMode.h>

// Include our helper functions
#include <yoga/helpers/YogaHelpers.h>

namespace facebook {
namespace yoga {

struct CachedMeasurement {
  float availableWidth{NAN};
  float availableHeight{NAN};
  MeasureMode widthSizingMode{MeasureMode::MaxContent};
  MeasureMode heightSizingMode{MeasureMode::MaxContent};
  float computedWidth{-1};
  float computedHeight{-1};

  bool operator==(CachedMeasurement measurement) const {
    bool isEqual = widthSizingMode == measurement.widthSizingMode &&
        heightSizingMode == measurement.heightSizingMode;

    if (!yoga::isUndefined(availableWidth) ||
        !yoga::isUndefined(measurement.availableWidth)) {
      isEqual = isEqual && availableWidth == measurement.availableWidth;
    }
    if (!yoga::isUndefined(availableHeight) ||
        !yoga::isUndefined(measurement.availableHeight)) {
      isEqual = isEqual && availableHeight == measurement.availableHeight;
    }
    if (!yoga::isUndefined(computedWidth) ||
        !yoga::isUndefined(measurement.computedWidth)) {
      isEqual = isEqual && computedWidth == measurement.computedWidth;
    }
    if (!yoga::isUndefined(computedHeight) ||
        !yoga::isUndefined(measurement.computedHeight)) {
      isEqual = isEqual && computedHeight == measurement.computedHeight;
    }

    return isEqual;
  }

  bool operator!=(CachedMeasurement measurement) const {
    return !(*this == measurement);
  }
};

} // namespace yoga
} // namespace facebook
EOF

# 2. Fix FloatOptional.h
cat << 'EOF' > ios/Pods/Headers/Private/Yoga/yoga/numeric/FloatOptional.h.fixed
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <cmath>
#include <limits>
#include <yoga/YGMacros.h>

// Include our helper functions
#include <yoga/helpers/YogaHelpers.h>

namespace facebook {
namespace yoga {

class FloatOptional {
 private:
  float value_ = std::numeric_limits<float>::quiet_NaN();

 public:
  explicit constexpr FloatOptional(float value) : value_(value) {}

  constexpr FloatOptional() = default;

  constexpr float unwrap() const {
    return value_;
  }

  constexpr float unwrapOrDefault(float defaultValue) const {
    return isUndefined() ? defaultValue : value_;
  }

  constexpr bool isUndefined() const {
    return yoga::isUndefined(value_);
  }

  constexpr bool isDefined() const {
    return yoga::isDefined(value_);
  }
};

template <typename T>
constexpr T max(T a, T b) {
  return a > b ? a : b;
}

template <typename T>
constexpr T min(T a, T b) {
  return a < b ? a : b;
}

constexpr FloatOptional maxOrDefined(FloatOptional a, FloatOptional b) {
  return a.isDefined() && b.isDefined() ? FloatOptional(max(a.unwrap(), b.unwrap()))
                             : (a.isDefined() ? a : b);
}

constexpr FloatOptional minOrDefined(FloatOptional a, FloatOptional b) {
  return a.isDefined() && b.isDefined() ? FloatOptional(min(a.unwrap(), b.unwrap()))
                             : (a.isDefined() ? a : b);
}

// operators
constexpr bool operator==(FloatOptional lhs, FloatOptional rhs) {
  return (lhs.isUndefined() && rhs.isUndefined()) ||
         (!lhs.isUndefined() && !rhs.isUndefined() &&
          lhs.unwrap() == rhs.unwrap());
}

constexpr bool operator!=(FloatOptional lhs, FloatOptional rhs) {
  return !(lhs == rhs);
}

constexpr FloatOptional operator+(FloatOptional lhs, FloatOptional rhs) {
  return lhs.isUndefined() || rhs.isUndefined()
      ? FloatOptional{}
      : FloatOptional{lhs.unwrap() + rhs.unwrap()};
}

constexpr FloatOptional operator-(FloatOptional lhs, FloatOptional rhs) {
  return lhs.isUndefined() || rhs.isUndefined()
      ? FloatOptional{}
      : FloatOptional{lhs.unwrap() - rhs.unwrap()};
}
EOF

# 3. Fix StyleLength.h
cat << 'EOF' > ios/Pods/Headers/Private/Yoga/yoga/style/StyleLength.h.fixed
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <array>
#include <cmath>
#include <yoga/YGEnums.h>
#include <yoga/YGMacros.h>
#include <yoga/numeric/FloatOptional.h>

// Include our helper functions
#include <yoga/helpers/YogaHelpers.h>

namespace facebook {
namespace yoga {

/**
 * Represents a style length in yoga. This may be specified by a user or
 * calculated during layout.
 *
 * See:
 * 1. https://www.w3.org/TR/css-values-4/#lengths
 * 2. https://www.w3.org/TR/css-values-4/#percentage-value
 * 3. https://www.w3.org/TR/css-values-4/#mixed-percentages
 */
class StyleLength {
 public:
  constexpr StyleLength() = default;

  constexpr static StyleLength points(float value) {
    return yoga::isUndefined(value) || yoga::isinf(value)
        ? undefined()
        : StyleLength{FloatOptional{value}, Unit::Point};
  }

  constexpr static StyleLength percent(float value) {
    return yoga::isUndefined(value) || yoga::isinf(value)
        ? undefined()
        : StyleLength{FloatOptional{value}, Unit::Percent};
  }

  constexpr static StyleLength auto_() {
    return StyleLength{FloatOptional{}, Unit::Auto};
  }

  constexpr static StyleLength undefined() {
    return StyleLength{FloatOptional{}, Unit::Undefined};
  }

  constexpr bool operator==(const StyleLength& other) const {
    return unit_ == other.unit_ && value_ == other.value_;
  }

  constexpr bool operator!=(const StyleLength& other) const {
    return !(*this == other);
  }

  constexpr Unit getUnit() const {
    return unit_;
  }

  constexpr bool isUndefined() const {
    return unit_ == Unit::Undefined;
  }

  constexpr bool isDefined() const {
    return !isUndefined();
  }

  constexpr bool isAuto() const {
    return unit_ == Unit::Auto;
  }

  constexpr bool hasUnit(Unit unit) const {
    return unit_ == unit && value_.isDefined();
  }

  constexpr bool isPercent() const {
    return hasUnit(Unit::Percent);
  }

  constexpr bool isPoints() const {
    return hasUnit(Unit::Point);
  }

  constexpr FloatOptional getValue() const {
    return value_;
  }

 private:
  constexpr StyleLength(FloatOptional value, Unit unit)
      : value_(value), unit_(unit) {}

  FloatOptional value_{};
  Unit unit_ = Unit::Undefined;
};

} // namespace yoga
} // namespace facebook
EOF

# 4. Fix StyleSizeLength.h
cat << 'EOF' > ios/Pods/Headers/Private/Yoga/yoga/style/StyleSizeLength.h.fixed
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <cmath>
#include <yoga/YGMacros.h>
#include <yoga/style/StyleLength.h>

// Include our helper functions
#include <yoga/helpers/YogaHelpers.h>

namespace facebook {
namespace yoga {

/**
 * A size length for width or height styling. This implements all of
 * StyleLength, but adds Fit-Content and Max-Content.
 */
class StyleSizeLength {
 public:
  constexpr StyleSizeLength() = default;

  constexpr static StyleSizeLength points(float value) {
    return yoga::isUndefined(value) || yoga::isinf(value)
        ? undefined()
        : fromLength(StyleLength::points(value));
  }

  constexpr static StyleSizeLength percent(float value) {
    return yoga::isUndefined(value) || yoga::isinf(value)
        ? undefined()
        : fromLength(StyleLength::percent(value));
  }

  constexpr static StyleSizeLength auto_() {
    return fromLength(StyleLength::auto_());
  }

  constexpr static StyleSizeLength fitContent() {
    StyleSizeLength result{};
    result.unit_ = Unit::FitContent;
    return result;
  }

  constexpr static StyleSizeLength maxContent() {
    StyleSizeLength result{};
    result.unit_ = Unit::MaxContent;
    return result;
  }

  constexpr static StyleSizeLength stretch() {
    StyleSizeLength result{};
    result.unit_ = Unit::Stretch;
    return result;
  }

  constexpr static StyleSizeLength undefined() {
    StyleSizeLength result{};
    result.unit_ = Unit::Undefined;
    return result;
  }

  constexpr static StyleSizeLength fromLength(const StyleLength& styleLength) {
    StyleSizeLength result{};
    result.length_ = styleLength;
    result.unit_ = styleLength.getUnit();
    return result;
  }

  constexpr bool operator==(const StyleSizeLength& other) const {
    return unit_ == other.unit_ && length_ == other.length_;
  }

  constexpr bool operator!=(const StyleSizeLength& other) const {
    return !(*this == other);
  }

  constexpr Unit getUnit() const {
    return unit_;
  }

  constexpr bool isUndefined() const {
    return unit_ == Unit::Undefined;
  }

  constexpr bool isDefined() const {
    return !isUndefined();
  }

  constexpr bool isAuto() const {
    return unit_ == Unit::Auto;
  }

  constexpr bool isStretch() const {
    return unit_ == Unit::Stretch;
  }

  constexpr bool isFitContent() const {
    return unit_ == Unit::FitContent;
  }

  constexpr bool isMaxContent() const {
    return unit_ == Unit::MaxContent;
  }

  constexpr bool hasUnit(Unit unit) const {
    return unit_ == unit && length_.isDefined();
  }

  constexpr bool isPercent() const {
    return hasUnit(Unit::Percent);
  }

  constexpr bool isPoints() const {
    return hasUnit(Unit::Point);
  }

  constexpr FloatOptional getValue() const {
    return length_.getValue();
  }

  constexpr StyleLength toLength() const {
    if (isUndefined()) {
      return StyleLength::undefined();
    }
    if (isAuto()) {
      return StyleLength::auto_();
    }
    if (isPercent()) {
      return StyleLength::percent(getValue().unwrap());
    }
    if (isPoints()) {
      return StyleLength::points(getValue().unwrap());
    }
    return StyleLength::undefined();
  }

 private:
  StyleLength length_{};
  Unit unit_ = Unit::Undefined;
};

} // namespace yoga
} // namespace facebook
EOF

# Now copy the fixed files to their proper locations
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/node
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/numeric
mkdir -p node_modules/react-native/ReactCommon/yoga/yoga/style

# Copy the fixed files to the node_modules directory
cp ios/Pods/Headers/Private/Yoga/yoga/node/CachedMeasurement.h.fixed node_modules/react-native/ReactCommon/yoga/yoga/node/CachedMeasurement.h
cp ios/Pods/Headers/Private/Yoga/yoga/numeric/FloatOptional.h.fixed node_modules/react-native/ReactCommon/yoga/yoga/numeric/FloatOptional.h
cp ios/Pods/Headers/Private/Yoga/yoga/style/StyleLength.h.fixed node_modules/react-native/ReactCommon/yoga/yoga/style/StyleLength.h
cp ios/Pods/Headers/Private/Yoga/yoga/style/StyleSizeLength.h.fixed node_modules/react-native/ReactCommon/yoga/yoga/style/StyleSizeLength.h

# Create the directories in the Pods directory
mkdir -p ios/Pods/Headers/Private/Yoga/yoga/helpers

# Copy the helper to the Pods directory
cp node_modules/react-native/ReactCommon/yoga/yoga/helpers/YogaHelpers.h ios/Pods/Headers/Private/Yoga/yoga/helpers/

echo "Fixed all Yoga namespace issues with helper includes."
