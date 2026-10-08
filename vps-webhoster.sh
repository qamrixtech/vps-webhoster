#!/usr/bin/env bash
# =============================================================================
#  VPS WEBHOSTER - Free Website Control Panel Installer & Server Toolkit
#  ---------------------------------------------------------------
#  Version : 1.0.0
#  Author  : Hayder
#  License : MIT
#  Repo    : https://github.com/qamrixtech/vps-webhoster
#
#  What it does:
#    * Auto-detects Ubuntu / Debian / AlmaLinux / Rocky Linux (+ CentOS)
#    * Detects architecture (x86_64 / aarch64), RAM, CPU cores, disk
#    * Builds a terminal TUI (dialog / whiptail / plain fallback)
#    * Recommends the best FREE website control panel for YOUR server
#    * Installs the selected panel with its latest official installer
#    * Removes panels cleanly (services, packages, files, users, ports)
#    * Junk cleaner (package cache, old kernels, logs, journal, trash...)
#    * Security hardening, status dashboard, system updates
#    * Built-in beginner guide in English AND Roman Urdu
#
#  Usage (interactive):
#      sudo bash vps-webhoster.sh
#  Usage (one-shot):
#      sudo bash vps-webhoster.sh --install hestiacp
#      sudo bash vps-webhoster.sh --remove aapanel
#      sudo bash vps-webhoster.sh --clean
#      bash vps-webhoster.sh --detect
#
#  Made by Hayder. Free for everyone. Be careful on production servers.
# =============================================================================

set -uo pipefail

# ----------------------------------------------------------------------------
# Constants & globals
# ----------------------------------------------------------------------------
readonly SCRIPT_NAME="VPS WebHoster"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_AUTHOR="Hayder"
readonly REPO_URL="https://github.com/qamrixtech/vps-webhoster"
readonly LOG_FILE_DEFAULT="/var/log/vps-webhoster.log"
readonly SETTINGS_FILE="${HOME}/.vps-webhoster.conf"

LOG_FILE="$LOG_FILE_DEFAULT"
ASSUME_YES=0
CLI_ACTION=""
CLI_ARG=""
CLI_LANG=""
LANG_PREF="en"          # en | ur  (guide language)
UI_BACKEND="plain"      # dialog | whiptail | plain
OS_ID=""
OS_VERSION=""
OS_TOKEN=""
OS_PRETTY=""
OS_FAMILY=""            # debian | rhel
ARCH=""
ARCH_OK=""              # normalized: x86_64 | aarch64
RAM_MB=0
RAM_GB=0
CORES=0
DISK_GB=0
VIRT="unknown"
PUB_IP=""
FOUND_PANELS=()
REC_ID=""
REC_REASON=""
COMPAT_REASON=""

# ----------------------------------------------------------------------------
# Colors (used in plain output and info screens)
# ----------------------------------------------------------------------------
C_RESET=$'\e[0m'
C_BOLD=$'\e[1m'
C_RED=$'\e[31m'
C_GREEN=$'\e[32m'
C_YELLOW=$'\e[33m'
C_BLUE=$'\e[34m'
C_CYAN=$'\e[36m'
C_DIM=$'\e[2m'

# ----------------------------------------------------------------------------
# Small helpers
# ----------------------------------------------------------------------------
log() {
    local msg
    msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    if [[ -w "$(dirname "$LOG_FILE")" ]] 2>/dev/null; then
        printf '%s\n' "$msg" >>"$LOG_FILE" 2>/dev/null || true
    else
        printf '%s\n' "$msg" >>"/tmp/vps-webhoster-$(id -u).log" 2>/dev/null || true
    fi
}

info()  { printf '%s[INFO]%s %s\n'  "$C_BLUE"   "$C_RESET" "$*"; }
ok()    { printf '%s[ OK ]%s %s\n'  "$C_GREEN"  "$C_RESET" "$*"; }
warn()  { printf '%s[WARN]%s %s\n'  "$C_YELLOW" "$C_RESET" "$*"; }
err()   { printf '%s[FAIL]%s %s\n'  "$C_RED"    "$C_RESET" "$*" >&2; }
hr()    { printf '%s\n' "--------------------------------------------------------"; }

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        err "This action needs root. Run:  sudo bash $0 ${1:-}"
        return 1
    fi
    return 0
}

confirm() {
    local prompt="${1:-Are you sure?}"
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        return 0
    fi
    local ans
    printf '%s [y/N]: ' "$prompt"
    read -r ans
    [[ "$ans" =~ ^[Yy] ]]
}

pause() {
    if [[ "$UI_BACKEND" == "plain" ]]; then
        printf 'Press Enter to continue...'
        read -r _
    else
        ui_msg "VPS WebHoster" "Done. Press OK to go back to the menu."
    fi
}

print_banner() {
    cat <<'BANNER'

==============================================================
|   V P S   W E B H O S T E R                                |
|   Free Website Control Panel Installer & Server Toolkit    |
|   ------------------------------------------------         |
|   Made by Hayder                     v1.0.0                |
|   https://github.com/qamrixtech/vps-webhoster              |
==============================================================

BANNER
}

print_usage() {
    cat <<EOF
${C_BOLD}${SCRIPT_NAME} v${SCRIPT_VERSION} - Made by ${SCRIPT_AUTHOR}${C_RESET}

Usage:
  sudo bash $0                      Launch the interactive TUI menu
  bash $0 --detect                  Show system detection (no root needed)
  bash $0 --list                    List all supported control panels
  bash $0 --guide [--lang en|ur]    Open the beginner guide
  sudo bash $0 --install <panel>    Install a panel (its official installer)
  sudo bash $0 --remove <panel>     Remove a panel cleanly
  sudo bash $0 --clean [items]      Junk cleaner (comma separated items)
  sudo bash $0 --status             Server status dashboard
  sudo bash $0 --security           Security hardening wizard
  sudo bash $0 --update             Update & upgrade the system
  bash $0 --lang en|ur              Set guide language (en / ur = Roman Urdu)
  bash $0 --version                 Print version
  bash $0 --help                    This help

Panels: hestiacp, cloudpanel, aapanel, cyberpanel,
        virtualmin, ispconfig, fastpanel, cwp
Clean items: pkgcache,autoremove,journal,oldlogs,tmp,trash,kernels,docker
EOF
}

# ----------------------------------------------------------------------------
# Settings (guide language is remembered)
# ----------------------------------------------------------------------------
load_settings() {
    if [[ -f "$SETTINGS_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$SETTINGS_FILE"
        [[ "${LANG_PREF:-en}" == "ur" ]] && LANG_PREF="ur" || LANG_PREF="en"
    fi
}

save_settings() {
    if umask 077; then
        printf 'LANG_PREF="%s"\n' "$LANG_PREF" >"$SETTINGS_FILE" 2>/dev/null || true
    fi
}

# ----------------------------------------------------------------------------
# System detection
# ----------------------------------------------------------------------------
detect_system() {
    if [[ ! -r /etc/os-release ]]; then
        err "Cannot read /etc/os-release - unsupported system."
        exit 1
    fi
    # shellcheck disable=SC1091
    source /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-unknown}"
    OS_PRETTY="${PRETTY_NAME:-$OS_ID $OS_VERSION}"

    case "$OS_ID" in
        ubuntu|debian)                 OS_FAMILY="debian" ;;
        almalinux|rocky|centos|ol|rhel) OS_FAMILY="rhel"   ;;
        *)                             OS_FAMILY="unknown" ;;
    esac

    # Normalized version token: rhel family -> major only (9.5 -> 9)
    if [[ "$OS_FAMILY" == "rhel" ]]; then
        OS_TOKEN="$OS_ID:${OS_VERSION%%.*}"
    else
        OS_TOKEN="$OS_ID:$OS_VERSION"
    fi

    local m
    m="$(uname -m)"
    case "$m" in
        x86_64|amd64)   ARCH_OK="x86_64"  ;;
        aarch64|arm64)  ARCH_OK="aarch64" ;;
        *)              ARCH_OK="$m"      ;;
    esac
    ARCH="$m"

    RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)
    RAM_GB=$(( RAM_MB / 1024 ))
    CORES=$(nproc 2>/dev/null || echo 1)
    DISK_GB=$(df -BG --output=size / 2>/dev/null | awk 'NR==2 {gsub(/G/,""); print $1}' || echo 0)
    [[ "$DISK_GB" =~ ^[0-9]+$ ]] || DISK_GB=0

    if command -v systemd-detect-virt >/dev/null 2>&1; then
        VIRT=$(systemd-detect-virt 2>/dev/null || echo "none (bare metal)")
        [[ -z "$VIRT" ]] && VIRT="unknown"
    fi

    PUB_IP=$(curl -4 -s --max-time 5 https://ifconfig.me 2>/dev/null || true)
    [[ -z "$PUB_IP" ]] && PUB_IP=$(curl -4 -s --max-time 5 https://api.ipify.org 2>/dev/null || true)
    [[ -z "$PUB_IP" ]] && PUB_IP="unknown"

    log "Detected: $OS_PRETTY | token=$OS_TOKEN arch=$ARCH_OK ram=${RAM_MB}MB cores=$CORES disk=${DISK_GB}GB"
}

pkg_manager() {
    if command -v apt-get >/dev/null 2>&1; then echo "apt"
    elif command -v dnf >/dev/null 2>&1; then echo "dnf"
    elif command -v yum >/dev/null 2>&1; then echo "yum"
    else echo "unknown"
    fi
}

# ----------------------------------------------------------------------------
# Panel data (verified against official docs - v1.0.0)
#   P_OS      : supported "id:version" tokens (space separated)
#   P_ARCH    : supported architectures
#   P_MINRAM  : minimum RAM in MB
#   P_RECRAM  : recommended RAM in MB
#   P_MINDISK : minimum disk in GB
#   P_PORT    : panel web port (or description)
#   P_MARKER  : path that proves the panel is installed
# ----------------------------------------------------------------------------
PANEL_IDS=(hestiacp cloudpanel aapanel cyberpanel virtualmin ispconfig fastpanel cwp)

declare -A P_NAME=(
    [hestiacp]="HestiaCP"
    [cloudpanel]="CloudPanel"
    [aapanel]="aaPanel"
    [cyberpanel]="CyberPanel"
    [virtualmin]="Virtualmin GPL"
    [ispconfig]="ISPConfig"
    [fastpanel]="FastPanel"
    [cwp]="CWP (Control Web Panel)"
)

declare -A P_SHORT=(
    [hestiacp]="Complete free cPanel alternative (PostgreSQL, custom DNS, email)"
    [cloudpanel]="Lightest modern panel (MariaDB, Varnish, PHP/Node/Python)"
    [aapanel]="Lowest RAM usage, beginner friendly (512 MB minimum)"
    [cyberpanel]="OpenLiteSpeed speed demon for PHP/WordPress"
    [virtualmin]="Most mature free panel (mail, DNS, full control)"
    [ispconfig]="True multi-server panel for hosting businesses"
    [fastpanel]="Modern clean UI with a free lifetime license"
    [cwp]="Enterprise style panel for AlmaLinux / Rocky"
)

declare -A P_LICENSE=(
    [hestiacp]="100% Free (GPL)"
    [cloudpanel]="Free Community Edition"
    [aapanel]="Free (Pro add-ons paid)"
    [cyberpanel]="Free edition (Pro paid)"
    [virtualmin]="100% Free (GPL)"
    [ispconfig]="100% Free (GPL)"
    [fastpanel]="Free license (personal + commercial)"
    [cwp]="Free (Pro paid)"
)

declare -A P_OS=(
    [hestiacp]="ubuntu:22.04 ubuntu:24.04 ubuntu:26.04 debian:12 debian:13"
    [cloudpanel]="ubuntu:22.04 ubuntu:24.04 ubuntu:26.04 debian:11 debian:12 debian:13"
    [aapanel]="ubuntu:22.04 ubuntu:24.04 ubuntu:26.04 debian:11 debian:12 debian:13 almalinux:8 almalinux:9 almalinux:10 rocky:8 rocky:9 rocky:10 centos:9 centos:10"
    [cyberpanel]="ubuntu:20.04 ubuntu:22.04 ubuntu:24.04 ubuntu:26.04 almalinux:8 almalinux:9 rocky:8 rocky:9"
    [virtualmin]="ubuntu:20.04 ubuntu:22.04 ubuntu:24.04 debian:11 debian:12 almalinux:8 almalinux:9 almalinux:10 rocky:8 rocky:9 rocky:10"
    [ispconfig]="ubuntu:22.04 ubuntu:24.04 debian:11 debian:12 debian:13"
    [fastpanel]="debian:9 debian:10 debian:11 debian:12 ubuntu:18.04 ubuntu:20.04 ubuntu:22.04 ubuntu:24.04 almalinux:8 rocky:8 centos:7"
    [cwp]="almalinux:8 almalinux:9 rocky:8 rocky:9 centos:7 centos:8 centos:9"
)

declare -A P_ARCH=(
    [hestiacp]="x86_64 aarch64"
    [cloudpanel]="x86_64 aarch64"
    [aapanel]="x86_64"
    [cyberpanel]="x86_64"
    [virtualmin]="x86_64 aarch64"
    [ispconfig]="x86_64 aarch64"
    [fastpanel]="x86_64"
    [cwp]="x86_64"
)

declare -A P_MINRAM=([hestiacp]=1024 [cloudpanel]=2048 [aapanel]=512 [cyberpanel]=1024
                     [virtualmin]=1024 [ispconfig]=1024 [fastpanel]=1024 [cwp]=2048)
declare -A P_RECRAM=([hestiacp]=4096 [cloudpanel]=4096 [aapanel]=1024 [cyberpanel]=2048
                     [virtualmin]=2048 [ispconfig]=2048 [fastpanel]=2048 [cwp]=4096)
declare -A P_MINDISK=([hestiacp]=10 [cloudpanel]=10 [aapanel]=5 [cyberpanel]=10
                      [virtualmin]=8 [ispconfig]=10 [fastpanel]=5 [cwp]=10)
declare -A P_PORT=(
    [hestiacp]="8083"
    [cloudpanel]="8443"
    [aapanel]="dynamic (run: bt default)"
    [cyberpanel]="8090"
    [virtualmin]="10000"
    [ispconfig]="8080"
    [fastpanel]="8888"
    [cwp]="2030"
)
declare -A P_MARKER=(
    [hestiacp]="/usr/local/hestia"
    [cloudpanel]="/usr/local/cloudpanel"
    [aapanel]="/www/server/panel"
    [cyberpanel]="/usr/local/CyberCP"
    [virtualmin]="/etc/webmin/virtual-server"
    [ispconfig]="/usr/local/ispconfig"
    [fastpanel]="/usr/local/fastpanel2"
    [cwp]="/usr/local/cwp"
)
declare -A P_DOCS=(
    [hestiacp]="https://hestiacp.com/docs/introduction/getting-started"
    [cloudpanel]="https://www.cloudpanel.io/docs/"
    [aapanel]="https://www.aapanel.com/docs/guide/quickstart.html"
    [cyberpanel]="https://cyberpanel.net/KnowledgeBase/home/install-cyberpanel/"
    [virtualmin]="https://www.virtualmin.com/download/"
    [ispconfig]="https://www.ispconfig.org/documentation/"
    [fastpanel]="https://kb.fastpanel.direct/quick_start/how-to-install-fastpanel/"
    [cwp]="https://control-webpanel.com/installation-instructions"
)

# ----------------------------------------------------------------------------
# Official install commands (verified from official docs, Oct 2026)
# ----------------------------------------------------------------------------
panel_install_cmd() {
    case "$1" in
        hestiacp)
            printf '%s' 'wget -q https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh -O /tmp/hst-install.sh && bash /tmp/hst-install.sh'
            ;;
        cloudpanel)
            printf '%s' 'curl -sSL https://installer.cloudpanel.io/ce/v2/install.sh -o /tmp/clp-install.sh && bash /tmp/clp-install.sh'
            ;;
        aapanel)
            # shellcheck disable=SC2016  # $URL must expand at install time, not now
            printf '%s' 'cd /tmp || exit 1; URL="https://www.aapanel.com/script/install_panel_en.sh"; if command -v curl >/dev/null 2>&1; then curl -ksSO "$URL"; else wget --no-check-certificate -O install_panel_en.sh "$URL"; fi; bash install_panel_en.sh forum'
            ;;
        cyberpanel)
            printf '%s' 'sh <(curl -s https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)'
            ;;
        virtualmin)
            printf '%s' 'cd /tmp || exit 1; curl -sO https://software.virtualmin.com/install.sh && bash install.sh'
            ;;
        ispconfig)
            printf '%s' 'wget -qO- https://get.ispconfig.org | sh -s -- --interactive'
            ;;
        fastpanel)
            printf '%s' 'wget -q https://repo.fastpanel.direct/install_fastpanel.sh -O - | bash -'
            ;;
        cwp)
            local el="el9"
            case "$OS_TOKEN" in
                almalinux:8|rocky:8|centos:8|centos:7) el="el8" ;;
            esac
            [[ "$OS_TOKEN" == "centos:7" ]] && el="el7"
            printf '%s' "cd /usr/local/src || exit 1; wget -q http://centos-webpanel.com/cwp-${el}-latest && sh cwp-${el}-latest"
            ;;
        *)
            printf '%s' 'true'
            ;;
    esac
}

