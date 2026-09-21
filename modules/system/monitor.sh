#!/usr/bin/env bash


# ============================================================

# Linux Admin Toolkit - System Monitor

# Branding : MANDRIVA

# ============================================================


get_hostname() {

    hostname 2>/dev/null || printf 'unknown'

}


get_os_name() {

    if [[ -f /etc/os-release ]]; then

        # shellcheck disable=SC1091

        . /etc/os-release

        printf '%s' "${PRETTY_NAME:-Linux}"

    else

        printf 'Linux'

    fi

}


get_cpu_usage() {

    local result="0.0"


    if command_exists top; then

        result="$(

            LC_ALL=C top -bn1 2>/dev/null |

                awk '

                /Cpu\(s\)/ {

                    for (i = 1; i <= NF; i++) {

                        if ($i ~ /id,?$/) {

                            idle = $(i - 1)

                            gsub(",", "", idle)

                            printf "%.1f", 100 - idle

                            exit

                        }

                    }

                }'

        )"

    fi


    [[ "$result" =~ ^[0-9]+([.][0-9]+)?$ ]] || result="0.0"


    printf '%s' "$result"

}


get_memory_percent() {

    local result="0.0"


    if command_exists free; then

        result="$(

            free | awk '/^Mem:/ {

                if ($2 > 0) {

                    printf "%.1f", ($3 / $2) * 100

                } else {

                    print "0.0"

                }

            }'

        )"

    fi


    [[ "$result" =~ ^[0-9]+([.][0-9]+)?$ ]] || result="0.0"


    printf '%s' "$result"

}


get_memory_details() {

    if command_exists free; then

        free -m | awk '/^Mem:/ {

            printf "%s MB / %s MB", $3, $2

        }'

    else

        printf 'unknown'

    fi

}


get_disk_percent() {

    local result="0"


    if command_exists df; then

        result="$(

            df -P / 2>/dev/null |

                awk 'NR == 2 {

                    gsub("%", "", $5)

                    print $5

                }'

        )"

    fi


    [[ "$result" =~ ^[0-9]+$ ]] || result="0"


    printf '%s' "$result"

}


get_disk_details() {

    if command_exists df; then

        df -hP / 2>/dev/null |

            awk 'NR == 2 {

                printf "%s / %s", $3, $2

            }'

    else

        printf 'unknown'

    fi

}


get_uptime() {

    if command_exists uptime; then

        uptime -p 2>/dev/null || printf 'unknown'

    else

        printf 'unknown'

    fi

}


get_load_average() {

    if [[ -r /proc/loadavg ]]; then

        awk '{print $1, $2, $3}' /proc/loadavg

    else

        printf 'unknown'

    fi

}


get_process_count() {

    if command_exists ps; then

        ps -e --no-headers 2>/dev/null | wc -l

    else

        printf '0'

    fi

}


draw_usage_bar() {

    local value="${1:-0}"

    local width=30

    local numeric="${value%.*}"


    [[ "$numeric" =~ ^[0-9]+$ ]] || numeric=0


    (( numeric > 100 )) && numeric=100

    (( numeric < 0 )) && numeric=0


    local filled=$((numeric * width / 100))

    local empty=$((width - filled))


    printf '  '


    if [[ "${UI_COLOR:-false}" == true ]]; then

        ui_color "$LIME" "$(ui_repeat '#' "$filled")"

        ui_color "$GRAY" "$(ui_repeat '-' "$empty")"

    else

        printf '%s%s' \

            "$(ui_repeat '#' "$filled")" \

            "$(ui_repeat '-' "$empty")"

    fi


    printf ' %s%%\n' "$value"

}


system_monitor() {

    local json=false


    if [[ "${1:-}" == "--json" ]]; then

        json=true

    fi


    local hostname_value

    local os_name

    local kernel

    local uptime_value

    local load_average

    local cpu

    local memory

    local memory_details

    local disk

    local disk_details

    local processes


    hostname_value="$(get_hostname)"

    os_name="$(get_os_name)"

    kernel="$(uname -r 2>/dev/null || printf 'unknown')"

    uptime_value="$(get_uptime)"

    load_average="$(get_load_average)"

    cpu="$(get_cpu_usage)"

    memory="$(get_memory_percent)"

    memory_details="$(get_memory_details)"

    disk="$(get_disk_percent)"

    disk_details="$(get_disk_details)"

    processes="$(get_process_count)"


    if [[ "$json" == true ]]; then

        cat <<EOF

{

  "timestamp": "$(json_escape "$(iso_timestamp)")",

  "hostname": "$(json_escape "$hostname_value")",

  "os": "$(json_escape "$os_name")",

  "kernel": "$(json_escape "$kernel")",

  "uptime": "$(json_escape "$uptime_value")",

  "load_average": "$(json_escape "$load_average")",

  "cpu_percent": $cpu,

  "memory_percent": $memory,

  "memory": "$(json_escape "$memory_details")",

  "disk_percent": $disk,

  "disk": "$(json_escape "$disk_details")",

  "process_count": $processes

}

EOF

        return 0

    fi


    ui_header "System Monitor" "Real-time Linux system information"


    ui_section "SYSTEM"


    ui_label "Hostname" "$hostname_value"

    ui_label "Operating System" "$os_name"

    ui_label "Kernel" "$kernel"

    ui_label "Uptime" "$uptime_value"

    ui_label "Load Average" "$load_average"

    ui_label "Processes" "$processes"


    ui_section "RESOURCES"


    ui_label "CPU" "${cpu}%"

    draw_usage_bar "$cpu"


    ui_label "Memory" "$memory_details"

    draw_usage_bar "$memory"


    ui_label "Disk /" "$disk_details"

    draw_usage_bar "$disk"


    ui_section "STATUS"


    local cpu_integer="${cpu%.*}"

    local memory_integer="${memory%.*}"


    [[ "$cpu_integer" =~ ^[0-9]+$ ]] || cpu_integer=0

    [[ "$memory_integer" =~ ^[0-9]+$ ]] || memory_integer=0


    if (( cpu_integer < 80 )); then

        ui_check "CPU usage within normal range" ok

    else

        ui_check "CPU usage is high" warning

    fi


    if (( memory_integer < 80 )); then

        ui_check "Memory usage within normal range" ok

    else

        ui_check "Memory usage is high" warning

    fi


    if (( disk < 80 )); then

        ui_check "Disk usage within normal range" ok

    else

        ui_check "Disk usage is high" warning

    fi


    ui_status ok "SYSTEM MONITORING COMPLETE"


    ui_footer

}


report_generate() {

    local report_file

    local timestamp_value


    timestamp_value="$(date '+%Y%m%d-%H%M%S')"

    report_file="$LAT_REPORT_DIR/system-$timestamp_value.json"


    mkdir -p "$LAT_REPORT_DIR"


    system_monitor --json > "$report_file"


    ui_header "System Report" "System information export"


    ui_section "REPORT"


    ui_label "Host" "$(get_hostname)"

    ui_label "Generated" "$(date '+%Y-%m-%d %H:%M:%S')"

    ui_label "Format" "JSON"

    ui_label "File" "$report_file"


    ui_status ok "REPORT GENERATED SUCCESSFULLY"


    ui_footer

}
