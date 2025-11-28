#!/usr/bin/env bash
# Proof Validation Suite
# Tests all completed proofs to ensure they load and execute correctly

set -e  # Exit on first error

ATHENA_BIN="./athena-run"
PROOF_DIR="src/framework"

echo "======================================"
echo "Athena CRDT Proof Validation Suite"
echo "======================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_file="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Testing: $test_name ... "
    
    if $ATHENA_BIN "$test_file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  Error details:"
        $ATHENA_BIN "$test_file" 2>&1 | head -20 | sed 's/^/    /'
    fi
}

# Function to check if file exists
check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File not found: $file${NC}"
        exit 1
    fi
}

echo "Phase 1: Validating Core Framework Files"
echo "------------------------------------------"

# Test 1: Vector Clocks
check_file "$PROOF_DIR/vector_clocks.ath"
run_test "Vector Clocks" "$PROOF_DIR/vector_clocks.ath"

# Test 2: Vector Clock Properties
check_file "$PROOF_DIR/vector_clock_properties.ath"
run_test "Vector Clock Properties" "$PROOF_DIR/vector_clock_properties.ath"

# Test 3: Map Lemmas
check_file "$PROOF_DIR/map_lemmas.ath"
run_test "Map Lemmas" "$PROOF_DIR/map_lemmas.ath"

# Test 4: Natural Number Max
check_file "$PROOF_DIR/nat-max.ath"
run_test "Natural Number Max" "$PROOF_DIR/nat-max.ath"

# Test 5: Payload Framework
check_file "$PROOF_DIR/payload.ath"
run_test "Payload Framework" "$PROOF_DIR/payload.ath"

# Test 6: Backbone Framework
check_file "$PROOF_DIR/backbone.ath"
run_test "Backbone Framework" "$PROOF_DIR/backbone.ath"

echo "Phase 2: Validating Semilattice Theory"
echo "---------------------------------------"

# Test 7: Semilattice Theory
check_file "$PROOF_DIR/theory/semilattice_theory.ath"
run_test "Semilattice Theory" "$PROOF_DIR/theory/semilattice_theory.ath"

echo "Phase 3: Validating CRDT Specifications"
echo "----------------------------------------"

CRDT_DIR="src/crdts"

# Test 8: GCounter Specification
check_file "$CRDT_DIR/gcounter/gcounter_specification.ath"
run_test "GCounter Specification" "$CRDT_DIR/gcounter/gcounter_specification.ath"

# Test 9: G-Set Specification
check_file "$CRDT_DIR/gset/gset_specification.ath"
run_test "G-Set Specification" "$CRDT_DIR/gset/gset_specification.ath"

# Test 10: PN-Counter Specification
check_file "$CRDT_DIR/pncounter/pncounter_specification.ath"
run_test "PN-Counter Specification" "$CRDT_DIR/pncounter/pncounter_specification.ath"

# Test 11: Two-Phase Set Specification
check_file "$CRDT_DIR/twophase_set/twophase_set_specification.ath"
run_test "Two-Phase Set Specification" "$CRDT_DIR/twophase_set/twophase_set_specification.ath"

# Test 12: LWW-Register Specification
check_file "$CRDT_DIR/lww_register/lww_register_specification.ath"
run_test "LWW-Register Specification" "$CRDT_DIR/lww_register/lww_register_specification.ath"

echo ""
echo "======================================"
echo "Validation Results"
echo "======================================"
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
else
    echo -e "Tests failed: $TESTS_FAILED"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All proofs validated successfully! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some proofs failed validation. See errors above.${NC}"
    exit 1
fi