# ----------------------------------------------------------------------------
# Compatibility check  -> compatible <panel-id>  (0=yes, 1=no + COMPAT_REASON)
# ----------------------------------------------------------------------------
compatible() {
    local id="$1"
    COMPAT_REASON=""

    local found=0 t
    for t in ${P_OS[$id]}; do
        if [[ "$t" == "$OS_TOKEN" ]]; then found=1; break; fi
    done
    if [[ "$found" -eq 0 ]]; then
        COMPAT_REASON="OS $OS_PRETTY is not in the supported list"
        return 1
    fi

    found=0
    for t in ${P_ARCH[$id]}; do
        if [[ "$t" == "$ARCH_OK" ]]; then found=1; break; fi
    done
    if [[ "$found" -eq 0 ]]; then
        COMPAT_REASON="needs $(printf '%s' "${P_ARCH[$id]}" | tr ' ' '/'), you have $ARCH_OK"
        return 1
    fi

    if (( RAM_MB < P_MINRAM[$id] )); then
        COMPAT_REASON="needs at least $(( P_MINRAM[$id] / 1024 ))GB RAM, you have ${RAM_GB}GB"
        return 1
    fi
    if (( DISK_GB > 0 && DISK_GB < P_MINDISK[$id] )); then
        COMPAT_REASON="needs ${P_MINDISK[$id]}GB disk, you have ${DISK_GB}GB"
        return 1
    fi
    return 0
}

detect_installed_panels() {
    FOUND_PANELS=()
    local id
    for id in "${PANEL_IDS[@]}"; do
        if [[ -e "${P_MARKER[$id]}" ]]; then
            FOUND_PANELS+=("$id")
        fi
    done
}

# ----------------------------------------------------------------------------
# Recommendation engine
#   use_case: wp | node | email | business | learn
# ----------------------------------------------------------------------------
recommend() {
    local use_case="$1"
    REC_ID=""
    REC_REASON=""
    local id score best=-1 best_id="" best_why=""

    for id in "${PANEL_IDS[@]}"; do
        compatible "$id" || continue
        score=0
        local why=""

        # popularity / maturity base
        case "$id" in
            hestiacp|cloudpanel) score=$((score + 15)) ;;
            aapanel|cyberpanel)  score=$((score + 12)) ;;
            *)                   score=$((score + 8))  ;;
        esac

        # resource fit
        if (( RAM_MB >= P_RECRAM[$id] )); then
            score=$((score + 25)); why="perfect RAM fit (${RAM_GB}GB)"
        elif (( RAM_MB >= P_MINRAM[$id] * 2 )); then
            score=$((score + 15)); why="good RAM fit (${RAM_GB}GB)"
        else
            score=$((score + 5)); why="minimum RAM fit (${RAM_GB}GB)"
        fi
        (( CORES >= 2 )) && score=$((score + 10))

        # use-case fit
        case "$use_case:$id" in
            wp:cloudpanel)        score=$((score + 25)); why="best for WordPress/PHP" ;;
            wp:cyberpanel)        score=$((score + 25)); why="fastest PHP for WordPress" ;;
            wp:hestiacp)          score=$((score + 20)); why="great all-rounder for WP" ;;
            node:cloudpanel)      score=$((score + 30)); why="built-in Node.js/Python support" ;;
            node:aapanel)         score=$((score + 20)); why="good Node.js app support" ;;
            email:hestiacp)       score=$((score + 30)); why="full mail server + DNS built in" ;;
            email:virtualmin)     score=$((score + 22)); why="mature mail + DNS stack" ;;
            business:ispconfig)   score=$((score + 25)); why="true multi-server/reseller model" ;;
            business:virtualmin)  score=$((score + 22)); why="powerful accounts + scripting" ;;
            business:hestiacp)    score=$((score + 20)); why="reseller packages out of the box" ;;
            learn:aapanel)        score=$((score + 25)); why="easiest for a first server" ;;
            learn:hestiacp)       score=$((score + 20)); why="clean interface, big community" ;;
            learn:cloudpanel)     score=$((score + 18)); why="simplest modern interface" ;;
        esac

        # family-native boost
        if [[ "$OS_FAMILY" == "rhel" ]]; then
            case "$id" in cwp|aapanel) score=$((score + 8)) ;; esac
        else
            case "$id" in hestiacp|cloudpanel) score=$((score + 8)) ;; esac
        fi

        if (( score > best )); then
            best=$score
            best_id=$id
            best_why=$why
        fi
    done

    if [[ -n "$best_id" ]]; then
        REC_ID="$best_id"
        REC_REASON="scored ${best}/100 - ${best_why}, fits ${OS_PRETTY} / ${ARCH_OK} / ${RAM_GB}GB / ${CORES} core(s)"
        log "Recommendation for use-case '$use_case': $REC_ID ($REC_REASON)"
    fi
}

# ----------------------------------------------------------------------------
# UI layer: dialog > whiptail > plain
# ----------------------------------------------------------------------------
init_ui() {
    if command -v dialog >/dev/null 2>&1; then
        UI_BACKEND="dialog"
    elif command -v whiptail >/dev/null 2>&1; then
        UI_BACKEND="whiptail"
    else
        UI_BACKEND="plain"
        if [[ -t 0 && -t 1 ]] && confirm "Pretty menus not found. Install 'dialog' now? (recommended)"; then
            local pm; pm=$(pkg_manager)
            case "$pm" in
                apt) DEBIAN_FRONTEND=noninteractive apt-get install -y dialog >/dev/null 2>&1 ;;
                dnf) dnf install -y dialog >/dev/null 2>&1 ;;
                yum) yum install -y dialog >/dev/null 2>&1 ;;
            esac
            command -v dialog >/dev/null 2>&1 && UI_BACKEND="dialog"
        fi
    fi
    log "UI backend: $UI_BACKEND"
}

ui_menu() {
    local title="$1" prompt="$2"
    shift 2
    case "$UI_BACKEND" in
        dialog)
            dialog --stdout --clear --title "$title" --menu "$prompt" 22 78 14 "$@" 2>/dev/null
            ;;
        whiptail)
            whiptail --title "$title" --menu "$prompt" 22 78 14 "$@" 3>&1 1>&2 2>&3
            ;;
        *)
            local -a tags=() items=()
            while (($# >= 2)); do
                tags+=("$1"); items+=("$2")
                shift 2
            done
            local i c
            printf '\n%s== %s ==%s\n%s\n' "$C_BOLD" "$title" "$C_RESET" "$prompt"
            for i in "${!tags[@]}"; do
                printf '  %s%2d)%s %s\n' "$C_CYAN" "$((i + 1))" "$C_RESET" "${items[$i]}"
                printf '        %s(%s)%s\n' "$C_DIM" "${tags[$i]}" "$C_RESET"
            done
            while true; do
                printf 'Choose [1-%d] (q to quit): ' "${#tags[@]}"
                read -r c
                [[ "$c" =~ ^[Qq]$ ]] && return 1
                if [[ "$c" =~ ^[0-9]+$ ]] && (( c >= 1 && c <= ${#tags[@]} )); then
                    printf '%s' "${tags[$((c - 1))]}"
                    return 0
                fi
                printf 'Invalid choice, try again.\n'
            done
            ;;
    esac
}

ui_msg() {
    local title="$1" msg="$2"
    case "$UI_BACKEND" in
        dialog)  dialog --clear --title "$title" --msgbox "$msg" 20 78 2>/dev/null ;;
        whiptail) whiptail --title "$title" --msgbox "$msg" 20 78 2>/dev/null ;;
        *)
            printf '\n%s== %s ==%s\n%s\n' "$C_BOLD" "$title" "$C_RESET" "$msg"
            printf 'Press Enter to continue...'
            read -r _
            ;;
    esac
}

ui_yesno() {
    local title="$1" msg="$2"
    case "$UI_BACKEND" in
        dialog)  dialog --clear --title "$title" --yesno "$msg" 14 78 2>/dev/null ;;
        whiptail) whiptail --title "$title" --yesno "$msg" 14 78 2>/dev/null ;;
        *)
            printf '\n%s== %s ==%s\n%s\n[y/N]: ' "$C_BOLD" "$title" "$C_RESET" "$msg"
            local a
            read -r a
            [[ "$a" =~ ^[Yy] ]]
            ;;
    esac
}

ui_input() {
    local title="$1" prompt="$2" def="${3:-}"
    case "$UI_BACKEND" in
        dialog)  dialog --stdout --clear --title "$title" --inputbox "$prompt" 12 70 "$def" 2>/dev/null ;;
        whiptail) whiptail --title "$title" --inputbox "$prompt" 12 70 "$def" 3>&1 1>&2 2>&3 ;;
        *)
            printf '\n%s (default: %s): ' "$prompt" "$def"
            local a
            read -r a
            printf '%s' "${a:-$def}"
            ;;
    esac
}

