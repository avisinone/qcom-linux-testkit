#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# Robustly find and source init_env
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INIT_ENV=""
SEARCH="$SCRIPT_DIR"
while [ "$SEARCH" != "/" ]; do
    if [ -f "$SEARCH/init_env" ]; then
        INIT_ENV="$SEARCH/init_env"
        break
    fi
    SEARCH=$(dirname "$SEARCH")
done

if [ -z "$INIT_ENV" ]; then
    echo "[ERROR] Could not find init_env (starting at $SCRIPT_DIR)" >&2
    exit 1
fi

# Only source if not already loaded (idempotent)
if [ -z "$__INIT_ENV_LOADED" ]; then
    # shellcheck disable=SC1090
    . "$INIT_ENV"
fi

# Always source functestlib.sh, using $TOOLS exported by init_env
# shellcheck disable=SC1090,SC1091
. "$TOOLS/functestlib.sh"

TESTNAME="systemctlStart"
test_path=$(find_test_case_by_name "$TESTNAME")
cd "$test_path" || exit 1
res_file="./$TESTNAME.res"

# Function to check if systemctl start command works for systemd-user-sessions.service
check_systemctl_start() {
    log_info "----------------------------------------------------"
    log_info "-------- Starting $TESTNAME Functional Test --------"
    systemctl start systemd-user-sessions.service
    sleep 5
    if systemctl is-active --quiet systemd-user-sessions.service; then
        log_pass "Service started successfully with systemctl command"
        echo "$TESTNAME PASS" >> "$res_file"
    else
        log_fail "Failed to start service with systemctl command"
        echo "$TESTNAME FAIL" >> "$res_file"
    fi
    log_info "----------------------------------------------------"
    log_info "-------- Stopping $TESTNAME Functional Test --------"
}


# Call the functions
check_systemctl_start
