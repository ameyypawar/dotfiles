# Setup-Remote-VPS — Claude Code on a $5/mo Hetzner box

A runbook to spin up an always-on Linux VPS that runs `claude remote-control`, so you can drive Claude Code from your iOS Claude app, the browser, or SSH from anywhere. Your Mac stays on the desk for anything that needs a real browser (Chrome extensions etc.).

**Estimated time:** 25–40 min on a fresh evening.
**Recurring cost:** ~$5/mo VPS + your Claude Max plan.

> **Placeholder convention:** this guide uses `<user>` for the Linux user you'll create on the VPS (`amey`, `dev`, whatever — pick one and stick with it), `<your-rust-project>` for any Rust workspace you want on the box, and `<you>` for your GitHub handle. Replace these as you go.

---

## Prerequisites

- Hetzner account (sign up at hetzner.cloud — credit card or PayPal).
- An existing SSH key on your Mac: `ls ~/.ssh/id_ed25519.pub` (if missing, run `ssh-keygen -t ed25519 -C "your_email@example.com"`).
- Active **Claude Max 5x or 20x** subscription (required for Remote Control; Pro works but Max is what makes the bundled Agent SDK credits useful).
- iOS Claude app installed on your phone.
- Optional: Blink Shell on iOS ($30 one-time) for occasional sysadmin SSH from phone.

---

## Step 1 — Provision the VPS (5 min)

1. Go to `console.hetzner.cloud` → New Project → "dev-anchor" (or whatever).
2. Add Server. Pick:
   - **Location:** closest to you (Helsinki / Falkenstein for EU, Ashburn / Hillsboro for US).
   - **Image:** Ubuntu 24.04 LTS.
   - **Type:** Shared vCPU → **CAX11** (€3.79/mo, 2 ARM vCPU, 4 GB RAM, 40 GB disk). If you ever hit ARM cross-compile pain on Rust, switch to **CX22** (€4.59/mo, x86).
   - **Networking:** IPv4 + IPv6 (default).
   - **SSH key:** upload `~/.ssh/id_ed25519.pub` from your Mac.
   - **Firewall:** create a new firewall, allow inbound `22/tcp` only. (Claude Remote Control uses outbound HTTPS only — no inbound ports needed.)
3. Create & Buy → wait ~30 sec for provisioning.
4. Copy the public IPv4 from the dashboard. You'll need it.

```bash
# from your Mac
export VPS_IP=<paste-the-ipv4>
ssh root@$VPS_IP            # accept the host key fingerprint
```

You're in.

---

## Step 2 — Server hardening (10 min)

Ubuntu's default is fine but should be locked down before running an agent on it.

```bash
# inside the VPS, as root
adduser <user>                                 # create your own user, set password
usermod -aG sudo <user>                        # grant sudo
mkdir -p /home/<user>/.ssh
cp /root/.ssh/authorized_keys /home/<user>/.ssh/
chown -R <user>:<user> /home/<user>/.ssh
chmod 700 /home/<user>/.ssh
chmod 600 /home/<user>/.ssh/authorized_keys

# disable root SSH + password auth
sed -i 's/^#*PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

# verify you can SSH as the new user from a NEW Mac terminal BEFORE closing the root session
# (in a new Mac terminal:)
ssh <user>@$VPS_IP

# only then, exit the root session
```

Optional but recommended: install `unattended-upgrades` for security patches.

```bash
sudo apt update && sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

---

## Step 3 — Base toolchain (5 min)

```bash
sudo apt update
sudo apt install -y build-essential curl git tmux ripgrep fd-find \
                    fzf jq python3-pip pkg-config libssl-dev

# Rust (for gitfix or any Cargo workspace)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Node (for any TS / npm tooling)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs

# Neovim (kickstart bootstraps itself on first launch)
sudo apt install -y neovim
```

---

## Step 4 — Install Claude Code (3 min)

```bash
curl -fsSL https://claude.ai/install.sh | bash

# add to PATH if the installer doesn't
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