ui_checklist() {
    local title="$1" prompt="$2"
    shift 2
    local out=""
    case "$UI_BACKEND" in
        dialog)
            out=$(dialog --stdout --separate-output --clear --title "$title" \
                    --checklist "$prompt" 22 78 10 "$@" 2>/dev/null)
            ;;
        whiptail)
            out=$(whiptail --title "$title" --checklist "$prompt" 22 78 10 "$@" \
                    3>&1 1>&2 2>&3)
            out=${out//\"/}
            ;;
        *)
            local -a tags=() items=()
            while (($# >= 2)); do
                tags+=("$1"); items+=("$2")
                shift 2
            done
            local i c picked=""
            printf '\n%s== %s ==%s\n%s\n' "$C_BOLD" "$title" "$C_RESET" "$prompt"
            for i in "${!tags[@]}"; do
                printf '  %s%2d)%s %s  %s(%s)%s\n' "$C_CYAN" "$((i + 1))" "$C_RESET" \
                    "${items[$i]}" "$C_DIM" "${tags[$i]}" "$C_RESET"
            done
            printf 'Pick numbers separated by spaces (empty = none): '
            read -r c
            for i in $c; do
                if [[ "$i" =~ ^[0-9]+$ ]] && (( i >= 1 && i <= ${#tags[@]} )); then
                    picked+=" ${tags[$((i - 1))]}"
                fi
            done
            out="${picked# }"
            ;;
    esac
    printf '%s' "$out"
}

ui_textbox() {
    local title="$1" file="$2"
    case "$UI_BACKEND" in
        dialog)  dialog --clear --title "$title" --textbox "$file" 0 0 2>/dev/null ;;
        whiptail) whiptail --title "$title" --scrolltext --textbox "$file" 24 78 2>/dev/null ;;
        *)
            cat "$file"
            printf '\nPress Enter to continue...'
            read -r _
            ;;
    esac
}

show_file_pretty() {
    local title="$1" file="$2"
    if [[ "$UI_BACKEND" == "plain" ]]; then
        cat "$file"
        printf '\nPress Enter to continue...'
        read -r _
    else
        ui_textbox "$title" "$file"
    fi
}

# ----------------------------------------------------------------------------
# System info screen
# ----------------------------------------------------------------------------
show_system_info() {
    local tmp; tmp=$(mktemp)
    {
        printf '=========== SYSTEM DETECTION ===========\n\n'
        printf ' OS          : %s\n' "$OS_PRETTY"
        printf ' Family      : %s\n' "$OS_FAMILY"
        printf ' Version tok : %s\n' "$OS_TOKEN"
        printf ' Architecture: %s (normalized: %s)\n' "$ARCH" "$ARCH_OK"
        printf ' RAM         : %s MB (%s GB)\n' "$RAM_MB" "$RAM_GB"
        printf ' CPU cores   : %s\n' "$CORES"
        printf ' Disk (/)    : %s GB\n' "$DISK_GB"
        printf ' Virt        : %s\n' "$VIRT"
        printf ' Public IP   : %s\n' "$PUB_IP"
        printf ' Pkg manager : %s\n' "$(pkg_manager)"
        printf ' Uptime      : %s\n' "$(uptime -p 2>/dev/null || uptime)"
        printf '\n----------- PANEL COMPATIBILITY ---------\n\n'
        local id mark reason
        for id in "${PANEL_IDS[@]}"; do
            if compatible "$id"; then
                mark="OK "
                reason="compatible"
            else
                mark="NO "
                reason="$COMPAT_REASON"
            fi
            printf ' [%s] %-16s %s - %s\n' "$mark" "${P_NAME[$id]}" "$reason" "${P_MINRAM[$id]}MB min"
        done
        printf '\n Installed panel(s): %s\n' \
            "${FOUND_PANELS[*]:-none detected}"
        printf '\n=========================================\n'
    } >"$tmp"
    show_file_pretty "System Detection" "$tmp"
    rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# Panel details (EN + Roman Urdu)
# ----------------------------------------------------------------------------
panel_details() {
    local id="$1" lang="$2" tmp
    tmp=$(mktemp)
    case "$lang:$id" in
        en:hestiacp) cat >"$tmp" <<'EOF'
===================== HESTIACP =====================
License : 100% Free (GPL)          Port : 8083
OS      : Debian 12/13, Ubuntu 22.04/24.04/26.04
Arch    : x86_64 + aarch64(ARM64)  RAM  : 1GB min / 4GB recommended

WHAT IT IS:
The most complete free cPanel alternative. One installer gives you
Nginx+Apache, MariaDB/PostgreSQL, a real mail server (Exim+Dovecot),
a BIND DNS server with custom nameservers, FTP, resellers, backups
and a file manager.

FEATURES: websites | email | DNS zones + DNSSEC | PostgreSQL &
MariaDB | FTP | resellers/packages | Let's Encrypt SSL | backups |
firewall + fail2ban | web terminal | REST API

PROS:
 + Truly 100% free, no "pro" traps, huge community
 + PostgreSQL support AND custom DNS out of the box
 + Full mail server - you can sell email hosting
 + Works on ARM64 servers (Hetzner, AWS Graviton, Oracle)
 + Clean beginner-friendly web interface

CONS:
 - Heavy: mail+DNS+antivirus need ~4GB RAM for full stack
 - No official uninstaller (use this script's Remove option)
 - Only Debian/Ubuntu - no AlmaLinux/Rocky
 - Default stack is Nginx+Apache combo (uses more RAM)

BEST FOR: hosting businesses, people who need email + PostgreSQL +
custom DNS, resellers, learners who want "everything".
EOF
        ;;
        ur:hestiacp) cat >"$tmp" <<'EOF'
===================== HESTIACP =====================
License : 100% Free (GPL)          Port : 8083
OS      : Debian 12/13, Ubuntu 22.04/24.04/26.04
Arch    : x86_64 + aarch64(ARM64)  RAM  : 1GB min / 4GB recommended

YE KYA HAI:
Ye free cPanel ka sab se mukammal alternative hai. Ek installer se
Nginx+Apache, MariaDB/PostgreSQL, asli mail server (Exim+Dovecot),
BIND DNS server (apne custom nameservers), FTP, reseller accounts,
backups aur file manager - sab kuch mil jata hai.

FEATURES: websites | email | DNS zones + DNSSEC | PostgreSQL &
MariaDB | FTP | reseller packages | Let's Encrypt SSL | backups |
firewall + fail2ban | web terminal | REST API

FAWADA (PROS):
 + Bilkul 100% free, koi "pro" trap nahi, bara community
 + PostgreSQL aur custom DNS dono shuru se maujood
 + Pura mail server - aap email hosting bech sakte hain
 + ARM64 servers par bhi chalta hai (Hetzner, AWS Graviton)
 + Saaf-suthra beginner-friendly interface

NUKSAAN (CONS):
 - Heavy: mail+DNS+antivirus ke liye ~4GB RAM chahiye
 - Official uninstaller nahi (is script ka Remove option use karein)
 - Sirf Debian/Ubuntu - AlmaLinux/Rocky par nahi
 - Nginx+Apache combo thoda zyada RAM khata hai

KIS KE LIYE: hosting business walon ke liye jinhein email, PostgreSQL
aur custom DNS chahiye, resellers, aur naye log jinhein sab kuch chahiye.
EOF
        ;;
        en:cloudpanel) cat >"$tmp" <<'EOF'
==================== CLOUDPANEL ====================
License : Free Community Edition   Port : 8443
OS      : Debian 11/12/13, Ubuntu 22.04/24.04/26.04
Arch    : x86_64 + aarch64(ARM64)  RAM  : 2GB min / 4GB recommended

WHAT IT IS:
A very lightweight, modern panel obsessed with simplicity. Stack:
nginx + Varnish cache (up to 250x faster pages, built in) + MariaDB
+ Redis. It supports PHP, Node.js, Python and Go sites side by side.

FEATURES: PHP sites | Node.js apps | Python apps | Go | MariaDB |
Varnish cache | Redis | free SSL | file manager | FTP/SFTP | CLI |
monitoring | 2FA | no mail server (use a mail service instead)

PROS:
 + Lightest modern interface - very low RAM/CPU overhead
 + Varnish built in = extremely fast WordPress/PHP pages
 + Node.js + Python + Go native support (rare for panels!)
 + Works on ARM64 VPS
 + Clean, developer-friendly UI

CONS:
 - No mail server (need external SMTP like Mailgun/SendGrid)
 - 2GB RAM minimum - too heavy for 512MB/1GB servers
 - No PostgreSQL (MariaDB/MySQL only)
 - Community Edition is source-available, not OSI-open-source

BEST FOR: PHP/WordPress shops, Node.js & Python apps, developers who
want speed and simplicity without email hosting.
EOF
        ;;
        ur:cloudpanel) cat >"$tmp" <<'EOF'
==================== CLOUDPANEL ====================
License : Free Community Edition   Port : 8443
OS      : Debian 11/12/13, Ubuntu 22.04/24.04/26.04
Arch    : x86_64 + aarch64(ARM64)  RAM  : 2GB min / 4GB recommended

YE KYA HAI:
Bohat halka-modern panel jo simplicity par focus karta hai. Stack:
nginx + Varnish cache (pages 250x tak tez, built-in) + MariaDB +
Redis. PHP, Node.js, Python aur Go sites ek saath chalti hain.

FEATURES: PHP sites | Node.js apps | Python apps | Go | MariaDB |
Varnish cache | Redis | free SSL | file manager | FTP/SFTP | CLI |
monitoring | 2FA | mail server nahi (kisi bahar ki mail service use karein)

FAWADA (PROS):
 + Sab se halka modern interface - RAM/CPU bahut kam khata
 + Varnish built-in = WordPress/PHP pages bahut tez
 + Node.js + Python + Go ka native support (panels mein rare!)
 + ARM64 VPS par bhi chalta hai
 + Saaf developer-friendly UI

NUKSAAN (CONS):
 - Mail server nahi (bahar ka SMTP chahiye jaise Mailgun/SendGrid)
 - 2GB RAM minimum - 512MB/1GB servers par theek nahi
 - PostgreSQL nahi (sirf MariaDB/MySQL)
 - Community Edition source-available hai, pura open-source nahi

KIS KE LIYE: PHP/WordPress wale, Node.js aur Python apps chalane
walay developers jo speed chahte hain bina email hosting ke.
EOF
        ;;
        en:aapanel) cat >"$tmp" <<'EOF'
===================== AAPANEL ======================
License : Free (Pro add-ons paid)  Port : dynamic (bt default)
OS      : Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky 8-10, CentOS 9+
Arch    : x86_64                    RAM  : 512MB min / 1GB recommended

WHAT IT IS:
The lowest-RAM full-featured panel - the pure panel itself uses only
~60MB RAM. Works on BOTH Debian-family and RHEL-family distros, so
it fits almost any VPS. One-click LNMP/LAMP installer, free WAF,
app store, WP Toolkit.

FEATURES: websites | MySQL/MariaDB | PostgreSQL | FTP | mail | file
manager | WAF (free) | app store | WP Toolkit | cron | monitoring |
Docker manager | Node.js projects | sub-accounts

PROS:
 + Only 512MB RAM needed - great for tiny/cheap VPS
 + Runs on Ubuntu, Debian, AlmaLinux AND Rocky
 + Free WAF (web firewall) included
 + Huge one-click app store, very beginner friendly
 + Lowest resource usage of all full panels

CONS:
 - Advanced features are paid "Pro" plugins (aapanel.com/pricing)
 - ARM64 support is unofficial/partial - use x86_64 VPS
 - Interface has ads/promos for paid modules
 - Smaller English community than Hestia/CyberPanel

BEST FOR: 1-2GB small VPS, AlmaLinux/Rocky users, beginners who want
the easiest start with minimum RAM.
EOF
        ;;
        ur:aapanel) cat >"$tmp" <<'EOF'
===================== AAPANEL ======================
License : Free (Pro add-ons paid)  Port : dynamic (bt default)
OS      : Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky 8-10, CentOS 9+
Arch    : x86_64                    RAM  : 512MB min / 1GB recommended

YE KYA HAI:
Sab se kam RAM wala full-featured panel - khud panel sirf ~60MB RAM
use karta hai. Debian-family aur RHEL-family dono tarah ke distros
par chalta hai, yaani har VPS par fit ho jata hai. One-click LNMP/LAMP, free
WAF, app store, WP Toolkit.

FEATURES: websites | MySQL/MariaDB | PostgreSQL | FTP | mail | file
manager | WAF (free) | app store | WP Toolkit | cron | monitoring |
Docker manager | Node.js projects | sub-accounts

FAWADA (PROS):
 + Sirf 512MB RAM chahiye - chhote/saste VPS ke liye best
 + Ubuntu, Debian, AlmaLinux aur Rocky - sab par chalta hai
 + Free WAF (web firewall) milta hai
 + Bara one-click app store, beginner ke liye asaan
 + Full panels mein sab se kam resource use

NUKSAAN (CONS):
 - Advanced cheezein paid "Pro" plugins hain (aapanel.com/pricing)
 - ARM64 support unofficial/partial - x86_64 VPS lein
 - Interface par paid modules ki promotion dikhti hai
 - English community Hestia/CyberPanel jitni bari nahi

KIS KE LIYE: 1-2GB chhote VPS, AlmaLinux/Rocky users, aur naye log
jo kam RAM mein asaani se start karna chahte hain.
EOF
        ;;
        en:cyberpanel) cat >"$tmp" <<'EOF'
