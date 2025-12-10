# FortiVPN GUI Launcher

A lightweight Bash-based GUI wrapper for `openfortivpn`, providing an interactive connection flow, password prompt, loading indicators, real-time logs in a terminal window, and controlled disconnect handling.
Designed for Linux desktops that use **yad** + **gnome-terminal**, but easily adaptable to other environments.

## Features

- GUI form for username and password (password hidden).
- Non-blocking loading dialog while connecting.
- Automatic sudo authentication once per session.
- Real-time VPN log viewer (`tail -f`) in a separate terminal.
- Safe disconnect: terminates `openfortivpn`, `pppd`, and cleans `pppX` interfaces.
- Detects successful tunnel establishment via log inspection.
- Detects connection errors and displays GUI feedback.
- No permanent installation required; portable script.

## Requirements

The script depends on the following packages:

### Runtime
- bash
- openfortivpn
- yad
- gnome-terminal
- sudo
- grep, awk, iproute2, tee

### Optional
- notify-send for desktop notifications (part of libnotify-bin on Debian-based distros)

## Installation

Clone the repository:

```bash
git clone https://github.com/<your-username>/fortivpn-gui-launcher.git
cd fortivpn-gui-launcher
chmod +x fortivpn-gui.sh
```

Run:

```bash
./fortivpn-gui.sh
```

## Configuration

Configure inside the script:

```bash
VPN_HOST="your-vpn-host:port"
USERNAME="your-username"
TIMEOUT=12
```

## How It Works

1. User enters password.
2. Script authenticates sudo once.
3. Launches openfortivpn and logs to temp file.
4. Detects connection success by log patterns.
5. Opens real‑time log terminal.
6. On failure, shows GUI error.
7. Disconnect cleans processes, interfaces, routes.

## Known Limitations / Next Steps

- Assumes gnome-terminal.
- Username static for now.
- No packaging (could become .deb/AppImage).
- Log patterns may vary by FortiGate config.

## License

MIT License.

## Contributing

Issues and PRs welcome.
