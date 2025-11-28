#!/bin/bash

# CRDT Framework Validation Test Suite
# Runs all verified CRDT semilattice adapters
# Updated to use actual adapter files instead of missing test files

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  CRDT Framework Validation Suite"
echo "  (Specifications & Demos Verification)"
echo "=========================================="
echo ""

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_file=$1
    local test_name=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Running: $test_name ... "
    
    if timeout 60 ./athena-run "$test_file" > /tmp/athena_test_output.log 2>&1; then
        # Check if there were any errors in output
        if grep -q "Error:" /tmp/athena_test_output.log; then
            echo -e "${RED}FAILED${NC}"
            echo "  Error details:"
            grep "Error:" /tmp/athena_test_output.log | head -3
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        else
            echo -e "${GREEN}PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        fi
    else
        local exit_code=$?
        echo -e "${RED}FAILED${NC}"
        if [ $exit_code -eq 124 ]; then
            echo "  TIMEOUT (60s exceeded)"
        else
            echo "  Exit code: $exit_code"
        fi
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

echo "=== State-Based CRDT Specifications ==="
echo ""

run_test "src/crdts/gcounter_specification.ath" "GCounter Specification"
echo ""

run_test "src/crdts/gset_specification.ath" "G-Set Specification"
echo ""

run_test "src/crdts/pncounter_specification.ath" "PN-Counter Specification"
echo ""

run_test "src/crdts/twophase_set_specification.ath" "Two-Phase Set Specification"
echo ""

run_test "src/crdts/lww_register_specification.ath" "LWW-Register Specification"
echo ""

echo "=== CRDT Unified Demos ==="
echo ""

run_test "src/demos/gcounter_unified_demo.ath" "GCounter Demo"
echo ""

run_test "src/demos/gset_unified_demo.ath" "G-Set Demo"
echo ""

run_test "src/demos/pncounter_unified_demo.ath" "PN-Counter Demo"
echo ""

run_test "src/demos/twophase_set_unified_demo.ath" "Two-Phase Set Demo"
echo ""

run_test "src/demos/lww_register_unified_demo.ath" "LWW-Register Demo"
echo ""

echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""
echo "Total Tests:  $TOTAL_TESTS"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"
else
    echo -e "Failed:       $FAILED_TESTS"
fi
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Framework validation complete."
    echo "All 5 state-based CRDTs are verified:"
    echo "  ✓ GCounter (Natural number max semilattice)"
    echo "  ✓ G-Set (Set union semilattice)"
    echo "  ✓ PN-Counter (Product of two GCounters)"
    echo "  ✓ Two-Phase Set (Product of two G-Sets)"
    echo "  ✓ LWW-Register (Vector clock-based convergence)"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    echo ""
    echo "Check /tmp/athena_test_output.log for details."
    exit 1
fi
