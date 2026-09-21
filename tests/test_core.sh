#!/usr/bin/env bash


set -Eeuo pipefail


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/lib/common.sh" 
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/validators.sh"

# Initialisation du répertoire de logs temporaire
TEST_LOG_DIR="$(mktemp -d)" passed=0
trap 'rm -rf "$TEST_LOG_DIR"' EXIT

LAT_LOG_DIR="$TEST_LOG_DIR" LOG_FILE="$TEST_LOG_DIR/test.log" 

init_logger

failed=0

assert_success() {
    local name="$1"

    shift


    if "$@"; then

        printf '[PASS] %s\n' "$name"

        passed=$((passed + 1))

    else

        printf '[FAIL] %s\n' "$name"

        failed=$((failed + 1))

    fi

}


assert_failure() {

    local name="$1"

    shift


    if ! "$@"; then

        printf '[PASS] %s\n' "$name"

        passed=$((passed + 1))

    else

        printf '[FAIL] %s\n' "$name"

        failed=$((failed + 1))

    fi

}


assert_success "command_exists finds bash" command_exists bash

assert_failure "command_exists rejects unknown command" command_exists command_that_does_not_exist_123

assert_success "positive integer validation" validate_positive_integer 10

assert_failure "invalid integer validation" validate_positive_integer abc

assert_success "directory validation" validate_directory "$ROOT_DIR"


printf '\nPassed: %d | Failed: %d\n' "$passed" "$failed"


(( failed == 0 ))