==================== CYBERPANEL ====================
License : Free edition (Pro paid)  Port : 8090
OS      : Ubuntu 20.04/22.04/24.04, AlmaLinux/Rocky 8-9
Arch    : x86_64 only              RAM  : 1GB min / 2GB recommended

WHAT IT IS:
The speed-focused free panel built on OpenLiteSpeed - the open
edition of LiteSpeed web server, famous for the fastest PHP/WordPress
serving. Includes PowerDNS (custom nameservers), Redis, mail, FTP.

FEATURES: websites | OpenLiteSpeed | PowerDNS | MariaDB | Redis |
mail (Postfix+Dovecot) | FTP | free SSL | WordPress manager |
Docker manager | backups | resellers | CLI

PROS:
 + Fastest PHP/WordPress performance of any free panel
 + OpenLiteSpeed = HTTP/3, low memory, .htaccess support
 + PowerDNS included - easy custom nameservers
 + Unlimited domains on the free edition
 + Redis built in for object caching

CONS:
 - x86_64 only - does NOT work on ARM64 servers
 - No PostgreSQL (MariaDB only)
 - No Debian support (Ubuntu + Alma/Rocky only)
 - Official uninstaller missing (use this script's Remove option)

BEST FOR: high-traffic WordPress/PHP sites where raw speed matters.
EOF
        ;;
        ur:cyberpanel) cat >"$tmp" <<'EOF'
==================== CYBERPANEL ====================
License : Free edition (Pro paid)  Port : 8090
OS      : Ubuntu 20.04/22.04/24.04, AlmaLinux/Rocky 8-9
Arch    : x86_64 only              RAM  : 1GB min / 2GB recommended

YE KYA HAI:
Speed par bana free panel, OpenLiteSpeed ke upar - PHP/WordPress ki
sab se tez serving ke liye mashhoor. PowerDNS (custom nameservers),
Redis, mail aur FTP bhi shamil hai.

FEATURES: websites | OpenLiteSpeed | PowerDNS | MariaDB | Redis |
mail (Postfix+Dovecot) | FTP | free SSL | WordPress manager |
Docker manager | backups | resellers | CLI

FAWADA (PROS):
 + Kisi bhi free panel se tez PHP/WordPress performance
 + OpenLiteSpeed = HTTP/3, kam RAM, .htaccess support
 + PowerDNS built-in - custom nameservers banana aasan
 + Free edition par unlimited domains
 + Object caching ke liye Redis built-in

NUKSAAN (CONS):
 - Sirf x86_64 - ARM64 servers par NAHI chalta
 - PostgreSQL nahi (sirf MariaDB)
 - Debian support nahi (Ubuntu + Alma/Rocky only)
 - Official uninstaller nahi (is script ka Remove option use karein)

KIS KE LIYE: high-traffic WordPress/PHP sites jahan kachi speed
sab se important ho.
EOF
        ;;
        en:virtualmin) cat >"$tmp" <<'EOF'
=================== VIRTUALMIN GPL =================
License : 100% Free (GPL)          Port : 10000
OS      : Alma/Rocky 8-10, Debian 11/12, Ubuntu 20.04-24.04
Arch    : x86_64 + aarch64(ARM64)  RAM  : 1GB min / 2GB recommended

WHAT IT IS:
The oldest and most mature free hosting panel (based on Webmin).
Gives sysadmin-grade control: BIND DNS, mail, MySQL + PostgreSQL,
FTP, quotas, cron, and a huge module system.

FEATURES: websites | Apache/Nginx | MySQL + PostgreSQL | BIND DNS |
mail | FTP | quotas | backups | resellers | 100+ Webmin modules |
powerful CLI (virtualmin CLI)

PROS:
 + 100% free with NO paid edition at all
 + PostgreSQL + DNS + mail - full classic hosting stack
 + Works on RHEL family AND Debian family, incl. ARM64
 + Extremely powerful CLI for automation
 + 20+ years of development, very stable

CONS:
 - Interface feels old-fashioned compared to CloudPanel/aaPanel
 - Steeper learning curve for beginners
 - Installs many services by default (disable what you don't need)

BEST FOR: sysadmins, Debian/Alma users who want total control and
automation, free PostgreSQL hosting.
EOF
        ;;
        ur:virtualmin) cat >"$tmp" <<'EOF'
=================== VIRTUALMIN GPL =================
License : 100% Free (GPL)          Port : 10000
OS      : Alma/Rocky 8-10, Debian 11/12, Ubuntu 20.04-24.04
Arch    : x86_64 + aarch64(ARM64)  RAM  : 1GB min / 2GB recommended

YE KYA HAI:
Sab se purana aur mazboot free hosting panel (Webmin par mubni).
Sysadmin-level control deta hai: BIND DNS, mail, MySQL + PostgreSQL,
FTP, quotas, cron aur baray modules ka poora nizam.

FEATURES: websites | Apache/Nginx | MySQL + PostgreSQL | BIND DNS |
mail | FTP | quotas | backups | resellers | 100+ Webmin modules |
taqatwar CLI (virtualmin CLI)

FAWADA (PROS):
 + 100% free, koi paid edition hi nahi
 + PostgreSQL + DNS + mail - pura classic hosting stack
 + RHEL family aur Debian family dono, ARM64 bhi
 + Automation ke liye bohat taqatwar CLI
 + 20+ saal ka development, bohat stable

NUKSAAN (CONS):
 - Interface CloudPanel/aaPanel ke muqable purana lagta hai
 - Naye logon ke liye thoda mushkil seekhna
 - Default mein yeh bohat si services install kar deta hai (faltu wale band karein)

KIS KE LIYE: sysadmins, Debian/Alma users jo mukammal control aur
automation chahte hain, free PostgreSQL hosting.
EOF
        ;;
        en:ispconfig) cat >"$tmp" <<'EOF'
==================== ISPCONFIG =====================
License : 100% Free (GPL)          Port : 8080
OS      : Debian 11/12/13, Ubuntu 22.04/24.04 (+ARM64)
Arch    : x86_64 + aarch64(ARM64)  RAM  : 1GB min / 2GB recommended

WHAT IT IS:
A professional multi-server hosting panel - you can run web, DNS,
mail and database servers as separate machines controlled from one
interface. Classic choice for hosting companies.

FEATURES: websites | Apache/Nginx | MySQL + PostgreSQL | BIND DNS |
mail | FTP | resellers | packages/quotas | web installer for
WordPress etc. | multi-server cluster

PROS:
 + 100% free, no paid tiers
 + Real multi-server architecture (scale across machines)
 + PostgreSQL + DNS + mail included
 + ARM64 supported in the official auto-installer
 + Very configurable, standard Linux packages under the hood

CONS:
 - Setup is heavier/slower than CloudPanel/aaPanel
 - Interface is functional, not modern/pretty
 - No official uninstaller (use this script's Remove option)

BEST FOR: hosting businesses that plan to grow into clusters, and
anyone who wants a classic ISP-style setup.
EOF
        ;;
        ur:ispconfig) cat >"$tmp" <<'EOF'
==================== ISPCONFIG =====================
License : 100% Free (GPL)          Port : 8080
OS      : Debian 11/12/13, Ubuntu 22.04/24.04 (+ARM64)
Arch    : x86_64 + aarch64(ARM64)  RAM  : 1GB min / 2GB recommended

YE KYA HAI:
Professional multi-server hosting panel - web, DNS, mail aur database
servers alag-alag machines par chala kar aap ek hi interface se
control kar sakte hain. Hosting companies ki purani pasand.

FEATURES: websites | Apache/Nginx | MySQL + PostgreSQL | BIND DNS |
mail | FTP | resellers | packages/quotas | WordPress waghera ka web
installer | multi-server cluster

FAWADA (PROS):
 + 100% free, koi paid tier nahi
 + Asal multi-server architecture (machines ke darmiyan scale)
 + PostgreSQL + DNS + mail shamil
 + Official auto-installer mein ARM64 support
 + Bohat configurable, neeche standard Linux packages

NUKSAAN (CONS):
 - Setup CloudPanel/aaPanel ke muqable bhaari aur ahista hai
 - Interface kaam ka hai, modern/khoobsurat nahi
 - Official uninstaller nahi (is script ka Remove option use karein)

KIS KE LIYE: hosting businesses jinhein aage barh kar cluster banana
hai, aur jo koi classic ISP-style setup chahta hai.
EOF
        ;;
        en:fastpanel) cat >"$tmp" <<'EOF'
==================== FASTPANEL =====================
License : Free lifetime license    Port : 8888
OS      : Debian 9-12, Ubuntu 18.04-24.04, Alma/Rocky 8, CentOS 7
Arch    : x86_64                    RAM  : 1GB min / 2GB recommended

WHAT IT IS:
A modern, clean panel with a genuinely FREE license (personal AND
commercial). You get the license key by email after install. Ships
its own nginx build and MySQL version choice.

FEATURES: websites | nginx | MySQL (version choice) | mail | DNS |
SSL | backups | firewall | monitoring | one-click apps | CLI tool |
free license for commercial use

PROS:
 + Free license even for commercial/agency use
 + Very modern, clean and fast interface
 + Official uninstall command (rare!)
 + Works on Debian AND AlmaLinux/Rocky
 + HTTP/3 support

CONS:
 - x86_64 only (no ARM64)
 - Requires a free license activation by email
 - Smaller community than Hestia/CyberPanel
 - Must be installed on a completely fresh OS

BEST FOR: agencies/freelancers who need a clean commercial-friendly
panel without paying.
EOF
        ;;
        ur:fastpanel) cat >"$tmp" <<'EOF'
==================== FASTPANEL =====================
License : Free lifetime license    Port : 8888
OS      : Debian 9-12, Ubuntu 18.04-24.04, Alma/Rocky 8, CentOS 7
Arch    : x86_64                    RAM  : 1GB min / 2GB recommended

YE KYA HAI:
Modern, saaf-suthra panel jiska license BILKUL FREE hai (personal
AUR commercial). Install ke baad email se license key milti hai.
Apna nginx build aur MySQL version choose karne ka option.

FEATURES: websites | nginx | MySQL (version choice) | mail | DNS |
SSL | backups | firewall | monitoring | one-click apps | CLI tool |
commercial use ke liye free license

FAWADA (PROS):
 + Commercial/agency use ke liye bhi free license
 + Bohat modern, saaf aur tez interface
 + Official uninstall command hai (panels mein rare!)
 + Debian AND AlmaLinux/Rocky dono par chalta hai
 + HTTP/3 support

NUKSAAN (CONS):
 - Sirf x86_64 (ARM64 nahi)
 - Email se free license activation zaroori
 - Community Hestia/CyberPanel jitna bara nahi
 - Sirf bilkul fresh OS par hi install ho sakta hai

KIS KE LIYE: agencies/freelancers jinhe bina kisi paise ke
commercial-friendly saaf panel chahiye.
EOF
        ;;
        en:cwp) cat >"$tmp" <<'EOF'
================= CONTROL WEB PANEL =================
License : Free (Pro paid)          Port : 2030
OS      : AlmaLinux 8/9 (best), Rocky 8/9, CentOS 7/8/9
Arch    : x86_64 only              RAM  : 2GB min / 4GB recommended

WHAT IT IS:
An enterprise-grade free panel for the RHEL world (AlmaLinux/Rocky).
Focuses on security and advanced server management. Root logs into
the dashboard - it is a sysadmin tool with a GUI.

FEATURES: websites | Apache/Nginx | MariaDB | PHP versions selector |
mail | DNS | firewall + CSF | antivirus (ClamAV) | mod_security |
account packages | server monitoring

PROS:
 + Very strong security tooling (firewall, antivirus, ModSecurity)
 + Great PHP version selector for shared hosting
 + Best documented panel for AlmaLinux
 + Free core is genuinely usable

CONS:
 - RHEL family ONLY (no Ubuntu/Debian)
 - x86_64 only, 2GB RAM minimum (4GB recommended)
 - NO official uninstaller - official advice is "reinstall the OS"
   (our Remove feature does a careful best-effort cleanup)
 - Must run on a fresh OS with a static IP

BEST FOR: AlmaLinux/Rocky servers that host many PHP apps and need
hardened security.
EOF
        ;;
        ur:cwp) cat >"$tmp" <<'EOF'
================= CONTROL WEB PANEL =================
License : Free (Pro paid)          Port : 2030
OS      : AlmaLinux 8/9 (best), Rocky 8/9, CentOS 7/8/9
Arch    : x86_64 only              RAM  : 2GB min / 4GB recommended

YE KYA HAI:
RHEL duniya (AlmaLinux/Rocky) ke liye enterprise-grade free panel.
Security aur advanced server management par focus. Root dashboard par
login karta hai - ye GUI wala sysadmin tool hai.

FEATURES: websites | Apache/Nginx | MariaDB | PHP versions selector |
mail | DNS | firewall + CSF | antivirus (ClamAV) | mod_security |
account packages | server monitoring

FAWADA (PROS):
 + Bohat mazboot security tooling (firewall, antivirus, ModSecurity)
 + Shared hosting ke liye zabardast PHP version selector
 + AlmaLinux ke liye sab se behtar documentation
 + Free core bilkul usable hai

