#!/usr/bin/env bash


validate_directory() {

    if [[ ! -d "$1" ]]; then

        log_error "Directory does not exist: $1"

        return 1

    fi


    return 0

}


validate_file() {

    if [[ ! -f "$1" ]]; then

        log_error "File does not exist: $1"

        return 1

    fi


    return 0

}


validate_positive_integer() {

    if [[ ! "$1" =~ ^[1-9][0-9]*$ ]]; then

        log_error "Invalid positive integer: $1"

        return 1

    fi


    return 0

}


confirm_action() {

    local prompt="${1:-Continue?}"

    local answer


    read -r -p "$prompt [y/N] " answer


    [[ "$answer" =~ ^[Yy]$ ]]

}
