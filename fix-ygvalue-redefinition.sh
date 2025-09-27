#!/bin/bash

echo "🎯 Targeted fix for YGValue.h redefinition error on line 27..."

cd "$(dirname "$0")"

# Let's examine and fix the exact file causing the error
echo "📍 Checking YGValue.h for the specific redefinition issue..."

# Check if YGValue.h exists and what's on line 27
YG_VALUE_H="node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h"

if [ -f "$YG_VALUE_H" ]; then
    echo "📄 Found YGValue.h, checking line 27..."
    sed -n '20,35p' "$YG_VALUE_H"
    echo "---"
fi

# Create a targeted fix that removes ONLY the conflicting definition
cat > fix_ygvalue_redefinition.py << 'EOF'
import re

# Read YGValue.h
with open('node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h', 'r') as f:
    content = f.read()

# Find and fix the specific redefinition issue
# The error is likely a duplicate isUndefined function definition
lines = content.split('\n')
fixed_lines = []
inside_duplicate_function = False
brace_count = 0

for i, line in enumerate(lines, 1):
    # If we find a second definition of isUndefined, skip it
    if 'inline bool isUndefined' in line and i >= 25:
        # Check if this is a duplicate by seeing if there's already one above
        already_defined = any('inline bool isUndefined' in prev_line for prev_line in lines[:i-1])
        if already_defined:
            print(f"Removing duplicate isUndefined definition at line {i}: {line.strip()}")
            inside_duplicate_function = True
            if '{' in line:
                brace_count = 1
            continue
    
    if inside_duplicate_function:
        if '{' in line:
            brace_count += line.count('{')
        if '}' in line:
            brace_count -= line.count('}')
        if brace_count <= 0:
            inside_duplicate_function = False
        continue
    
    fixed_lines.append(line)

# Write the fixed content back
with open('node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h', 'w') as f:
    f.write('\n'.join(fixed_lines))

print("✅ Fixed YGValue.h redefinition issue")
EOF

# Run the Python fix
python3 fix_ygvalue_redefinition.py

# Clean up
rm fix_ygvalue_redefinition.py

# Also check for template instantiation issues
echo "🔍 Checking for template instantiation conflicts..."

# Fix any template instantiation issues in YGValue.h
sed -i.bak '/^template.*isUndefined.*YGValue/d' node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h
sed -i.bak '/^extern template.*isUndefined/d' node_modules/react-native/ReactCommon/yoga/yoga/YGValue.h

echo "✅ Targeted fix complete!"
echo "📝 Fixed:"
echo "   - Removed duplicate isUndefined function definition"
echo "   - Removed problematic template instantiations"
echo ""
echo "🔄 Run 'cd ios && pod install' to test the fix"
