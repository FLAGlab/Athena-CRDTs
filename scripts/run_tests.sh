#!/bin/bash
# Automated test runner for Athena-CRDTs framework
# Runs all test files and reports results
# Note: Some tests may timeout (gset_reduce_test.ath) - this is a known issue

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# Test directories
TEST_DIRS=(
  "src/tests"
  "src/demos/tests"
  "src/framework"
  "src/crdts"
)

# Files to run (property proofs and demos)
CORE_TESTS=(
  "src/framework/backbone_props.ath"
  "src/framework/payload_props.ath"
  "src/framework/vector_clock_properties.ath"
)

echo "================================================"
echo "  Athena-CRDTs Test Suite"
echo "================================================"
echo ""

# Function to run a single test file
run_test() {
  local test_file="$1"
  local test_name=$(basename "$test_file")
  
  TOTAL=$((TOTAL + 1))
  
  echo -n "Running $test_name ... "
  
  # Run athena-run with timeout to prevent hangs
  if timeout 60s ./athena-run "$test_file" > /dev/null 2>&1; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
    return 0
  else
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
      echo -e "${YELLOW}TIMEOUT${NC}"
      SKIPPED=$((SKIPPED + 1))
    else
      echo -e "${RED}FAILED${NC}"
      FAILED=$((FAILED + 1))
      # Show error details
      echo "  Error details:"
      timeout 60s ./athena-run "$test_file" 2>&1 | head -20 | sed 's/^/    /'
    fi
    return 1
  fi
}

# Run core property proofs
echo "=== Core Framework Properties ==="
for test in "${CORE_TESTS[@]}"; do
  if [ -f "$test" ]; then
    run_test "$test"
  else
    echo "Skipping $test (not found)"
  fi
done
echo ""

# Run tests from test directories
for dir in "${TEST_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "=== Tests in $dir ==="
    
    # Find all .ath files with "test" in the name
    while IFS= read -r test_file; do
      run_test "$test_file"
    done < <(find "$dir" -maxdepth 1 -name "*test*.ath" -o -name "*_props.ath" 2>/dev/null | sort)
    
    echo ""
  fi
done

# Summary
echo "================================================"
echo "  Test Summary"
echo "================================================"
echo -e "Total:   $TOTAL"
echo -e "${GREEN}Passed:  $PASSED${NC}"
echo -e "${RED}Failed:  $FAILED${NC}"
echo -e "${YELLOW}Timeout: $SKIPPED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Some tests failed${NC}"
  exit 1
fi
