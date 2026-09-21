#!/usr/bin/env bash


# ============================================================

# Linux Admin Toolkit - User Interface Engine

# Branding : MANDRIVA

#

# Palette :

#   #0B0D10 - Background

#   #F7F7F5 - Primary text

#   #A6A9AD - Secondary text

#   #C8FF3D - Accent

# ============================================================


RESET='\033[0m'

BOLD='\033[1m'


BLACK='\033[38;2;11;13;16m'

WHITE='\033[38;2;247;247;245m'

GRAY='\033[38;2;166;169;173m'

LIME='\033[38;2;200;255;61m'

RED='\033[38;2;255;95;95m'

YELLOW='\033[38;2;255;200;80m'

BLUE='\033[38;2;100;180;255m'


UI_WIDTH=62

UI_COLOR=false


# ------------------------------------------------------------

# INITIALISATION

# ------------------------------------------------------------


ui_enable() {

    if [[ -t 1 ]]; then

        UI_COLOR=true

    else

        UI_COLOR=false

    fi

}


# ------------------------------------------------------------

# COULEURS

# ------------------------------------------------------------


ui_color() {

    local color="$1"

    shift


    if [[ "${UI_COLOR:-false}" == true ]]; then

        printf '%b%s%b' "$color" "$*" "$RESET"

    else

        printf '%s' "$*"

    fi

}


ui_bold() {

    local text="$1"


    if [[ "${UI_COLOR:-false}" == true ]]; then

        printf '%b%s%b' "$BOLD" "$text" "$RESET"

    else

        printf '%s' "$text"

    fi

}


# ------------------------------------------------------------

# ELEMENTS DE BASE

# ------------------------------------------------------------


ui_line() {

    printf '%*s\n' "$UI_WIDTH" '' | tr ' ' '-'

}


ui_empty_line() {

    printf '|%*s|\n' "$UI_WIDTH" ''

}


ui_clear() {

    if [[ -t 1 ]]; then

        printf '\033[2J\033[H'

    fi

}


# ------------------------------------------------------------

# EN-TETE

# ------------------------------------------------------------


