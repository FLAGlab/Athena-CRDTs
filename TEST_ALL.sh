#!/bin/bash
# Comprehensive test suite for Athena-CRDTs
# Tests framework, specifications, adapters, and demos

echo "========================================"
echo "ATHENA-CRDTS COMPREHENSIVE TEST SUITE"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

run_test() {
    local name="$1"
    local file="$2"
    
    echo -n "Testing $name... "
    if timeout 30 ./athena-run "$file" > /tmp/athena_test.log 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        local exit_code=$?
        echo -e "${RED}✗ FAIL${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        if [ $exit_code -eq 124 ]; then
            echo "  TIMEOUT (30s exceeded): $file"
        else
            echo "  Failed file: $file"
            grep "Error:" /tmp/athena_test.log | head -1 | sed 's/^/  /'
        fi
        return 1
    fi
}

echo -e "${BLUE}=== FRAMEWORK COMPONENTS ===${NC}"
run_test "Vector Clocks" "src/framework/vector_clocks.ath"
run_test "CRDT Specification Interface" "src/framework/crdt_specification.ath"
run_test "Payload Framework" "src/framework/payload.ath"
run_test "Unified Payload" "src/framework/unified_payload.ath"
run_test "Unified Backbone" "src/framework/unified_backbone.ath"

echo ""
echo -e "${BLUE}=== CRDT SPECIFICATIONS ===${NC}"
run_test "GCounter Specification" "src/crdts/gcounter_specification.ath"
run_test "GSet Specification" "src/crdts/gset_specification.ath"
run_test "PN-Counter Specification" "src/crdts/pncounter_specification.ath"
run_test "2P-Set Specification" "src/crdts/twophase_set_specification.ath"
run_test "LWW-Register Specification" "src/crdts/lww_register_specification.ath"

echo ""
echo -e "${BLUE}=== PAYLOAD ADAPTERS ===${NC}"
run_test "GCounter Adapter" "src/crdts/gcounter_payload_adapter.ath"
run_test "GSet Adapter" "src/crdts/gset_payload_adapter.ath"
run_test "PN-Counter Adapter" "src/crdts/pncounter_payload_adapter.ath"
run_test "2P-Set Adapter" "src/crdts/twophase_set_payload_adapter.ath"
run_test "LWW-Register Adapter" "src/crdts/lww_register_payload_adapter.ath"

echo ""
echo -e "${BLUE}=== UNIFIED DEMOS ===${NC}"
run_test "GCounter Unified Demo" "src/demos/gcounter_unified_demo.ath"
run_test "GSet Unified Demo" "src/demos/gset_unified_demo.ath"
run_test "PN-Counter Unified Demo" "src/demos/pncounter_unified_demo.ath"
run_test "2P-Set Unified Demo" "src/demos/twophase_set_unified_demo.ath"
run_test "LWW-Register Unified Demo" "src/demos/lww_register_unified_demo.ath"

echo ""
echo "========================================"
echo -e "RESULTS: ${GREEN}$PASS_COUNT passed${NC}, ${RED}$FAIL_COUNT failed${NC}"
echo "========================================"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