NUKSAAN (CONS):
 - Sirf RHEL family (Ubuntu/Debian nahi)
 - Sirf x86_64, 2GB RAM minimum (4GB recommended)
 - Official uninstaller NAHI - company kehti hai "OS reinstall karein"
   (is script ka Remove feature ehtiyat se best-effort cleanup karta hai)
 - Fresh OS aur static IP chahiye

KIS KE LIYE: AlmaLinux/Rocky servers jahan bohat PHP apps chalti hain
aur hardened security chahiye.
EOF
        ;;
        *) printf 'No details found.\n' >"$tmp" ;;
    esac
    show_file_pretty "${P_NAME[$id]} - Details" "$tmp"
    rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# Install flow
# ----------------------------------------------------------------------------
run_installer() {
    local id="$1"
    local cmd
    cmd=$(panel_install_cmd "$id")
    printf '\n'
    hr
    info "Running the official ${P_NAME[$id]} installer:"
    printf '  %s\n' "$cmd"
    hr
    log "Starting installer for $id: $cmd"
    if bash -c "$cmd"; then
        ok "Installer finished for ${P_NAME[$id]}."
        log "Installer finished for $id"
    else
        warn "Installer for ${P_NAME[$id]} returned a non-zero status."
        log "Installer for $id returned $?"
    fi
}

post_install_info() {
    local id="$1" tmp
    tmp=$(mktemp)
    {
        printf '=============== ALL DONE ===============\n\n'
        printf ' %s installed. Panel address:\n\n' "${P_NAME[$id]}"
        printf '   https://%s:%s\n\n' "${PUB_IP}" "${P_PORT[$id]}"
        printf ' NEXT STEPS:\n'
        case "$id" in
            hestiacp)
                printf '   - Login details were shown by the installer (and emailed).\n'
                printf '   - Forgot them? run:  v-change-user-password admin\n'
                printf '   - Open port 8083 in your cloud firewall/security group.\n'
                ;;
            cloudpanel)
                printf '   - Create your admin user at https://IP:8443 on first visit.\n'
                printf '   - Open port 8443 in your cloud firewall/security group.\n'
                ;;
            aapanel)
                printf '   - The installer printed your URL/username/password.\n'
                printf '   - Forgot them? run:  bt default   (change: bt 5)\n'
                printf '   - Open ports shown (usually 31750|888|80|443|21|20).\n'
                ;;
            cyberpanel)
                printf '   - Admin: https://IP:8090  user: admin\n'
                printf '   - Password was shown at the end of installation.\n'
                printf '   - Open port 8090 in your cloud firewall/security group.\n'
                ;;
            virtualmin)
                printf '   - Admin: https://IP:10000  user: root\n'
                printf '   - Uses your root password. Open port 10000 in the firewall.\n'
                ;;
            ispconfig)
                printf '   - Admin: https://IP:8080  (installer printed the password)\n'
                printf '   - Open port 8080 in your cloud firewall/security group.\n'
                ;;
            fastpanel)
                printf '   - Admin: https://IP:8888  user: fastuser\n'
                printf '   - Password was printed by the installer.\n'
                printf '   - First login asks for your email to issue a FREE license.\n'
                ;;
            cwp)
                printf '   - Admin: https://IP:2030  user: root\n'
                printf '   - CWP requires a REBOOT afterwards:  reboot\n'
                printf '   - Open port 2030 in your cloud firewall/security group.\n'
                ;;
        esac
        printf '\n IMPORTANT:\n'
        printf '   - Always change default passwords immediately.\n'
        printf '   - Open the panel port in your provider firewall too\n'
        printf '     (cloud security groups block ports before the OS does).\n'
        printf '   - Enable automatic backups if this server matters.\n'
        printf '\n Docs: %s\n' "${P_DOCS[$id]}"
        printf ' Log : %s\n' "$LOG_FILE"
        printf '=========================================\n'
    } >"$tmp"
    show_file_pretty "Installation finished" "$tmp"
    rm -f "$tmp"
}

install_flow() {
    local use_case
    use_case=$(ui_menu "What will you host?" \
        "Tell us your main use case - we will rank the panels for YOUR server." \
        wp      "WordPress / PHP websites" \
        node    "Node.js / Python / Go apps" \
        email   "Email + full hosting (mail, DNS, PostgreSQL)" \
        business "Hosting business / resellers / many sites" \
        learn   "Learning / my first server" \
        back    "<- Back to main menu")
    [[ -n "$use_case" ]] || return 0
    [[ "$use_case" == "back" ]] && return 0

    recommend "$use_case"

    local -a items=()
    local id
    if [[ -n "$REC_ID" ]]; then
        items+=("$REC_ID" "RECOMMENDED (${P_NAME[$REC_ID]}) - $REC_REASON")
    fi
    for id in "${PANEL_IDS[@]}"; do
        [[ "$id" == "$REC_ID" ]] && continue
        if compatible "$id"; then
            items+=("$id" "${P_NAME[$id]} - ${P_SHORT[$id]}")
        else
            items+=("$id" "NOT COMPATIBLE: ${P_NAME[$id]} - $COMPAT_REASON")
        fi
    done
    items+=("back" "<- Back to main menu")

    local choice
    choice=$(ui_menu "Install Website Control Panel" \
        "Panels are ordered: recommended first, then compatible, then incompatible." \
        "${items[@]}")
    [[ -n "$choice" ]] || return 0
    [[ "$choice" == "back" ]] && return 0
    id="$choice"

    panel_details "$id" "$LANG_PREF"

    if ! compatible "$id"; then
        ui_msg "Cannot install" "${P_NAME[$id]} cannot be installed here.\n\nReason: $COMPAT_REASON"
        return 0
    fi

    # Conflicts: another panel already present?
    detect_installed_panels
    if ((${#FOUND_PANELS[@]} > 0)); then
        ui_msg "Warning" "Panel(s) already detected on this server: ${FOUND_PANELS[*]}\n\nInstalling a second panel on the same server is NOT recommended.\nConsider using 'Remove Panel Cleanly' first, or reinstall the OS."
    fi

    if ! ui_yesno "Confirm installation" \
        "Install ${P_NAME[$id]} now?\n\nInstaller:\n$(panel_install_cmd "$id")\n\nNOTE: install on a FRESH server for best results.\nThe official interactive installer will start."; then
        info "Installation cancelled."
        return 0
    fi

    printf '\n'
    info "Preflight: ${OS_PRETTY} | ${ARCH_OK} | ${RAM_GB}GB RAM | ${CORES} core | ${DISK_GB}GB disk"
    run_installer "$id"
    post_install_info "$id"
}

# ----------------------------------------------------------------------------
# Removal flow (clean uninstall helpers)
# ----------------------------------------------------------------------------
step() { printf '  %s->%s %s\n' "$C_CYAN" "$C_RESET" "$*"; log "REMOVE: $*"; }

stop_services_by_pattern() {
    local pat="$1"
    command -v systemctl >/dev/null 2>&1 || return 0
    local svc
    while IFS= read -r svc; do
        [[ -z "$svc" ]] && continue
        step "Stopping $svc"
        systemctl stop "$svc" >/dev/null 2>&1 || true
        systemctl disable "$svc" >/dev/null 2>&1 || true
    done < <(systemctl list-units --all --no-legend --plain --type=service 2>/dev/null \
                | awk '{print $1}' | grep -E "$pat" || true)
}

pkg_purge() {
    local pm; pm=$(pkg_manager)
    case "$pm" in
        apt) step "Removing packages: $*"
             DEBIAN_FRONTEND=noninteractive apt-get -y purge "$@" >/dev/null 2>&1 || true ;;
        dnf) step "Removing packages: $*"
             dnf -y remove "$@" >/dev/null 2>&1 || true ;;
        yum) step "Removing packages: $*"
             yum -y remove "$@" >/dev/null 2>&1 || true ;;
    esac
}

remove_paths() {
    local p
    for p in "$@"; do
        if [[ -e "$p" ]]; then
            step "Deleting $p"
            rm -rf "$p" 2>/dev/null || true
        fi
    done
}

remove_user_if_exists() {
    local u="$1"
    if id "$u" >/dev/null 2>&1; then
        step "Removing user $u"
        pkill -u "$u" >/dev/null 2>&1 || true
        userdel -r "$u" >/dev/null 2>&1 || userdel "$u" >/dev/null 2>&1 || true
    fi
}

panel_remove() {
    local id="$1"
    printf '\n'
    hr
    info "Cleaning up ${P_NAME[$id]} ..."
    hr

    case "$id" in
        hestiacp)
            stop_services_by_pattern '^(hestia|nginx|apache2|httpd|php.*-fpm|exim4|dovecot|vsftpd|named)\.'
            pkg_purge 'hestia*'
            remove_paths /usr/local/hestia /etc/hestia /var/log/hestia /root/.hestia \
                         /etc/cron.d/hestia /tmp/hst-install.sh
            remove_user_if_exists "hestia"
            ;;
        cloudpanel)
            stop_services_by_pattern '^(cloudpanel|clp-nginx|nginx|varnish|php.*-fpm|mariadb|mysql|redis)\.'
            pkg_purge 'cloudpanel*'
            remove_paths /usr/local/cloudpanel /etc/systemd/system/cloudpanel.service \
                         /etc/update-motd.d/10-cloudpanel /tmp/clp-install.sh
            ;;
        aapanel)
            stop_services_by_pattern '^(bt|nginx|apache2|httpd|php.*-fpm|mysqld|mariadb|pure-ftpd)\.'
            if command -v service >/dev/null 2>&1; then
                step "Stopping aaPanel service (bt)"
                service bt stop >/dev/null 2>&1 || true
            fi
            remove_paths /etc/init.d/bt /www/server /www/wwwroot /www/backup \
                         /www/server/panel /tmp/install_panel_en.sh
            remove_user_if_exists "www"
            ;;
        cyberpanel)
            stop_services_by_pattern '^(lshttpd|lsws|powerdns|pdns|postfix|dovecot|pure-ftpd|mariadb|mysql|php.*-fpm|cyberpanel)\.'
            remove_paths /usr/local/CyberCP /usr/local/CyberPanel /usr/local/lsws \
                         /usr/local/CyberCP/cyberpanel.service /etc/systemd/system/cyberpanel.service
            remove_user_if_exists "cyberpanel"
            ;;
        virtualmin)
            stop_services_by_pattern '^(webmin|apache2|httpd|nginx|bind|named)\.'
            pkg_purge 'virtualmin*'
            remove_paths /usr/local/virtualmin /etc/webmin /etc/skel/.sync \
                         /usr/libexec/webmin /var/webmin
            ;;
        ispconfig)
            stop_services_by_pattern '^(nginx|apache2|httpd|php.*-fpm|named|dovecot|postfix|pure-ftpd|vsftpd)\.'
            remove_paths /usr/local/ispconfig /usr/local/ispconfig/interface/web
            ;;
        fastpanel)
            step "Using FastPanel's official uninstall command"
            local pm; pm=$(pkg_manager)
            case "$pm" in
                apt) DEBIAN_FRONTEND=noninteractive apt-get -y remove fastpanel2 fastpanel2-nginx >/dev/null 2>&1 || true ;;
                dnf|yum) "${pm}" -y remove fastpanel2 fastpanel2-nginx >/dev/null 2>&1 || true ;;
            esac
            remove_paths /usr/local/fastpanel2
            ;;
        cwp)
            warn "CWP has no official uninstaller (their advice: reinstall the OS)."
            step "Doing a careful best-effort cleanup instead."
            stop_services_by_pattern '^(cwpsrv|httpd|apache2|nginx|php.*-fpm|mariadb|mysql|named|pure-ftpd|postfix|cwp)\.'
            pkg_purge 'cwp*' 'cwphp*'
            remove_paths /usr/local/cwp /usr/local/directadmin /usr/local/src/cwp-el8-latest \
                         /usr/local/src/cwp-el9-latest /usr/local/src/cwp-el7-latest \
                         /etc/cwpsrv.conf /usr/local/cwpsrv
            ;;
    esac
    hr
    ok "${P_NAME[$id]} removal steps finished."
}

purge_web_stack() {
    printf '\n'
    warn "This removes the WEB STACK itself (web server, PHP, database, mail)."
    warn "Any websites living on this server will STOP working."
    if ! confirm "Really purge nginx/apache/php/database/mail packages?"; then
        return 0
    fi
    local pm; pm=$(pkg_manager)
    case "$pm" in
        apt)
            step "Purging web stack packages (apt)"
            DEBIAN_FRONTEND=noninteractive apt-get -y purge \
                nginx apache2 'php*' mariadb-server mysql-server postfix dovecot2 \
                dovecot-imapd dovecot-pop3d pure-ftpd vsftpd bind9 >/dev/null 2>&1 || true
            DEBIAN_FRONTEND=noninteractive apt-get -y autoremove >/dev/null 2>&1 || true
            ;;
        dnf|yum)
            step "Purging web stack packages ($pm)"
            "$pm" -y remove nginx httpd 'php*' mariadb mysql-server postfix dovecot \
                pure-ftpd vsftpd bind >/dev/null 2>&1 || true
            "$pm" -y autoremove >/dev/null 2>&1 || true
            ;;
    esac
    ok "Web stack purge finished."
}

verify_ports_free() {
    local port="$1"
    if command -v ss >/dev/null 2>&1; then
        if ss -lnt 2>/dev/null | grep -q ":${port}[[:space:]]"; then
            warn "Port $port is still open (something is still listening)."
        else
            ok "Port $port is closed."
        fi
    fi
}

