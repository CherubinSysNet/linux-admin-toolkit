#!/usr/bin/env bash


network_diagnose() {

    local target="${1:-8.8.8.8}"

    local dns_target="${2:-example.com}"


    ui_header "Network Diagnostics" "Connectivity and network inspection"


    ui_section "INTERFACES"


    if command_exists ip; then

        while read -r interface state address; do

            [[ -z "$interface" ]] && continue


            ui_label "$interface" "$state ${address:-}"

        done < <(

            ip -brief address |

            awk '{

                printf "%s %s %s\n", $1, $2, $3

            }'

        )

    else

        ui_check "ip command unavailable" error

    fi


    ui_section "ROUTING"


    if command_exists ip; then

        local gateway

        gateway="$(ip route show default | awk '{print $3; exit}')"


        if [[ -n "$gateway" ]]; then

            ui_label "Default Gateway" "$gateway"


            if ping -c 2 -W 2 "$gateway" >/dev/null 2>&1; then

                ui_status ok "Gateway reachable"

            else

                ui_status error "Gateway unreachable"

            fi

        else

            ui_status error "No default gateway detected"

        fi

    fi


    ui_section "DNS"


    ui_label "Resolver Test" "$dns_target"


    if getent hosts "$dns_target" >/dev/null 2>&1; then

        ui_status ok "DNS resolution successful"

    else

        ui_status error "DNS resolution failed"

    fi


    ui_section "CONNECTIVITY"


    ui_label "Target" "$target"


    if ping -c 2 -W 2 "$target" >/dev/null 2>&1; then

        ui_status ok "Host reachable"

    else

        ui_status error "Host unreachable"

    fi


    ui_section "LISTENING PORTS"


    if command_exists ss; then

        ss -tuln |

            awk 'NR > 1 {

                printf "  %-8s %s\n", $1, $5

            }' |

            head -n 10

    else

        ui_check "ss command unavailable" warning

    fi


    ui_footer

}
