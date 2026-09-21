#!/usr/bin/env bash


backup_create() {

    local source_dir="${1:-}"

    local destination_dir="${2:-$LAT_ROOT/backups}"


    if [[ -z "$source_dir" ]]; then

        ui_header "Backup Manager"

        ui_status error \

            "Usage: lat backup create <source> [destination]"

        ui_footer

        return 1

    fi


    validate_directory "$source_dir" || return 1


    mkdir -p "$destination_dir"


    local source_name

    local archive_file

    local checksum_file

    local archive_size


    source_name="$(basename "$(realpath "$source_dir")")"


    archive_file="$destination_dir/${source_name}_$(date +%Y%m%d_%H%M%S).tar.gz"

    checksum_file="${archive_file}.sha256"


    ui_header "Backup Manager" "Create compressed and verified backup"


    ui_section "SOURCE"


    ui_label "Source" "$source_dir"

    ui_label "Destination" "$destination_dir"


    ui_section "BACKUP"


    ui_status info "Creating archive..."


    if tar -czf "$archive_file" \

        -C "$(dirname "$(realpath "$source_dir")")" \

        "$source_name"; then


        ui_check "Archive created" ok

    else

        ui_check "Archive creation failed" error

        ui_footer

        return 1

    fi


    ui_status info "Calculating SHA-256..."


    sha256sum "$archive_file" > "$checksum_file"


    archive_size="$(du -h "$archive_file" | awk '{print $1}')"


    ui_label "Archive" "$(basename "$archive_file")"

    ui_label "Size" "$archive_size"

    ui_label "Checksum" "SHA-256"


    ui_section "RESULT"


    ui_status ok "BACKUP COMPLETED"


    ui_footer

}


backup_restore() {

    local archive="${1:-}"

    local destination="${2:-.}"


    if [[ -z "$archive" ]]; then

        ui_header "Backup Manager"

        ui_status error \

            "Usage: lat backup restore <archive> [destination]"

        ui_footer

        return 1

    fi


    validate_file "$archive" || return 1


    mkdir -p "$destination"


    if ! tar -tzf "$archive" >/dev/null 2>&1; then

        ui_header "Backup Restore"

        ui_status error "Invalid or corrupted archive"

        ui_footer

        return 1

    fi


    ui_header "Backup Restore" "Restore archived data"


    ui_section "RESTORE"


    ui_label "Archive" "$archive"

    ui_label "Destination" "$destination"


    printf '\n'


    if ! confirm_action "Proceed with restoration?"; then

        ui_status warning "RESTORATION CANCELLED"

        ui_footer

        return 0

    fi


    if tar -xzf "$archive" -C "$destination"; then

        ui_status ok "RESTORATION COMPLETED"

    else

        ui_status error "RESTORATION FAILED"

        ui_footer

        return 1

    fi


    ui_footer

}
