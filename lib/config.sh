#!/usr/bin/env bash


CONFIG_FILE="${LAT_CONFIG_FILE:-$LAT_ROOT/config/toolkit.conf}"


load_config() {

    if [[ -f "$CONFIG_FILE" ]]; then

        # shellcheck disable=SC1090

        source "$CONFIG_FILE"

    fi


    LAT_REPORT_DIR="${LAT_REPORT_DIR:-$LAT_ROOT/reports}"

    LAT_LOG_DIR="${LAT_LOG_DIR:-$LAT_ROOT/logs}"


    export LAT_REPORT_DIR LAT_LOG_DIR


    ensure_directories

    init_logger

}