claude --version              # confirm it installed
```

---

## Step 5 — OAuth login (2 min, requires a browser somewhere)

Remote Control needs a full OAuth session token. The CLI prints a URL.

```bash
claude auth login
```

It outputs something like `Open this URL: https://...`. **Open that URL in any browser on any machine** (your Mac, your phone, doesn't matter). Sign in with the same Anthropic account that has your Max subscription. The browser redirects, the CLI catches the callback, you're authed.

Credentials persist in `~/.claude/.credentials.json` on the VPS. Survives reboots.

---

## Step 6 — Pull your dotfiles + projects (5 min)

```bash
# clone your dotfiles (assumes you finished the public repo)
git clone https://github.com/ameyypawar/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh                  # brew bundle won't apply on Ubuntu; that's fine
# Manually install what install.sh skipped — eza, bat, etc. from apt:
sudo apt install -y bat eza
mkdir -p ~/.config
stow -t ~ zsh git tmux yazi nvim
# (skip ghostty + starship overrides — they're Ghostty-app specific or shell-specific)

# Set git identity (kept local on this box)
git config --global user.email "you+yourname@users.noreply.github.com"
git config --global user.name "yourname"

# Clone your active projects
mkdir -p ~/Projects
cd ~/Projects
gh auth login          # need GitHub CLI; install if needed: sudo apt install gh
git clone git@github.com:<you>/<your-rust-project>.git    # gitfix
# (whatever other repos you need on the server)
```

---

## Step 7 — Persistent tmux + remote-control session (5 min)

You want `claude remote-control` to keep running even when you SSH out, plus survive a server reboot.

### Quick approach (tmux session)

```bash
tmux new -s anchor                    # creates session named "anchor"
# inside tmux:
cd ~/Projects/<your-rust-project>
claude remote-control
# you'll see: "Session ID: ... — Press SPACE to display QR code"
# press SPACE → terminal shows a QR. Scan with iOS Claude app camera/scanner.

# detach with prefix + d (Ctrl-b d)
# verify it's still running: tmux ls
```

**Reattach later from any device:**
```bash
ssh <user>@$VPS_IP
tmux a -t anchor
```

### Robust approach (systemd, survives reboots)

```bash
# create the unit file
sudo tee /etc/systemd/system/claude-remote.service >/dev/null <<'EOF'
[Unit]
Description=Claude Code Remote Control
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=<user>
WorkingDirectory=/home/<user>/Projects/<your-rust-project>
ExecStart=/home/<user>/.local/bin/claude remote-control
Restart=on-failure
RestartSec=10
Environment="HOME=/home/amey"
Environment="PATH=/home/<user>/.local/bin:/home/<user>/.cargo/bin:/usr/local/bin:/usr/bin:/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable claude-remote
sudo systemctl start claude-remote

# verify
sudo systemctl status claude-remote --no-pager
journalctl -u claude-remote -f          # follow logs, Ctrl-C to exit
```

After this, `claude remote-control` survives reboots and crashes. You only need to SSH in to view the QR code on the first connect from each new device.

Note: Anthropic doesn't officially document the systemd unit; community confirms it works. If a future Claude Code release changes auth flow, re-do step 5.

---

## Step 8 — Connect from your iPhone (2 min)

1. Open the **iOS Claude app**.
2. Tap the Code tab (bottom nav).
3. Tap "Connect to a session" or similar (UI changes per release).
4. Scan the QR code:
   - If using tmux: SSH in, `tmux a -t anchor`, press SPACE in the running `claude` session — QR appears.
   - If using systemd: connect through `claude.ai/code` browser; it'll show your active session and a QR.
5. Phone connects. You're now driving Claude Code on the VPS from your phone.

**Push notifications:** the app asks once. Enable them. The phone vibrates when Claude finishes a long task or needs a decision.

---

## Step 9 — Wire up gitfix MCP (optional, if gitfix is your active project)

Inside the VPS, build gitfix once:

```bash
cd ~/Projects/<your-rust-project>
cargo build --release
ln -sf "$PWD/target/release/gitfix" ~/.local/bin/gitfix
gitfix --version
```

Then add it to Claude Code's MCP servers. Edit `~/.claude.json` on the VPS:

