#!/usr/bin/env bash


set -o pipefail


LAT_ROOT="${LAT_ROOT:-$(pwd)}"

LAT_REPORT_DIR="${LAT_REPORT_DIR:-$LAT_ROOT/reports}"

LAT_LOG_DIR="${LAT_LOG_DIR:-$LAT_ROOT/logs}"


ensure_directories() {

    mkdir -p "$LAT_REPORT_DIR" "$LAT_LOG_DIR"

}


command_exists() {

    command -v "$1" >/dev/null 2>&1

}


require_command() {

    if ! command_exists "$1"; then

        log_error "Required command not found: $1"

        return 1

    fi

}


is_root() {

    [[ "${EUID:-$(id -u)}" -eq 0 ]]

}


timestamp() {

    date '+%Y-%m-%d %H:%M:%S'

}


iso_timestamp() {

    date -u '+%Y-%m-%dT%H:%M:%SZ'

}


json_escape() {

    local value="$1"

    value=${value//\\/\\\\}

    value=${value//\"/\\\"}

    value=${value//$'\n'/\\n}

    value=${value//$'\r'/\\r}

    value=${value//$'\t'/\\t}

    printf '%s' "$value"

}


safe_filename() {

    printf '%s' "$1" | tr -c '[:alnum:]._- ' '_' | tr ' ' '_'

}


run_with_timeout() {

    local seconds="$1"

    shift


    if command_exists timeout; then

        timeout "$seconds" "$@"

    else

        "$@"

    fi

}
