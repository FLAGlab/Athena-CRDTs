#!/bin/bash

# Comprehensive testing script for all CRDT framework, demos, specs, and tests

ATHENA_RUN="./athena-run"
TIMEOUT=30

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Categories
declare -A results

# Function to test a file
test_file() {
    local file=$1
    local category=$2
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ MISSING${NC} $file"
        results["$category-missing"]=$((${results["$category-missing"]:-0} + 1))
        return 2
    fi
    
    # Run with timeout and capture stderr
    timeout $TIMEOUT "$ATHENA_RUN" "$file" > /tmp/athena_out.log 2>&1
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}⏱ TIMEOUT${NC} $file"
        results["$category-timeout"]=$((${results["$category-timeout"]:-0} + 1))
        return 1
    elif [ $exit_code -ne 0 ]; then
        # Extract error message
        local error=$(grep -i "error" /tmp/athena_out.log | head -1)
        echo -e "${RED}✗ FAIL${NC}    $file"
        if [ ! -z "$error" ]; then
            echo "          $error"
        fi
        results["$category-fail"]=$((${results["$category-fail"]:-0} + 1))
        return 1
    else
        echo -e "${GREEN}✓ PASS${NC}    $file"
        results["$category-pass"]=$((${results["$category-pass"]:-0} + 1))
        return 0
    fi
}

# Create temporary directory for logs
mkdir -p /tmp/athena_test_logs

cd /home/leo/Documents/Athena-CRDTs

echo "============================================"
echo "TESTING FRAMEWORK FILES"
echo "============================================"
framework_files=(
    "src/framework/nat-max.ath"
    "src/framework/map_lemmas.ath"
    "src/framework/vector_clocks.ath"
    "src/framework/vector_clock_properties.ath"
    "src/framework/crdt_specification.ath"
    "src/framework/payload.ath"
    "src/framework/backbone.ath"
    "src/framework/unified_backbone.ath"
    "src/framework/unified_payload.ath"
)

for file in "${framework_files[@]}"; do
    test_file "$file" "framework"
done

echo ""
echo "============================================"
echo "TESTING CRDT SPECIFICATIONS"
echo "============================================"
crdt_specs=(
    "src/crdts/gcounter_specification.ath"
    "src/crdts/gset_specification.ath"
    "src/crdts/twophase_set_specification.ath"
    "src/crdts/pncounter_specification.ath"
    "src/crdts/lww_register_specification.ath"
)

for file in "${crdt_specs[@]}"; do
    test_file "$file" "spec"
done

echo ""
echo "============================================"
echo "TESTING CRDT PAYLOAD ADAPTERS"
echo "============================================"
payload_adapters=(
    "src/crdts/gcounter_payload_adapter.ath"
    "src/crdts/gset_payload_adapter.ath"
    "src/crdts/twophase_set_payload_adapter.ath"
    "src/crdts/pncounter_payload_adapter.ath"
    "src/crdts/lww_register_payload_adapter.ath"
)

for file in "${payload_adapters[@]}"; do
    test_file "$file" "adapter"
done

echo ""
echo "============================================"
echo "TESTING DEMOS"
echo "============================================"
demo_files=(
    "src/demos/gcounter_unified_demo.ath"
    "src/demos/gset_unified_demo.ath"
    "src/demos/twophase_set_unified_demo.ath"
    "src/demos/pncounter_unified_demo.ath"
    "src/demos/lww_register_simple_demo.ath"
    "src/demos/lww_register_unified_demo.ath"
)

for file in "${demo_files[@]}"; do
    test_file "$file" "demo"
done

echo ""
echo "============================================"
echo "TESTING DEMO TESTS (tests/ subdirectory)"
echo "============================================"
demo_tests=(
    "src/demos/tests/backbone_reduce_test.ath"
    "src/demos/tests/gset_reduce_test.ath"
    "src/demos/tests/simple_check_test.ath"
    "src/demos/tests/pattern_check_test.ath"
    "src/demos/tests/equality_test.ath"
)

for file in "${demo_tests[@]}"; do
    test_file "$file" "demo-test"
done

echo ""
echo "============================================"
echo "TESTING DEBUG FILES"
echo "============================================"
debug_files=(
    "src/demos/debug/ultra_minimal_test.ath"
    "src/demos/debug/test_payload_eval.ath"
    "src/demos/debug/debug_insert_verbose.ath"
    "src/demos/debug/debug_registry_insert.ath"
)

for file in "${debug_files[@]}"; do
    test_file "$file" "debug"
done

echo ""
echo "============================================"
echo "TESTING UTILITIES"
echo "============================================"
util_files=(
    "src/utils/fmaps.ath"
    "src/utils/pair.ath"
    "src/utils/list-util.ath"
    "src/utils/set-util.ath"
    "src/utils/common.ath"
)

for file in "${util_files[@]}"; do
    test_file "$file" "util"
done

echo ""
echo "============================================"
echo "SUMMARY"
echo "============================================"

total_pass=0
total_fail=0
total_timeout=0
total_missing=0

for key in "${!results[@]}"; do
    count=${results[$key]}
    if [[ $key == *"-pass" ]]; then
        category=${key%-pass}
        total_pass=$((total_pass + count))
        echo -e "${GREEN}✓${NC} $category PASS: $count"
    elif [[ $key == *"-fail" ]]; then
        category=${key%-fail}
        total_fail=$((total_fail + count))
        echo -e "${RED}✗${NC} $category FAIL: $count"
    elif [[ $key == *"-timeout" ]]; then
        category=${key%-timeout}
        total_timeout=$((total_timeout + count))
        echo -e "${YELLOW}⏱${NC} $category TIMEOUT: $count"
    elif [[ $key == *"-missing" ]]; then
        category=${key%-missing}
        total_missing=$((total_missing + count))
        echo -e "${YELLOW}?${NC} $category MISSING: $count"
    fi
done

echo ""
echo "TOTAL:"
echo -e "  ${GREEN}Passed:${NC}  $total_pass"
echo -e "  ${RED}Failed:${NC}  $total_fail"
echo -e "  ${YELLOW}Timeout:${NC} $total_timeout"
echo -e "  ${YELLOW}Missing:${NC} $total_missing"

total=$((total_pass + total_fail + total_timeout + total_missing))
echo ""
echo "Success Rate: $total_pass / $total"

# Exit with failure if any tests failed or timed out
if [ $total_fail -gt 0 ] || [ $total_timeout -gt 0 ]; then
    exit 1
fi

exit 0
