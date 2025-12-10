#!/usr/bin/env bash

VPN_HOST="your-vpn-host:port"
USERNAME="your-username"
TIMEOUT=12
APP_NAME="FortiVPN GUI"

if [ "$EUID" -eq 0 ]; then
    yad --error --title="$APP_NAME" --text="Do not run this script with sudo."
    exit 1
fi

force_disconnect() {
    killall -q openfortivpn 2>/dev/null
    sudo killall -q pppd 2>/dev/null
    for iface in $(ip -o link show | awk -F': ' '/ppp[0-9]/{print $2}'); do
        sudo ip link delete "$iface" 2>/dev/null
    done
    sudo ip route del default dev ppp0 2>/dev/null
    sleep 1
}

show_loading() {
    yad --title="$1" \
        --width=300 --height=120 \
        --center \
        --no-buttons \
        --undecorated \
        --text="<big><b>$1</b></big>" \
        --progress --pulsate --auto-close \
        --percentage=0 --progress-text="" \
        --no-escape &
    LOADING_PID=$!
}

close_loading() {
    kill "$LOADING_PID" 2>/dev/null
}

open_real_time_log() {
    LOG_FILE="$1"
    gnome-terminal -- bash -c "tail -f '$LOG_FILE'; exit" &
    TERMINAL_PID=$!
}

disconnect_and_back() {
    show_loading "Disconnecting..."
    force_disconnect
    kill "$TERMINAL_PID" 2>/dev/null
    close_loading
    show_form
}

start_vpn() {
    PASSWORD="$1"

    force_disconnect
    LOG_FILE="/tmp/vpn_log_$(date +%s).txt"

    show_loading "Connecting..."

    echo "$PASSWORD" | sudo -S true

    {
        sudo openfortivpn "$VPN_HOST" -u "$USERNAME" -p "$PASSWORD" -vv
    } 2>&1 | tee "$LOG_FILE" >/dev/null &

    CONNECT_PID=$!
    sleep 1

    while kill -0 "$CONNECT_PID" 2>/dev/null; do
        if grep -Eq "Tunnel is up|allocated a VPN|Interface is up|Using gateway" "$LOG_FILE"; then
            close_loading
            notify-send "$APP_NAME" "Connected" --icon=network-vpn

            open_real_time_log "$LOG_FILE"

            yad --title="$APP_NAME" \
                --width=300 --height=120 \
                --text="<big>VPN Connected</big>" \
                --button="Disconnect:1"

            disconnect_and_back
            return
        fi

        if grep -Ei "ERROR|Failed|403|denied|Could not" "$LOG_FILE"; then
            close_loading
            notify-send "$APP_NAME" "Connection failed" --icon=dialog-error
            yad --error --title="$APP_NAME" --text="Connection failed."
            show_form
            return
        fi

        sleep 0.3
    done

    close_loading
    show_form
}

show_form() {
    FORM=$(yad --title="$APP_NAME" \
        --width=420 --height=250 \
        --center \
        --image="network-vpn" \
        --image-on-top \
        --form \
        --field="Username (fixed):RO" "$USERNAME" \
        --field="Password":H \
        --button="Connect:0" \
        --button="Cancel:1")

    [ $? -ne 0 ] && exit 0

    PASSWORD=$(echo "$FORM" | awk -F'|' '{print $2}')

    [ -z "$PASSWORD" ] && {
        yad --error --title="$APP_NAME" --text="Password is required."
        show_form
        return
    }

    start_vpn "$PASSWORD"
}

show_form
