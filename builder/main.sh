#!/usr/bin/env bash
# shellcheck disable=SC1090

#########################################################
# ARCH OS INSTALLER | Automated Arch Linux Installer TUI
#########################################################

# SOURCE:   https://github.com/murkl/arch-os
# AUTOR:    murkl
# ORIGIN:   Germany
# LICENCE:  GPL 2.0

# CONFIG
set -o pipefail # A pipeline error results in the error status of the entire pipeline
set -e          # Terminate if any command exits with a non-zero
set -E          # ERR trap inherited by shell functions (errtrace)

# ENVIRONMENT
: "${DEBUG:=false}"            # DEBUG=true ./installer.sh
: "${FORCE:=false}"            # FORCE=true ./installer.sh
: "${GUM:=/usr/local/bin/gum}" # GUM=/usr/bin/gum ./installer.sh

# SCRIPT
VERSION='1.9.3'

# VERSION
[ "$*" = "--version" ] && echo "$VERSION" && exit 0

# GUM
GUM_VERSION="0.13.0"

# FILES
SCRIPT_CONFIG="./installer.conf"
LOG_FILE="./installer.log"

# TEMP
SCRIPT_TMP_DIR="$(mktemp -d "./.tmp.XXXXX")"
ERROR_MSG_TMP_FILE="${SCRIPT_TMP_DIR}/installer.err"
PROCESS_LOG_TMP_FILE="${SCRIPT_TMP_DIR}/process.log"
PROCESS_RET_TMP_FILE="${SCRIPT_TMP_DIR}/process.ret"

DOTFILES_DIR="/home/nebolsinvasili/dotfiles-act/builder"
# Load logging functions
LOGGING_DIR="$DOTFILES_DIR/.settings/logging"
AUTOSTART_DIR="$DOTFILES_DIR/bin/arch-os-autostart"
IMPORT_FILES=(
  $LOGGING_DIR
  $AUTOSTART_DIR
)

for file in "${IMPORT_FILES[@]}"; do
  if [ -f "$file" ]; then
    . "$file"
  else
    echo "WARNING: Logging file not found: $file"
    exit 1
  fi
done
main() {

  # Clear logfile
  [ -f "$LOG_FILE" ] && mv -f "$LOG_FILE" "${LOG_FILE}.old"

  # Check gum binary or download
  # gum_init

  # Traps (error & exit)
  # trap 'trap_exit' EXIT
  # trap 'trap_error ${FUNCNAME} ${LINENO}' ERR

  # Print version to logfile
  log_info -v "Arch OS ${VERSION}"

  # ---------------------------------------------------------------------------------------------------

  # Loop properties step to update screen if user edit properties
  while (true); do

    print_header "Arch OS Installer" # Show landig page
    gum_white 'Please make sure you have:' && echo
    gum_white '• Backed up your important data'
    gum_white '• A stable internet connection'
    gum_white '• Secure Boot disabled'
    gum_white '• Boot Mode set to UEFI'

    ######################################################
    break # Exit properties step and continue installation
    ######################################################
  done
}

# START MAIN
main "$@"