```json
{
  "mcpServers": {
    "gitfix": {
      "command": "gitfix",
      "args": ["mcp"],
      "env": { "GITFIX_BYOK": "1" }
    }
  }
}
```

Restart the `claude remote-control` service (`sudo systemctl restart claude-remote`). New sessions will pick up the MCP server.

---

## Step 10 — Daily ops

### Connect from phone (most common path)

- Open iOS Claude app → Code tab → tap your active session. That's it.

### SSH from phone for actual terminal work

- Open Blink Shell.
- `ssh amey@<vps-ip>` (Blink stores the key/host once).
- `tmux a -t anchor` to attach if you want to see what's running.
- Detach with `Ctrl-b d` before closing Blink.

### Check on the agent later

- iOS Claude app shows session activity.
- Or via `journalctl -u claude-remote -n 50` over SSH.

### Restart if anything's stuck

```bash
sudo systemctl restart claude-remote
```

### Update Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
sudo systemctl restart claude-remote
```

---

## Costs to watch

- **VPS fixed:** ~€3.79/mo (~$5 USD) for CAX11. Hetzner bills monthly.
- **Anthropic variable:** Max 5x → $100/mo includes $100 Agent SDK credits. Beyond that → Sonnet 4.6 API rates ($3 in / $15 out per million tokens). Heavy multi-agent days can spike token usage fast. Check via `claude usage` periodically.
- **Bandwidth:** Hetzner includes 20 TB/month outbound on CAX11. You won't get close.
- **Storage:** 40 GB SSD on CAX11. Build artifacts for one Rust workspace fit easily; clean `cargo clean` if you ever feel pressure.

---

## Pause / shutdown (when you don't need it)

You can pause the VPS without losing data:

```bash
# from the Hetzner web console: Server → Power → Shutdown → Power Off
# Hetzner still charges for the IP allocation while the box is off — about €0.50/mo for IP.
# Full delete = zero cost but you lose the snapshot/state.
```

For real cost containment: **take a snapshot first, then delete the server.** Snapshots cost €0.0119/GB/month — about €0.50/mo for a 40 GB image. To bring it back, create a new server from snapshot in ~2 min.

---

## Decommission entirely

```bash
# on Hetzner console:
# 1. Take final snapshot (optional) if you want to come back
# 2. Delete server
# 3. Delete the firewall + project
```

Subscription cancellation is separate — handle in Anthropic billing.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `claude remote-control` exits immediately | OAuth token expired | Re-run `claude auth login` |
| iOS app shows "no active sessions" | systemd unit died | `sudo systemctl restart claude-remote`, check `journalctl -u claude-remote` |
| Token cost climbing fast | Agent loop with infinite retries | Check active sessions; kill runaway ones; review prompt budgets |
| SSH suddenly refused | `sshd` died or firewall change | Use Hetzner web console → access via web terminal → fix sshd |
| Git push fails from VPS | No GitHub key registered | `gh auth login` or `ssh-keygen` on VPS + add pubkey to github.com |
| Builds OOM | 4 GB RAM not enough | Add swap: `fallocate -l 4G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile`, persist via `/etc/fstab` |

---

## Reading later

- Official: https://code.claude.com/docs/en/remote-control
- Auth scopes: https://code.claude.com/docs/en/authentication
- Hetzner CAX series: https://www.hetzner.com/cloud/cost-optimized
- Pricing post-June-15-2026 model: https://findskill.ai/blog/claude-code-pricing-after-june-15-decision-table/

---

## Mental model

The VPS is your **always-on anchor**: a persistent Linux box where Claude Code lives and gitfix runs. Your Mac is still the main keyboard, and the phone is a remote control for the anchor. The anchor never sleeps, so long-running agents and overnight evaluations keep going. Tubio testing still happens on the Mac because Chrome extensions need a real browser.

Skip the setup until at least one of these is true:
- gitfix is the active project for weeks at a time, and you'd benefit from agents that run while you're away from the Mac
- You travel and want to dev from a phone or iPad
- A multi-hour gitfix evaluation is something you'd start and check on later

Otherwise the Mac + `caffeinate -i` + tmux-continuum gives you most of the persistence benefit at zero extra cost.