ui_header() {

    local title="${1:-Linux Admin Toolkit}"

    local subtitle="${2:-}"


    local brand="  MANDRIVA / LINUX ADMIN TOOLKIT"

    local brand_length=${#brand}

    local title_length=${#title}

    local subtitle_length=${#subtitle}


    # Protection contre les textes trop longs

    if (( brand_length > UI_WIDTH )); then

        brand_length=$UI_WIDTH

    fi


    if (( title_length > UI_WIDTH - 2 )); then

        title="${title:0:UI_WIDTH-2}"

        title_length=${#title}

    fi


    if (( subtitle_length > UI_WIDTH - 2 )); then

        subtitle="${subtitle:0:UI_WIDTH-2}"

        subtitle_length=${#subtitle}

    fi


    printf '\n'


    # Bordure supérieure

    printf '+%s+\n' "$(ui_repeat '-' "$UI_WIDTH")"


    # Marque

    printf '|'


    ui_color "$LIME" "  MANDRIVA"

    ui_color "$GRAY" " / "

    ui_color "$WHITE" "LINUX ADMIN TOOLKIT"


    printf '%*s|\n' "$((UI_WIDTH - brand_length))" ''


    # Séparateur

    printf '+%s+\n' "$(ui_repeat '-' "$UI_WIDTH")"


    # Titre

    printf '|  '

    ui_color "$WHITE" "${title^^}"


    printf '%*s|\n' "$((UI_WIDTH - title_length - 2))" ''


    # Sous-titre

    if [[ -n "$subtitle" ]]; then

        printf '|  '

        ui_color "$GRAY" "$subtitle"


        printf '%*s|\n' "$((UI_WIDTH - subtitle_length - 2))" ''

    fi


    # Ligne vide

    ui_empty_line

}


ui_footer() {

    printf '+%s+\n' "$(ui_repeat '-' "$UI_WIDTH")"

    printf '\n'

}


# ------------------------------------------------------------

# REPETITION DE CARACTERES

# ------------------------------------------------------------


ui_repeat() {

    local character="$1"

    local count="$2"


    if (( count <= 0 )); then

        return 0

    fi


    printf '%*s' "$count" '' | tr ' ' "$character"

}


# ------------------------------------------------------------

# SECTIONS

# ------------------------------------------------------------


ui_section() {

    local title="$1"


    printf '\n'


    ui_color "$LIME" "$title"

    printf '\n'


    ui_color "$GRAY" "$(ui_repeat '-' "$UI_WIDTH")"

    printf '\n'

}


# ------------------------------------------------------------

# LABELS ET VALEURS

# ------------------------------------------------------------


ui_label() {

    local label="$1"

    local value="${2:-}"


    printf '  '


    ui_color "$GRAY" "$(printf '%-18s' "$label")"

    ui_color "$WHITE" "$value"


    printf '\n'

}


ui_title_value() {

    local title="$1"

    local value="${2:-}"


    printf '  '


    ui_color "$LIME" "$title"

    printf ' '

    ui_color "$WHITE" "$value"


    printf '\n'

}


# ------------------------------------------------------------

# MESSAGES D'ETAT

# ------------------------------------------------------------


ui_status() {

    local status="${1:-info}"

    local message="${2:-}"


    printf '  '


    case "${status,,}" in

        ok|success)

            ui_color "$LIME" "[OK] "

            ;;


        warning|warn)

            ui_color "$YELLOW" "[WARN] "

            ;;


        error|critical)

            ui_color "$RED" "[ERROR] "

            ;;


        info)

            ui_color "$BLUE" "[INFO] "

            ;;


        *)

            ui_color "$GRAY" "[....] "

            ;;

    esac


    ui_color "$WHITE" "$message"

    printf '\n'

}


ui_check() {

    local message="$1"

    local status="${2:-ok}"


    printf '  '


    case "${status,,}" in

        ok|success)

            ui_color "$LIME" "[+] "

            ;;


        warning|warn)

            ui_color "$YELLOW" "[!] "

            ;;


        error|critical)

            ui_color "$RED" "[-] "

            ;;


        *)

            ui_color "$GRAY" "[.] "

            ;;

    esac


    ui_color "$WHITE" "$message"

    printf '\n'

}


# ------------------------------------------------------------

# BARRE DE PROGRESSION

# ------------------------------------------------------------


ui_progress() {

    local current="$1"

    local total="$2"

    local width="${3:-38}"


    (( total > 0 )) || total=1

    (( current < 0 )) && current=0

    (( current > total )) && current=$total


    local percent=$((current * 100 / total))

    local filled=$((percent * width / 100))

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


    printf ' %3d%%\n' "$percent"

}


# ------------------------------------------------------------

# BARRE D'UTILISATION DES RESSOURCES

# ------------------------------------------------------------


ui_usage_bar() {

    local value="$1"

    local width="${2:-30}"


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


# ------------------------------------------------------------

# TABLEAUX

# ------------------------------------------------------------


ui_table_header() {

    local left="$1"

    local right="$2"


    printf '  '


    ui_color "$GRAY" "$(printf '%-24s' "$left")"

    ui_color "$GRAY" "$right"


    printf '\n'


    printf '  '

    ui_color "$GRAY" "$(ui_repeat '-' "$((UI_WIDTH - 2))")"

    printf '\n'

}


# ------------------------------------------------------------

# CONFIRMATION

# ------------------------------------------------------------


ui_confirm() {

    local prompt="${1:-Continue?}"

    local answer


    printf '  '

    ui_color "$YELLOW" "$prompt [y/N] "

    read -r answer


    [[ "$answer" =~ ^[Yy]$ ]]

}


# ------------------------------------------------------------

# INITIALISATION DE L'INTERFACE

# ------------------------------------------------------------



ui_enable