remove_flow() {
    detect_installed_panels
    if ((${#FOUND_PANELS[@]} == 0)); then
        ui_msg "Nothing found" "No control panel was detected on this server.\n\n(Searched the standard install paths of all 8 supported panels.)"
        return 0
    fi

    local -a items=()
    local id
    for id in "${FOUND_PANELS[@]}"; do
        items+=("$id" "Remove ${P_NAME[$id]} (${P_MARKER[$id]})")
    done
    items+=("back" "<- Back")

    local choice
    choice=$(ui_menu "Remove Panel Cleanly" \
        "Detected panel(s): ${FOUND_PANELS[*]} - pick the one to remove." \
        "${items[@]}")
    [[ -n "$choice" && "$choice" != "back" ]] || return 0
    id="$choice"

    if ! ui_yesno "Backup first!" \
        "Remove ${P_NAME[$id]}?\n\n!! STOP !!\n1) Backup your website files AND databases first.\n2) The panel AND its services will be stopped and deleted.\n3) After removal, websites may need manual config.\n\nContinue?"; then
        info "Removal cancelled."
        return 0
    fi

    panel_remove "$id"

    printf '\n'
    if ui_yesno "Optional" \
        "Also purge the whole web stack (nginx/apache/PHP/database/mail)?\n\nChoose NO to keep the web server and databases installed\n(you may still need them for your sites)."; then
        purge_web_stack
    fi

    local tmp; tmp=$(mktemp)
    {
        printf '========= REMOVAL REPORT =========\n\n'
        printf ' Panel removed : %s\n' "${P_NAME[$id]}"
        printf ' Marker path   : %s -> %s\n' "${P_MARKER[$id]}" \
            "$([[ -e "${P_MARKER[$id]}" ]] && echo 'STILL PRESENT (!)' || echo 'gone')"
        printf '\n Panel port check:\n'
        if command -v ss >/dev/null 2>&1; then
            ss -lnt 2>/dev/null | awk 'NR==1 || /:(8083|8443|8090|8080|10000|8888|2030|888)[[:space:]]/'
        fi
        printf '\n Remaining panel markers:\n'
        detect_installed_panels
        if ((${#FOUND_PANELS[@]} == 0)); then
            printf '   none - server is panel-free.\n'
        else
            printf '   %s\n' "${FOUND_PANELS[*]}"
        fi
        printf '\n NOTE: run the Junk Cleaner from the main menu to\n'
        printf ' clear leftover package caches.\n'
        printf '==================================\n'
    } >"$tmp"
    show_file_pretty "Removal report" "$tmp"
    rm -f "$tmp"
    log "Removed panel: $id"
}

# ----------------------------------------------------------------------------
# Junk cleaner
# ----------------------------------------------------------------------------
disk_used_gb() {
    df -BG --output=used / 2>/dev/null | awk 'NR==2 {gsub(/G/,""); print $1}'
}

clean_items() {
    local clean_list="$1"
    local before after
    before=$(disk_used_gb)
    printf '\n'
    info "Disk used before cleaning: ${before}GB"

    local t
    # shellcheck disable=SC2086  # intentional word splitting of tag list
    for t in $clean_list; do
        case "$t" in
            pkgcache)
                local pm; pm=$(pkg_manager)
                case "$pm" in
                    apt) step "Cleaning apt cache"; apt-get clean >/dev/null 2>&1 || true ;;
                    dnf) step "Cleaning dnf cache"; dnf clean all >/dev/null 2>&1 || true ;;
                    yum) step "Cleaning yum cache"; yum clean all >/dev/null 2>&1 || true ;;
                esac
                ;;
            autoremove)
                local pm2; pm2=$(pkg_manager)
                case "$pm2" in
                    apt) step "Removing orphaned packages"; DEBIAN_FRONTEND=noninteractive apt-get -y autoremove >/dev/null 2>&1 || true ;;
                    dnf) step "Removing orphaned packages"; dnf -y autoremove >/dev/null 2>&1 || true ;;
                    yum) step "Removing orphaned packages"; yum -y autoremove >/dev/null 2>&1 || true ;;
                esac
                ;;
            journal)
                if command -v journalctl >/dev/null 2>&1; then
                    step "Trimming systemd journal to 200MB"
                    journalctl --vacuum-size=200M >/dev/null 2>&1 || true
                fi
                ;;
            oldlogs)
                step "Deleting old rotated logs (*.gz, *.1, *.2)"
                find /var/log -type f \( -name '*.gz' -o -name '*.1' -o -name '*.2' \) \
                    -delete 2>/dev/null || true
                ;;
            tmp)
                step "Deleting /tmp files older than 7 days"
                find /tmp -xdev -type f -mtime +7 -delete 2>/dev/null || true
                find /tmp -xdev -type d -empty -mtime +7 -delete 2>/dev/null || true
                ;;
            trash)
                if [[ -d /root/.local/share/Trash ]]; then
                    step "Emptying root's trash"
                    rm -rf /root/.local/share/Trash/* 2>/dev/null || true
                fi
                ;;
            kernels)
                if command -v package-cleanup >/dev/null 2>&1; then
                    step "Keeping only the 2 newest kernels"
                    package-cleanup --oldkernels --count=2 -y >/dev/null 2>&1 || true
                elif [[ "$(pkg_manager)" == "dnf" ]]; then
                    step "Installing yum-utils for kernel cleanup"
                    dnf install -y yum-utils >/dev/null 2>&1 || true
                    package-cleanup --oldkernels --count=2 -y >/dev/null 2>&1 || true
                else
                    step "kernel cleanup skipped (apt autoremove already handles it)"
                fi
                ;;
            docker)
                if command -v docker >/dev/null 2>&1; then
                    step "Pruning Docker images/build cache (volumes kept)"
                    docker system prune -af >/dev/null 2>&1 || true
                else
                    step "Docker not installed - skipped"
                fi
                ;;
            snap)
                if command -v snap >/dev/null 2>&1; then
                    step "Removing disabled/old snap revisions"
                    local sname srev
                    while read -r sname srev; do
                        [[ -z "$sname" || -z "$srev" ]] && continue
                        snap remove "$sname" --revision="$srev" >/dev/null 2>&1 || true
                    done < <(snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' || true)
                fi
                ;;
        esac
    done

    sync
    after=$(disk_used_gb)
    printf '\n'
    if [[ "$before" =~ ^[0-9]+$ && "$after" =~ ^[0-9]+$ ]]; then
        local freed=$(( before - after ))
        (( freed < 0 )) && freed=0
        ok "Disk used after cleaning: ${after}GB  (freed about ${freed}GB)"
    else
        ok "Cleaning finished."
    fi
    log "Cleaned: $clean_list (before=${before}GB after=${after}GB)"
}

clean_flow() {
    local picked
    picked=$(ui_checklist "Junk Cleaner" \
        "Select what to clean. Nothing touches your website files or databases." \
        pkgcache   "Package manager cache (apt/dnf)" \
        autoremove "Orphan / unused packages" \
        journal    "Systemd journal logs (trim to 200MB)" \
        oldlogs    "Old rotated logs (*.gz, *.1)" \
        tmp        "/tmp files older than 7 days" \
        trash      "Root user trash" \
        kernels    "Old kernels (keep 2 newest)" \
        docker     "Docker dangling images + build cache" \
        snap       "Old/disabled snap revisions")
    [[ -n "$picked" ]] || { info "Nothing selected."; return 0; }

    if ! ui_yesno "Confirm cleaning" \
        "Clean these items?\n\n$(printf '%s\n' "$picked" | tr ' ' '\n')"; then
        info "Cleaning cancelled."
        return 0
    fi
    clean_items "$picked"
    pause
}

clean_all_flow() {
    clean_items "pkgcache autoremove journal oldlogs tmp trash"
}

# ----------------------------------------------------------------------------
# Security hardening
# ----------------------------------------------------------------------------
security_flow() {
    local choice
    choice=$(ui_menu "Security Hardening" "Pick a hardening step:" \
        firewall "Setup firewall (ufw on Debian / firewalld on RHEL)" \
        fail2ban "Install & enable fail2ban (brute-force protection)" \
        autoupdate "Enable automatic security updates" \
        sshtips  "SSH security tips (keys, root login, port)" \
        all      "Do all of the above" \
        back     "<- Back")
    [[ -n "$choice" && "$choice" != "back" ]] || return 0

    [[ "$choice" == "all" || "$choice" == "firewall" ]] && sec_firewall
    [[ "$choice" == "all" || "$choice" == "fail2ban" ]] && sec_fail2ban
    [[ "$choice" == "all" || "$choice" == "autoupdate" ]] && sec_autoupdate
    [[ "$choice" == "sshtips" ]] && sec_ssh_tips
    [[ "$choice" == "all" ]] && sec_ssh_tips
    pause
}

sec_firewall() {
    local pm; pm=$(pkg_manager)
    case "$pm" in
        apt)
            step "Installing ufw"
            DEBIAN_FRONTEND=noninteractive apt-get install -y ufw >/dev/null 2>&1 || true
            step "Default: deny incoming / allow outgoing"
            ufw default deny incoming >/dev/null 2>&1 || true
            ufw default allow outgoing >/dev/null 2>&1 || true
            step "Allowing OpenSSH (port 22)"
            ufw allow OpenSSH >/dev/null 2>&1 || ufw allow 22/tcp >/dev/null 2>&1 || true
            step "Enabling ufw"
            ufw --force enable >/dev/null 2>&1 || true
            ufw status | head -12
            ;;
        dnf|yum)
            step "Installing firewalld"
            "$pm" -y install firewalld >/dev/null 2>&1 || true
            step "Enabling firewalld"
            systemctl enable --now firewalld >/dev/null 2>&1 || true
            step "Allowing ssh service in firewalld"
            firewall-cmd --permanent --add-service=ssh >/dev/null 2>&1 || true
            firewall-cmd --reload >/dev/null 2>&1 || true
            firewall-cmd --list-all 2>/dev/null || true
            ;;
        *)
            warn "Unknown package manager - configure your firewall manually."
            ;;
    esac
    warn "If you installed a panel, allow its port too (see post-install info)."
    warn "Cloud providers (AWS/GCP/Vultr...) also have SEPARATE security groups!"
    ok "Firewall step finished."
}

sec_fail2ban() {
    local pm; pm=$(pkg_manager)
    case "$pm" in
        apt)
            step "Installing fail2ban"
            DEBIAN_FRONTEND=noninteractive apt-get install -y fail2ban >/dev/null 2>&1 || true
            ;;
        dnf|yum)
            step "Installing fail2ban (EPEL)"
            "$pm" -y install epel-release >/dev/null 2>&1 || true
            "$pm" -y install fail2ban >/dev/null 2>&1 || true
            ;;
    esac
    if command -v fail2ban-client >/dev/null 2>&1; then
        if [[ ! -f /etc/fail2ban/jail.local ]]; then
            step "Creating /etc/fail2ban/jail.local (ssh jail enabled)"
            cat >/etc/fail2ban/jail.local <<'JAIL'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled = true
port    = ssh
JAIL
        fi
        step "Enabling and starting fail2ban"
        systemctl enable --now fail2ban >/dev/null 2>&1 || true
        systemctl restart fail2ban >/dev/null 2>&1 || true
        ok "fail2ban is running: $(systemctl is-active fail2ban 2>/dev/null || echo unknown)"
    else
        warn "fail2ban installation could not be verified."
    fi
}

sec_autoupdate() {
    local pm; pm=$(pkg_manager)
    case "$pm" in
        apt)
            step "Installing unattended-upgrades"
            DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades >/dev/null 2>&1 || true
            if command -v dpkg-reconfigure >/dev/null 2>&1; then
                step "Enabling unattended-upgrades"
                echo unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections 2>/dev/null || true
                DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive unattended-upgrades >/dev/null 2>&1 || true
            fi
            ok "Automatic security updates enabled (apt)."
            ;;
        dnf)
            step "Installing dnf-automatic"
            dnf -y install dnf-automatic >/dev/null 2>&1 || true
            if [[ -f /etc/dnf/automatic.conf ]]; then
                sed -i 's/^apply_updates = .*/apply_updates = yes/' /etc/dnf/automatic.conf 2>/dev/null || true
            fi
            systemctl enable --now dnf-automatic.timer >/dev/null 2>&1 || true
            ok "Automatic security updates enabled (dnf-automatic)."
            ;;
        yum)
            warn "CentOS 7: consider moving to AlmaLinux 9 (CentOS 7 is EOL)."
            yum -y install yum-cron >/dev/null 2>&1 || true
            systemctl enable --now yum-cron >/dev/null 2>&1 || true
            ;;
        *)
            warn "Unknown package manager - enable auto updates manually."
            ;;
    esac
}

sec_ssh_tips() {
    local tmp; tmp=$(mktemp)
    cat >"$tmp" <<'EOF'
================= SSH SECURITY TIPS =================

1) USE SSH KEYS instead of passwords (best protection):
   On YOUR computer (not the server):
       ssh-keygen -t ed25519
       ssh-copy-id root@YOUR_SERVER_IP
   Then disable password login in /etc/ssh/sshd_config:
       PasswordAuthentication no
   Then restart ssh:  systemctl restart sshd

