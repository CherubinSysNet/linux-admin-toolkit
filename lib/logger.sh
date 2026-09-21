#!/usr/bin/env bash


LOG_FILE="${LOG_FILE:-}"


init_logger() {

    ensure_directories

    LOG_FILE="${LOG_FILE:-$LAT_LOG_DIR/lat.log}"

    touch "$LOG_FILE"

}


_log() {

    local level="$1"

    shift

    local message="$*"

    local line

    line="$(printf '[%s] [%s] %s' "$(timestamp)" "$level" "$message")"


    printf '%s\n' "$line" >> "$LOG_FILE"


    case "$level" in

        ERROR) printf '\033[31m%s\033[0m\n' "$line" >&2 ;;

        WARN)  printf '\033[33m%s\033[0m\n' "$line" >&2 ;;

        *)     printf '%s\n' "$line" ;;

    esac

}


log_info() {

    _log INFO "$@"

}


log_warn() {

    _log WARN "$@"

}


log_error() {

    _log ERROR "$@"

}


log_success() {

    _log SUCCESS "$@"

}
