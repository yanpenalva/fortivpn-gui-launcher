# FortiVPN GUI Launcher

A lightweight Bash-based GUI wrapper for `openfortivpn`, providing an interactive connection flow, password prompt, loading indicators, real-time logs, and safe disconnect handling.
Designed for Linux desktops using **yad** + **gnome-terminal**, but adaptable to other environments.

## Features

- GUI form for username and password
- Non-blocking loading dialogs
- Real-time logs streamed in a terminal
- Clean disconnect routine (kills VPN + pppd + routes + ppp interfaces)
- Detects connection success or failure via log inspection
- No installation required; portable script

## Requirements

### Runtime dependencies
- bash
- openfortivpn
- yad
- gnome-terminal
- sudo
- grep, awk, iproute2, tee

### Optional
- notify-send (desktop notifications)

## Installation

```bash
git clone https://github.com/<your-username>/fortivpn-gui-launcher.git
cd fortivpn-gui-launcher
chmod +x fortivpn-gui.sh
./fortivpn-gui.sh
```

## Configuration

Inside the script:

```bash
VPN_HOST="your-vpn-host:port"
USERNAME="your-username"
TIMEOUT=12
APP_NAME="FortiVPN GUI"
```

## How It Works

1. User enters password in GUI
2. Script authenticates sudo once
3. Launches openfortivpn, logs everything to /tmp
4. Script inspects log until VPN tunnel is up
5. Opens live log terminal (`tail -f`)
6. “Disconnect” button terminates VPN cleanly
7. Returns to main GUI form

## Optional: Passwordless Sudo (Recommended)

To avoid extra sudo prompts and ensure a smoother experience, allow only the required commands to run passwordless.

Edit sudoers:

```bash
sudo visudo
```

Add:

```
youruser ALL=(ALL) NOPASSWD: /usr/bin/openfortivpn
youruser ALL=(ALL) NOPASSWD: /usr/sbin/pppd
```

Replace `youruser` with your Linux username.

## Known Limitations / Notes

- Assumes gnome-terminal; change if needed
- Log detection may vary depending on VPN server
- Username is fixed but can be externalized to config
- Packaging (.deb/AppImage) not yet included

## License

MIT License.

## Contributing

PRs and improvements are welcome.