2) NEVER allow root login with password.
   In /etc/ssh/sshd_config:   PermitRootLogin prohibit-password

3) Consider a non-root admin user:
       adduser hayder
       usermod -aG sudo hayder        # Debian/Ubuntu
       usermod -aG wheel hayder       # AlmaLinux/Rocky
   Then disable password auth (tip 1) and use:  ssh hayder@IP

4) Changing the SSH port (22 -> something else) reduces noise from
   bots, but is NOT a real security control. Keys matter more.

5) Keep the system updated (menu -> System Update & Upgrade).

6) fail2ban + firewall (previous menu options) complete the picture.

Real-world example:
   A password is like leaving your shop key under the doormat -
   bots will find it. A key pair is like changing the lock so only
   YOUR key opens it, and nobody can brute-force a key that is
   never sent over the network.

====================================================
EOF
    show_file_pretty "SSH Security Tips" "$tmp"
    rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# Status dashboard & system update
# ----------------------------------------------------------------------------
status_flow() {
    local tmp; tmp=$(mktemp)
    {
        printf '============ SERVER STATUS ============\n\n'
        printf ' Host      : %s\n' "$(hostname 2>/dev/null || echo unknown)"
        printf ' OS        : %s\n' "$OS_PRETTY"
        printf ' Uptime    : %s\n' "$(uptime -p 2>/dev/null || uptime)"
        printf ' Load      : %s\n' "$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || echo n/a)"
        printf ' CPU cores : %s\n' "$CORES"
        printf '\n-- Memory -----------------------------\n'
        free -h 2>/dev/null || awk '/MemTotal|MemAvailable|SwapTotal/ {print}' /proc/meminfo
        printf '\n-- Disk --------------------------------\n'
        df -hT -x tmpfs -x devtmpfs 2>/dev/null | head -10
        printf '\n-- Listening ports ----------------------\n'
        if command -v ss >/dev/null 2>&1; then
            ss -lntup 2>/dev/null | head -20
        else
            netstat -lntup 2>/dev/null | head -20
        fi
        printf '\n-- Failed services (if any) ------------\n'
        systemctl --failed --no-legend 2>/dev/null | head -10 || echo " (none or no systemd)"
        printf '\n-- Control panel -----------------------\n'
        detect_installed_panels
        if ((${#FOUND_PANELS[@]} == 0)); then
            printf ' No panel detected.\n'
        else
            local id
            for id in "${FOUND_PANELS[@]}"; do
                printf ' %s -> https://%s:%s\n' "${P_NAME[$id]}" "$PUB_IP" "${P_PORT[$id]}"
            done
        fi
        printf '\n-- Top 5 processes by memory -----------\n'
        ps -eo comm,%mem,%cpu --sort=-%mem 2>/dev/null | head -6
        printf '\n========================================\n'
    } >"$tmp"
    show_file_pretty "Server Status" "$tmp"
    rm -f "$tmp"
}

update_flow() {
    if ! ui_yesno "System update" "Update & upgrade ALL system packages now?\n\nThis can take several minutes."; then
        return 0
    fi
    local pm; pm=$(pkg_manager)
    case "$pm" in
        apt)
            step "apt-get update"
            apt-get update >/dev/null 2>&1 || true
            step "apt-get upgrade (this may take a while)"
            DEBIAN_FRONTEND=noninteractive apt-get -y upgrade >/dev/null 2>&1 || true
            ;;
        dnf)
            step "dnf update (this may take a while)"
            dnf -y update >/dev/null 2>&1 || true
            ;;
        yum)
            step "yum update (this may take a while)"
            yum -y update >/dev/null 2>&1 || true
            ;;
        *)
            warn "Unknown package manager."
            ;;
    esac
    ok "System update finished."
    if needs_reboot; then
        warn "A reboot is recommended (kernel/libc updated)."
    fi
    pause
}

needs_reboot() {
    if [[ -f /var/run/reboot-required || -f /var/run/reboot-required.pkgs ]]; then
        return 0
    fi
    if command -v needs-restarting >/dev/null 2>&1; then
        needs-restarting -r >/dev/null 2>&1 || return 0
    fi
    return 1
}

# ----------------------------------------------------------------------------
# Built-in beginner guide (English + Roman Urdu)
# ----------------------------------------------------------------------------
guide_file() {
    local lang="$1" tmp
    tmp=$(mktemp)
    if [[ "$lang" == "ur" ]]; then
        cat >"$tmp" <<'EOF'
================================================================
     VPS WEBHOSTER - BEGINNER GUIDE (ROMAN URDU)
     Banaya: Hayder        Version: 1.0.0
================================================================

1) VPS KYA HAI?
----------------------------------------------------------------
VPS (Virtual Private Server) ek chhota sa computer hai jo internet
par 24 ghante chalta hai. Aap use apne laptop/PC se SSH ke zariye
control karte hain. Example: aap Karachi mein baithe hain aur aapka
server Frankfurt mein hai - phir bhi aap usay chala sakte hain.

2) WEBSITE CONTROL PANEL KYA HAI?
----------------------------------------------------------------
Control panel ek WEBSITE (browser) wala remote control hai. Aap
browser mein kholte hain aur mouse se website banana, database
banana, SSL lagana, email banana - sab kuch click-click ho jata hai.

Real-world misaal: Aapki car ka remote jaise aap door kholte hain
bagair kisi technical kaam ke - theek waise hi control panel aapke
server ka "remote" hai jo har kaam button bana deta hai.

Example: Aap WordPress lagana chahte hain. Panel ke andar
"Websites -> Add -> WordPress install" - 1 click, bas ho gaya.

3) SSH KYA HAI?
----------------------------------------------------------------
SSH (Secure Shell) ek COMMAND ke zariye server tak pohanchne ka
tareeqa hai. Aap terminal/PuTTY mein likhte hain: "ls" (files dekho),
"nano index.php" (file edit karo) - yani har kaam typing se hota hai.

Real-world misaal: SSH aapke server ka "chabi wala darwaza" hai -
aap andar ja kar khud har cheez chhed sakte hain. Control panel
hotel ki reception desk hai jahan aap sirf request karte hain.

4) DONO MEIN FARQ (Control Panel vs SSH)
----------------------------------------------------------------
| Cheez          | Control Panel         | SSH                  |
|----------------|-----------------------|----------------------|
| Tareeqa        | Browser + mouse       | Terminal + typing    |
| Seekhna        | Aasan (1 din)         | Mushkil (haftay)     |
| Speed          | Click-click           | Bahut tez (expert)   |
| Control        | Limited jo panel de   | Poora server aapka   |
| Risk           | Kam (safe buttons)    | Zyada (galat command)|
| Kaun use kare  | Blogger, shop owner   | Developer, sysadmin  |
| Resources      | Panel RAM khata hai   | Zero extra cost      |

5) ASAL DUNIYA KE MISAALEN
----------------------------------------------------------------
(a) Amaan ek photographer hain, unko sirf apni portfolio site
    chalani hai. Unko Linux ya command nahi aati → CONTROL PANEL
    (aaPanel/CloudPanel) lagaya, WordPress install kiya, ho gaya.

(b) Bilal developer hain, har raat code deploy karte hain aur
    scripts likhte hain → SSH unka asal kaam hai; panel sirf
    databases/SSL dekhne ke liye.

(c) Sara ki hosting company hai, 50 clients ki sites chalni hain →
    reseller panel (HestiaCP/ISPConfig) + SSH for maintenance.

(d) Kam RAM wala 1GB VPS hai → panel choose karte waqt RAM dekhein
    (aaPanel 512MB se chalta hai). Yahi is script ka kaam hai.

6) IS SCRIPT KA TAREEKA-E-KAR
----------------------------------------------------------------
   sudo bash vps-webhoster.sh
   -> Pehle system detection screen dikhegi (OS, RAM, CPU, arch)
   -> "Install Website Control Panel" choose karein
   -> Poochega "What will you host?" - apna case batayein
   -> Top par RECOMMENDED panel milega wajah ke saath
   -> Official installer chalega, aap sirf Enter dabate rahein
   -> Install ke baad panel URL + password screen par aayega

7) JUNK CLEANER KYA KARTA HAI?
----------------------------------------------------------------
Package cache, faltu packages, purane logs, journal, /tmp ki purani
files, trash aur purane kernels saaf karta hai - DISK pehle/baad
batata hai kitni jagah khali hui. Aapki WEBSITE FILES aur DATABASES
kabhi nahi chhoota.

8) REMOVE PANEL CLEANLY KYA KARTA HAI?
----------------------------------------------------------------
Panel ki services band karta hai, packages aur files delete karta
hai, users hata deta hai, ports check karta hai. Aap pooch sakte
hain ke poora web stack (nginx/apache/mysql) bhi utaarein ya na.
ZAROORI: Pehle backup lein!

9) PEHLA KAAM (INSTALL KE BAAD)
----------------------------------------------------------------
   1. Panel ka port apne cloud firewall/security group mein kholein
   2. Default password FORAN badlein
   3. Auto-update aur firewall (menu ke Security options) chalu karein
   4. Backup schedule set karein
   5. Panel ke andar pehli website/WordPress add karein

10) ZAROORI ALFAAZ (GLOSSARY)
----------------------------------------------------------------
- VPS      : aapka chhota sa 24/7 server
- SSH      : terminal se server control karne ka secure tareeqa
- Panel    : browser wala server remote control
- Nginx/Apache : web server jo pages serve karta hai
- MySQL/MariaDB : database jahan data store hota hai
- PostgreSQL : aur advanced SQL database (Hestia/ISPConfig/Virtualmin)
- DNS      : domain ko IP se jorna (panel apna DNS server bhi chalata hai)
- SSL/HTTPS: green lock, encryption (Let's Encrypt free hai)
- Varnish/Redis : caching - site ko tez banate hain
- Firewall : bahar se aane wale traffic ki security gate
- fail2ban : brute-force attackers ko automatically ban karta hai
- RAM/CPU  : server ki memory aur processor - panel chunne mein matter
             karta hai

--------------------------------------------------------------
 "Pehle samjho, phir chalao." - Har command se pehle sochein.
 Made by Hayder. Documentation: docs/ur/ folder mein mukammal.
============================================================
EOF
    else
        cat >"$tmp" <<'EOF'
================================================================
     VPS WEBHOSTER - BEGINNER GUIDE (ENGLISH)
     Made by Hayder        Version: 1.0.0
================================================================

1) WHAT IS A VPS?
----------------------------------------------------------------
A VPS (Virtual Private Server) is a small computer that runs 24/7
in a datacenter. You control it from your own laptop through SSH.
Example: you sit in London, your server runs in Frankfurt - you
still fully control it.

2) WHAT IS A WEBSITE CONTROL PANEL?
----------------------------------------------------------------
A control panel is a BROWSER-BASED remote control for your server.
You click buttons to create websites, databases, SSL certificates
and email - no commands needed.

Real-world example: like a TV remote - you change channels without
touching the wiring inside the TV. The panel turns every server
task into a button.

Practical example: you want WordPress installed. In the panel:
"Websites -> Add -> WordPress" - one click, done.

3) WHAT IS SSH?
----------------------------------------------------------------
SSH (Secure Shell) is a SECURE way to reach your server with a
terminal. You TYPE everything: "ls" to list files,
"nano index.php" to edit a file, "systemctl restart nginx" to
restart the web server.

Real-world example: SSH is the door with a key - you walk in and
touch everything yourself. The control panel is the hotel reception
desk - you just make requests and they handle it.

4) THE DIFFERENCE: CONTROL PANEL vs SSH
----------------------------------------------------------------
| Aspect        | Control Panel        | SSH                  |
|---------------|----------------------|----------------------|
| How           | Browser + mouse      | Terminal + typing    |
| Learning      | Easy (one day)       | Harder (weeks)       |
| Speed         | Click-by-click       | Very fast (experts)  |
| Control       | Only what panel gives| The entire server    |
| Risk          | Lower (safe buttons) | Higher (typos hurt)  |
| Best for      | Bloggers, shop owners| Developers, admins   |
| Cost          | Uses some RAM        | No extra cost        |

5) REAL-WORLD SCENARIOS
----------------------------------------------------------------
(a) Amaan is a photographer who just needs a portfolio site and
    does not know Linux → CONTROL PANEL (aaPanel/CloudPanel),
    install WordPress, done.

(b) Bilal is a developer who deploys code every night and writes
    scripts → SSH is his daily work; the panel is only there to
    peek at databases and SSL.

(c) Sara runs a hosting company with 50 client sites → reseller
    panel (HestiaCP/ISPConfig) + SSH for maintenance.

(d) Your VPS has only 1GB RAM → RAM matters when picking a panel
    (aaPanel runs from 512MB). That is exactly what this script
    checks for you.

6) HOW THIS SCRIPT WORKS
----------------------------------------------------------------
   sudo bash vps-webhoster.sh
   -> Detection screen first (OS, RAM, CPU, architecture)
   -> Choose "Install Website Control Panel"
   -> Answer "What will you host?"
   -> The RECOMMENDED panel appears on top with the reason
   -> The official installer runs; you just follow its prompts
   -> After install, the panel URL + credentials are shown

