#!/usr/bin/env bash


security_audit() {

    local privileged_users

    local listening_ports

    local failed_services=0

    local writable_files


    privileged_users="$(

        awk -F: '$3 == 0 {print $1}' /etc/passwd |

        wc -l

    )"


    if command_exists ss; then

        listening_ports="$(

            ss -tuln |

            tail -n +2 |

            wc -l

        )"

    else

        listening_ports=0

    fi


    if command_exists systemctl; then

        failed_services="$(

            systemctl --failed --no-legend 2>/dev/null |

            wc -l

        )"

    fi


    writable_files="$(

        find /etc -xdev -type f -perm -0002 2>/dev/null |

        wc -l

    )"


    ui_header "Security Audit" "Non-destructive Linux security inspection"


    ui_section "SYSTEM"


    ui_label "Privileged Users" "$privileged_users"

    ui_label "Listening Ports" "$listening_ports"

    ui_label "Failed Services" "$failed_services"

    ui_label "Writable /etc Files" "$writable_files"


    ui_section "SERVICES"


    if (( failed_services == 0 )); then

        ui_check "No failed systemd services" ok

    else

        ui_check "$failed_services failed systemd service(s)" error

    fi


    ui_section "SSH"


    if [[ -f /etc/ssh/sshd_config ]]; then


        local root_login

        local password_auth


        root_login="$(

            awk '$1 == "PermitRootLogin" {print $2}' \

                /etc/ssh/sshd_config |

            tail -n 1

        )"


        password_auth="$(

            awk '$1 == "PasswordAuthentication" {print $2}' \

                /etc/ssh/sshd_config |

            tail -n 1

        )"


        ui_label "Root Login" "${root_login:-not configured}"

        ui_label "Password Auth" "${password_auth:-not configured}"


    else

        ui_check "SSH configuration not found" warning

    fi


    ui_section "FILESYSTEM"


    if (( writable_files == 0 )); then

        ui_check "No world-writable files detected in /etc" ok

    else

        ui_check "$writable_files world-writable file(s) detected" warning

    fi


    ui_section "RESULT"


    if (( failed_services == 0 && writable_files == 0 )); then

        ui_status ok "SECURITY AUDIT COMPLETED"

    else

        ui_status warning "ITEMS REQUIRE REVIEW"

    fi


    ui_footer

}
