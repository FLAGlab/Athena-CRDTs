#!/bin/bash
# Unified Framework Demo Validation Script
# Tests all 4 unified CRDT demos to verify framework migration

set -e  # Exit on error

echo "======================================"
echo "Unified Framework Validation"
echo "======================================"
echo ""

DEMOS=(
    "gcounter_unified_demo"
    "gset_unified_demo"
    "pncounter_unified_demo"
    "twophase_set_unified_demo"
)

PASSED=0
FAILED=0

for demo in "${DEMOS[@]}"; do
    echo "Testing: ${demo}.ath"
    echo "--------------------------------------"
    
    if timeout 60 ./athena-run "src/demos/${demo}.ath" 2>&1 | grep -q "Demo completed successfully"; then
        echo "✅ PASSED: ${demo}"
        PASSED=$((PASSED + 1))
    else
        echo "❌ FAILED: ${demo}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
done

echo "======================================"
echo "Summary:"
echo "  Passed: ${PASSED}/${#DEMOS[@]}"
echo "  Failed: ${FAILED}/${#DEMOS[@]}"
echo "======================================"

if [ ${FAILED} -eq 0 ]; then
    echo "✅ All unified demos working!"
    exit 0
else
    echo "❌ Some demos failed"
    exit 1
fi
