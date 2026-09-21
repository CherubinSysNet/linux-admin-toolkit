#!/usr/bin/env bash


maintenance_health() {

    local issues=0


    ui_header "System Health" "Linux infrastructure health check"


    ui_section "REQUIRED COMMANDS"


    local commands=(

        awk

        df

        free

        ps

        ip

        ss

        systemctl

    )


    local available=0


    for command_name in "${commands[@]}"; do

        if command_exists "$command_name"; then

            ui_check "$command_name" ok

            ((available++))

        else

            ui_check "$command_name unavailable" warning

            ((issues++))

        fi

    done


    ui_section "STORAGE"


    local disk

    disk="$(df -P / | awk 'NR == 2 {

        gsub("%", "", $5)

        print $5

    }')"


    ui_label "Root filesystem" "${disk}% used"


    if (( disk < 80 )); then

        ui_check "Disk capacity is healthy" ok

    elif (( disk < 90 )); then

        ui_check "Disk usage requires attention" warning

        ((issues++))

    else

        ui_check "Disk usage is critical" error

        ((issues++))

    fi


    ui_section "SERVICES"


    if command_exists systemctl; then

        local failed

        failed="$(systemctl --failed --no-legend 2>/dev/null | wc -l)"


        if (( failed == 0 )); then

            ui_check "No failed systemd services" ok

        else

            ui_check "$failed failed service(s)" error

            ((issues++))

        fi

    fi


    ui_section "RESULT"


    ui_label "Checks" "${#commands[@]}"

    ui_label "Available" "$available"

    ui_label "Issues" "$issues"


    if (( issues == 0 )); then

        ui_status ok "SYSTEM HEALTHY"

    else

        ui_status warning "SYSTEM REQUIRES ATTENTION"

    fi


    ui_footer


    (( issues == 0 ))

}
