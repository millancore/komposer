#!/bin/bash

# Simple Test Framework inspired by BATS
# This provides basic testing capabilities without any external dependencies.

set -o pipefail

# --- Test State ---
_test_counter=0
_failure_counter=0

# --- Test Runner ---

# @test "description" "function_name_or_command"
# Defines and runs a test case by executing the command string.
function @test {
    local description="$1"
    local command_to_run="$2"
    _test_counter=$((_test_counter + 1))
    
    echo "───────────────────────────────────────────────────────────────────────"
    echo "▶️  Running test #${_test_counter}: $description"
    
    # Run the test logic in a subshell to isolate its state
    (
        eval "$command_to_run"
    )
    
    # Check the exit code of the subshell
    if [ $? -eq 0 ]; then
        echo "✅  [PASS] Test #${_test_counter}: $description"
    else
        echo "❌  [FAIL] Test #${_test_counter}: $description"
        _failure_counter=$((_failure_counter + 1))
    fi
    echo ""
}

# --- Assertion Helpers ---

# run command...
# Executes a command and captures its status and output for assertions.
function run {
    _command_to_run=("$@")
    _temp_output_file=$(mktemp)
    
    "${_command_to_run[@]}" >"$_temp_output_file" 2>&1
    _status=$?
    
    BATS_OUTPUT=$(<"$_temp_output_file")
    rm "$_temp_output_file"
    
    return $_status
}

function assert_success {
    if [ "$_status" -ne 0 ]; then
        echo "  Assertion failed: Expected command to succeed (exit code 0), but it failed with status $_status."
        echo "  Command run: '''${_command_to_run[*]}'''"
        echo "  Output:"
        echo "$BATS_OUTPUT" | sed 's/^/    /'
        return 1
    fi
}

function assert_failure {
    if [ "$_status" -eq 0 ]; then
        echo "  Assertion failed: Expected command to fail (non-zero exit code), but it succeeded."
        echo "  Command run: '''${_command_to_run[*]}'''"
        echo "  Output:"
        echo "$BATS_OUTPUT" | sed 's/^/    /'
        return 1
    fi
}

function assert_output_contains {
    local pattern="$1"
    if [[ ! "$BATS_OUTPUT" == *"$pattern"* ]]; then
        echo "  Assertion failed: Expected output to contain '''$pattern'''."
        echo "  Command run: '''${_command_to_run[*]}'''"
        echo "  Full output:"
        echo "$BATS_OUTPUT" | sed 's/^/    /'
        return 1
    fi
}

# --- Test Case Definitions ---

DK_COMPOSER_SCRIPT="./dk-composer"
TEST_DIR="./tests"

function test_help_message {
    run "$DK_COMPOSER_SCRIPT" --help
    assert_success
    assert_output_contains "Usage: dk-composer [OPTIONS] <php_version> <composer_command>"
}

function test_missing_arguments {
    run "$DK_COMPOSER_SCRIPT"
    assert_failure
    assert_output_contains "Error: <php_version> and <composer_command> are required arguments."
}

function test_composer_version {
    local php_version="$1"
    run "$DK_COMPOSER_SCRIPT" "$php_version" --version
    assert_success
    assert_output_contains "Composer version"
}

function test_composer_install {
    cd "$TEST_DIR"
    rm -rf vendor composer.lock
    
    echo "  Running 'composer install'..."
    run "../$DK_COMPOSER_SCRIPT" "8.3" "install"
    
    assert_success
    assert_output_contains "Installing monolog/monolog"
    
    if [ ! -d "vendor" ]; then
        echo "  Assertion failed: 'vendor' directory was not created."
        rm -rf vendor composer.lock
        cd ..
        return 1
    fi
    
    echo "  'vendor' directory successfully created."
    rm -rf vendor composer.lock
    cd ..
}

# --- Main Test Execution ---

if [ ! -x "$DK_COMPOSER_SCRIPT" ]; then
    echo "Making dk-composer script executable..."
    chmod +x "$DK_COMPOSER_SCRIPT"
fi

@test "should display help message when called with --help" "test_help_message"
@test "should fail if required arguments are missing" "test_missing_arguments"

PHP_VERSIONS_TO_TEST=("8.3" "8.1" "7.4" "7.3" "7.2" "7.1")
for php_version in "${PHP_VERSIONS_TO_TEST[@]}"; do
    @test "should run 'composer --version' for PHP $php_version" "test_composer_version $php_version"
done

@test "should correctly run 'composer install' inside the test directory" "test_composer_install"

# --- Final Summary ---
echo "======================================================================="
echo "Test Summary"
echo "======================================================================="
echo "Total tests run: $_test_counter"

if [ "$_failure_counter" -ne 0 ]; then
    echo "Result: ❌ FAILED ($_failure_counter failures)"
    exit 1
else
    echo "Result: ✅ PASSED"
    exit 0
fi