7) WHAT DOES THE JUNK CLEANER DO?
----------------------------------------------------------------
It clears package caches, orphan packages, old logs, the systemd
journal, /tmp files older than 7 days, trash and old kernels -
and reports disk space before/after. It NEVER touches your website
files or databases.

8) WHAT DOES "REMOVE PANEL CLEANLY" DO?
----------------------------------------------------------------
It stops the panel's services, removes packages, files, users,
then verifies the ports are closed. Optionally purges the whole
web stack (nginx/apache/mysql). ALWAYS BACK UP FIRST.

9) FIRST STEPS AFTER INSTALLING A PANEL
----------------------------------------------------------------
   1. Open the panel port in your CLOUD firewall/security group
   2. Change the default password IMMEDIATELY
   3. Turn on firewall + auto-updates (Security menu)
   4. Set up a backup schedule
   5. Add your first website / WordPress from inside the panel

10) KEY WORDS (GLOSSARY)
----------------------------------------------------------------
- VPS        : your tiny 24/7 server
- SSH        : secure terminal access to the server
- Panel      : browser-based server remote control
- Nginx/Apache : the web server that serves pages
- MySQL/MariaDB : the database that stores your data
- PostgreSQL : an advanced SQL database (Hestia/ISPConfig/Virtualmin)
- DNS        : connects a domain name to an IP address
- SSL/HTTPS  : the green lock, encryption (Let's Encrypt = free)
- Varnish/Redis : caching - makes sites much faster
- Firewall   : the security gate for incoming traffic
- fail2ban   : auto-bans brute-force attackers
- RAM/CPU    : memory & processor - they decide which panel fits

--------------------------------------------------------------
 "Understand first, then run." - Think before every command.
 Made by Hayder. Full documentation lives in docs/en/.
============================================================
EOF
    fi
    printf '%s' "$tmp"
}

guide_flow() {
    local tmp
    tmp=$(guide_file "$LANG_PREF")
    show_file_pretty "Beginner Guide ($LANG_PREF)" "$tmp"
    rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# Details / settings / about
# ----------------------------------------------------------------------------
details_flow() {
    local -a items=()
    local id
    for id in "${PANEL_IDS[@]}"; do
        items+=("$id" "${P_NAME[$id]} - ${P_LICENSE[$id]}")
    done
    items+=("compare" "Side-by-side comparison table" "back" "<- Back")
    local choice
    choice=$(ui_menu "Panel Details & Comparison" \
        "Pick a panel to see features, pros and cons (in your language)." \
        "${items[@]}")
    [[ -n "$choice" ]] || return 0
    case "$choice" in
        back)    return 0 ;;
        compare) comparison_table ;;
        *)       panel_details "$choice" "$LANG_PREF" ;;
    esac
}

comparison_table() {
    local tmp; tmp=$(mktemp)
    {
        printf '================ COMPARISON ================\n\n'
        printf '%-14s %-9s %-9s %-8s %-7s %s\n' \
            "PANEL" "MIN-RAM" "PORT" "ARCH" "FAMILY" "LICENSE"
        printf '%s\n' "----------------------------------------------------------------------"
        local id
        for id in "${PANEL_IDS[@]}"; do
            local fam
            fam=$(printf '%s' "${P_OS[$id]}" | tr ' ' '\n' | cut -d: -f1 | sort -u | tr '\n' ',' | sed 's/,$//')
            printf '%-14s %-9s %-9s %-8s %-7s %s\n' \
                "${P_NAME[$id]}" "$(( ${P_MINRAM[$id]} / 1024 ))GB" \
                "${P_PORT[$id]}" \
                "$([[ ${P_ARCH[$id]} == *aarch64* ]] && echo 'x86+ARM' || echo 'x86')" \
                "$fam" "${P_LICENSE[$id]}"
        done
        printf '\nSupport on THIS server:\n\n'
        for id in "${PANEL_IDS[@]}"; do
            if compatible "$id"; then
                printf '  [OK] %-24s %s\n' "${P_NAME[$id]}" "${P_SHORT[$id]}"
            else
                printf '  [--] %-24s no: %s\n' "${P_NAME[$id]}" "$COMPAT_REASON"
            fi
        done
        printf '\n===========================================\n'
    } >"$tmp"
    show_file_pretty "Comparison" "$tmp"
    rm -f "$tmp"
}

settings_flow() {
    local choice
    choice=$(ui_menu "Language & Settings" \
        "Guide language is remembered for next time." \
        en "Guide language: English" \
        ur "Guide language: Roman Urdu (اردو)" \
        logs "Show log file location" \
        back "<- Back")
    case "$choice" in
        en|ur)
            LANG_PREF="$choice"
            save_settings
            ok "Guide language set to: $choice"
            pause
            ;;
        logs)
            ui_msg "Logs" "Log file: $LOG_FILE\n(if not writable, fallback: /tmp/vps-webhoster-$(id -u).log)\n\nSettings file: $SETTINGS_FILE"
            ;;
    esac
}

about() {
    local tmp; tmp=$(mktemp)
    cat >"$tmp" <<EOF
==============================================================
|   V P S   W E B H O S T E R                                |
|   Free Website Control Panel Installer & Server Toolkit    |
==============================================================

 Version   : $SCRIPT_VERSION
 Author    : $SCRIPT_AUTHOR  (made with care for beginners)
 License   : MIT - free to use, share and modify
 Repository: $REPO_URL
 Log file  : $LOG_FILE

 What this script is:
   A helper for people who just bought a VPS and want a website
   control panel without reading 50 tutorials. It detects your
   server, recommends the best FREE panel, runs the official
   installer, cleans junk, hardens security and can remove panels
   cleanly afterwards.

 Panels supported (all free or freemium):
   HestiaCP, CloudPanel, aaPanel, CyberPanel,
   Virtualmin GPL, ISPConfig, FastPanel, CWP

 Paid panels like cPanel, Plesk and DirectAdmin are NOT included
 on purpose - this project is 100% free.

 Docs (English + Roman Urdu): see the docs/ folder on GitHub.

==============================================================
EOF
    show_file_pretty "About" "$tmp"
    rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# Main menu
# ----------------------------------------------------------------------------
main_menu() {
    local choice
    while true; do
        detect_installed_panels
        choice=$(ui_menu "$SCRIPT_NAME v$SCRIPT_VERSION - Made by $SCRIPT_AUTHOR" \
            "Detected: $OS_PRETTY | $ARCH_OK | ${RAM_GB}GB RAM | ${CORES} core(s)${FOUND_PANELS:+ | panel: ${FOUND_PANELS[*]}}" \
            info     "System Detection & Info" \
            install  "Install Website Control Panel (recommended on top)" \
            details  "Panel Details, Pros/Cons & Comparison" \
            remove   "Remove Panel Cleanly" \
            clean    "Junk Cleaner (free disk space)" \
            security "Security Hardening (firewall, fail2ban, updates)" \
            status   "Server Status Dashboard" \
            update   "System Update & Upgrade" \
            guide    "Beginner Guide (English / Roman Urdu)" \
            settings "Language & Settings" \
            about    "About / Credits" \
            exit     "Exit")

        case "$choice" in
            info)     show_system_info ;;
            install)  install_flow ;;
            details)  details_flow ;;
            remove)   remove_flow ;;
            clean)    clean_flow ;;
            security) security_flow ;;
            status)   status_flow ;;
            update)   update_flow ;;
            guide)    guide_flow ;;
            settings) settings_flow ;;
            about)    about ;;
            exit|"")  printf '\nGoodbye, %s! Stay safe.\n\n' "$SCRIPT_AUTHOR"; break ;;
        esac
    done
}

# ----------------------------------------------------------------------------
# CLI argument parsing
# ----------------------------------------------------------------------------
parse_args() {
    while (($#)); do
        case "$1" in
            --install)
                CLI_ACTION="install"; CLI_ARG="${2:-}"
                [[ -z "$CLI_ARG" ]] && { err "--install needs a panel id"; exit 1; }
                shift 2
                ;;
            --remove)
                CLI_ACTION="remove"; CLI_ARG="${2:-}"
                [[ -z "$CLI_ARG" ]] && { err "--remove needs a panel id"; exit 1; }
                shift 2
                ;;
            --clean)
                CLI_ACTION="clean"; CLI_ARG="${2:-}"
                shift $(( $# > 1 ? 2 : 1 ))
                ;;
            --security)  CLI_ACTION="security"; shift ;;
            --update)    CLI_ACTION="update";   shift ;;
            --status)    CLI_ACTION="status";   shift ;;
            --detect)    CLI_ACTION="detect";   shift ;;
            --list)      CLI_ACTION="list";     shift ;;
            --guide)     CLI_ACTION="guide";    shift ;;
            --lang)
                CLI_LANG="${2:-}"
                [[ "$CLI_LANG" != "en" && "$CLI_LANG" != "ur" ]] && { err "--lang expects en or ur"; exit 1; }
                LANG_PREF="$CLI_LANG"
                save_settings
                shift 2
                ;;
            --yes|-y)    ASSUME_YES=1; shift ;;
            --version)   printf '%s v%s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION"; exit 0 ;;
            --help|-h)   print_usage; exit 0 ;;
            *)           err "Unknown option: $1"; print_usage; exit 1 ;;
        esac
    done
}

panel_exists() {
    local id="$1"
    if [[ ! -e "${P_MARKER[$id]:-}" ]]; then
        err "'$id' looks like it is not installed (marker ${P_MARKER[$id]:-?} missing)."
        exit 1
    fi
}

run_cli() {
    case "$CLI_ACTION" in
        detect)
            detect_installed_panels
            show_system_info_plain
            ;;
        list)
            local id
            for id in "${PANEL_IDS[@]}"; do
                printf '%-12s %-24s %-28s %s\n' "$id" "${P_NAME[$id]}" "${P_LICENSE[$id]}" "${P_OS[$id]}"
            done
            ;;
        guide)
            local tmp; tmp=$(guide_file "$LANG_PREF")
            cat "$tmp"
            rm -f "$tmp"
            ;;
        install)
            require_root "--install $CLI_ARG" || exit 1
            [[ -n "${P_MARKER[$CLI_ARG]:-}" ]] || { err "Unknown panel: $CLI_ARG (see --list)"; exit 1; }
            compatible "$CLI_ARG" || { err "Not compatible: $COMPAT_REASON"; exit 1; }
            detect_installed_panels
            ((${#FOUND_PANELS[@]} == 0)) || warn "Panel(s) already present: ${FOUND_PANELS[*]}"
            run_installer "$CLI_ARG"
            post_install_info "$CLI_ARG"
            ;;
        remove)
            require_root "--remove $CLI_ARG" || exit 1
            [[ -n "${P_MARKER[$CLI_ARG]:-}" ]] || { err "Unknown panel: $CLI_ARG (see --list)"; exit 1; }
            panel_exists "$CLI_ARG"
            confirm "Remove ${P_NAME[$CLI_ARG]}? BACK UP YOUR DATA FIRST." || { info "Cancelled."; exit 0; }
            panel_remove "$CLI_ARG"
            ;;
        clean)
            require_root "--clean" || exit 1
            if [[ -n "$CLI_ARG" ]]; then
                clean_items "${CLI_ARG//,/ }"
            else
                clean_all_flow
            fi
            ;;
        security)
            require_root "--security" || exit 1
            UI_BACKEND="plain"
            sec_firewall
            sec_fail2ban
            sec_autoupdate
            ;;
        update)
            require_root "--update" || exit 1
            UI_BACKEND="plain"
            update_flow
            ;;
        status)
            UI_BACKEND="plain"
            status_flow
            ;;
    esac
}

show_system_info_plain() {
    printf '%s\n' "OS          : $OS_PRETTY"
    printf '%s\n' "Family      : $OS_FAMILY (token: $OS_TOKEN)"
    printf '%s\n' "Architecture: $ARCH (normalized: $ARCH_OK)"
    printf '%s\n' "RAM         : ${RAM_MB}MB (${RAM_GB}GB)"
    printf '%s\n' "CPU cores   : $CORES"
    printf '%s\n' "Disk (/)    : ${DISK_GB}GB"
    printf '%s\n' "Virt        : $VIRT"
    printf '%s\n' "Public IP   : $PUB_IP"
    printf '%s\n' "Pkg manager : $(pkg_manager)"
    printf '\nPanel compatibility:\n'
    local id
    for id in "${PANEL_IDS[@]}"; do
        if compatible "$id"; then
            printf '  [OK] %s\n' "${P_NAME[$id]}"
        else
            printf '  [--] %-24s %s\n' "${P_NAME[$id]}" "$COMPAT_REASON"
        fi
    done
    detect_installed_panels
    printf '\nInstalled panel(s): %s\n' "${FOUND_PANELS[*]:-none detected}"
}

# ----------------------------------------------------------------------------
# Entry point
# ----------------------------------------------------------------------------
main() {
    load_settings
    parse_args "$@"
    detect_system

    if [[ -n "$CLI_ACTION" ]]; then
        run_cli
        exit $?
    fi

    # Interactive mode needs a real terminal
    if [[ ! -t 0 || ! -t 1 ]]; then
        print_usage
        err "No terminal detected. For interactive mode run:  sudo bash $0"
        exit 1
    fi
    require_root "" || exit 1
    init_ui
    print_banner
    main_menu
}

main "$@"

