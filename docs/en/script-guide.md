# ⚙️ Script Guide - Every Option of VPS WebHoster Explained

> **Language:** **English** | [اردو (Roman Urdu)](../ur/script-guide.md)
>
> Part of **VPS WebHoster** - [back to README](../../README.md)

---

## How to run it

```bash
# 1. download (or clone the repo)
wget https://raw.githubusercontent.com/qamrixtech/vps-webhoster/main/vps-webhoster.sh

# 2. run the menu
sudo bash vps-webhoster.sh
```

**Requirements:** a fresh-ish Linux VPS (Ubuntu, Debian, AlmaLinux, Rocky or
CentOS), root access, and an internet connection.

The script first **detects your server** and then shows a menu:

```text
==============================================================
|   V P S   W E B H O S T E R                                |
|   Free Website Control Panel Installer & Server Toolkit    |
|   Made by Hayder                     v1.0.0                |
==============================================================
```

---

## The menu, option by option

### 1️⃣ System Detection & Info

Prints everything the script knows about your machine:

- OS name/family and the normalized version token it matches panels against
- Architecture (`x86_64` or `aarch64`) - this decides which panels *can* run
- RAM (MB/GB), CPU cores, disk size, virtualization type, public IP
- **A compatibility row for all 8 panels** - `[OK]` or `[NO]` with the exact
  reason (e.g. "needs at least 2GB RAM, you have 1GB")
- Which panel(s), if any, are already installed

Use this first whenever something surprises you.

### 2️⃣ Install Website Control Panel

The core of the project.

1. **"What will you host?"** - WordPress/PHP · Node/Python/Go · Email + full
   hosting · Hosting business · Learning. Your answer feeds the
   recommendation engine.
2. **The list appears ranked**:
   - `RECOMMENDED (PanelName) - scored 87/100 - best for WordPress, fits your 4GB / amd64 / Debian 12`
   - then the other compatible panels
   - then incompatible ones, greyed with the reason
3. **Details screen** for the panel you picked (features, pros, cons - in
   English or Roman Urdu, your choice)
4. **Confirmation** shows the exact official installer command before
   anything runs
5. The **official interactive installer** starts - answer its prompts
6. An **ALL DONE screen** shows the panel URL, port, where the credentials
   are and which firewall port to open

**Scoring logic (transparent, so you know why):**

| Factor | Points |
|---|---|
| Compatible with your OS/arch at all | required (otherwise hidden as incompatible) |
| RAM ≥ recommended | +25 |
| RAM ≥ 2× minimum | +15 |
| RAM ≥ minimum (tight fit) | +5 |
| ≥2 CPU cores | +10 |
| Use-case match (e.g. `node:cloudpanel`) | +18…+30 |
| Panel maturity/popularity base | +8…+15 |
| Distro family native bonus | +8 |

### 3️⃣ Panel Details, Pros/Cons & Comparison

Opens any panel's full write-up (bilingual) or a **comparison table** that
adds a *"Support on THIS server"* section using your live hardware.

### 4️⃣ Remove Panel Cleanly

1. Scans the standard install paths of all 8 panels
2. Shows what it found; you pick one
3. **Backup warning** (this is your last easy chance to back up)
4. Runs panel-specific cleanup:
   - stops & disables its services (web server, mail, DNS, database…)
   - purges its packages
   - deletes its directories (`/usr/local/hestia`, `/www/server/panel`…)
   - removes its system user if it created one
5. Asks whether to **also purge the whole web stack**
   (nginx/apache/PHP/database/mail) - say NO if you still need the sites
6. Prints a **removal report**: marker gone?, ports closed?, any panels left?

> ⚠️ This is best-effort. Panels rewrite system configs deeply - for a
> production server, a fresh OS reinstall is the only *guaranteed* clean
> slate. That is also what CWP's own docs recommend.

### 5️⃣ Junk Cleaner

Checklist (you choose what applies):

| Item | What it does | Safe? |
|---|---|---|
| `pkgcache` | `apt clean` / `dnf clean` - downloaded package files | ✅ |
| `autoremove` | removes orphaned no-longer-needed packages | ✅ |
| `journal` | trims systemd journal logs to 200 MB | ✅ |
| `oldlogs` | deletes `*.gz`, `*.1`, `*.2` rotated logs in `/var/log` | ✅ |
| `tmp` | deletes `/tmp` files older than 7 days | ✅ (7-day grace) |
| `trash` | empties root's trash | ✅ |
| `kernels` | keeps only the 2 newest kernels (RHEL via package-cleanup; apt handles it with autoremove) | ✅ |
| `docker` | `docker system prune -af` - dangling images & build cache, **volumes kept** | ⚠️ confirm |
| `snap` | removes disabled/old snap revisions | ✅ |

Shows **disk used before and after** so you see exactly what you gained.
It **never** touches `/var/www`, website files or database dumps.

### 6️⃣ Security Hardening

- **Firewall** - `ufw` on Debian/Ubuntu (deny incoming, allow SSH) or
  `firewalld` on AlmaLinux/Rocky/CentOS (allow ssh service)
- **fail2ban** - installs it, writes a sane `jail.local` with an `sshd` jail
  and enables the service
- **Automatic updates** - `unattended-upgrades` on Debian/Ubuntu,
  `dnf-automatic` on Alma/Rocky, `yum-cron` on CentOS 7
- **SSH tips** - key-based login, `PasswordAuthentication no`, non-root user,
  why changing the port is *not* real security
- **All of the above** in one go

> Reminder: cloud providers have a **second** firewall (AWS Security Groups,
> Hetzner Cloud Firewall…). The OS firewall alone won't open the panel port.

### 7️⃣ Server Status Dashboard

Read-only overview: hostname, uptime, load, RAM, disk, listening ports,
failed systemd services, detected panel + URL, top 5 processes by memory.

### 8️⃣ System Update & Upgrade

`apt update && apt upgrade` or `dnf/yum update`, then warns you if a reboot
is required (`/var/run/reboot-required`, `needs-restarting`).

### 9️⃣ Beginner Guide

The full beginner guide (control panel vs SSH, real-world examples, glossary)
printed inside the terminal - in **English** or **Roman Urdu**.

### 🔟 Language & Settings

Choose guide language (`en` / `ur`). It is saved to `~/.vps-webhoster.conf`
and reused next time. Also shows log file locations.

### 🪪 About / Credits

Version, author (**Hayder**), license (MIT), repository link.

---

## Command-line flags (no menu)

```bash
bash vps-webhoster.sh --detect                 # system report (no root)
bash vps-webhoster.sh --list                   # all panels + support matrix
bash vps-webhoster.sh --guide [--lang ur]      # beginner guide to stdout
bash vps-webhoster.sh --lang ur                # set default guide language

sudo bash vps-webhoster.sh --install hestiacp  # straight into the installer
sudo bash vps-webhoster.sh --remove aapanel    # clean removal (asks to confirm)
sudo bash vps-webhoster.sh --clean             # default safe cleaning
sudo bash vps-webhoster.sh --clean pkgcache,journal,oldlogs
sudo bash vps-webhoster.sh --security          # firewall + fail2ban + auto updates
sudo bash vps-webhoster.sh --status            # status dashboard
sudo bash vps-webhoster.sh --update            # system upgrade
sudo bash vps-webhoster.sh --yes --remove cwp  # skip confirmations (careful!)
```

Valid panel ids: `hestiacp cloudpanel aapanel cyberpanel virtualmin ispconfig fastpanel cwp`

---

## Logging & troubleshooting

- **Main log:** `/var/log/vps-webhoster.log`
  (fallback if not root-writable: `/tmp/vps-webhoster-<uid>.log`)
- Every detection, recommendation and removal step is logged with a
  timestamp.

| Problem | Fix |
|---|---|
| "This action needs root" | prefix `sudo` |
| "No terminal detected" | you piped the script - run it in a real terminal instead |
| Menus look plain/ugly | `apt install dialog` (the script offers to do it) |
| Panel installer says "not a fresh OS" | most panels want a clean server - reinstall the OS or remove the existing stack |
| Port won't open | open it in your **cloud provider's** firewall too |
| ARM64 panel missing | only HestiaCP/CloudPanel/Virtualmin/ISPConfig officially support ARM64 - the script hides the rest |
| Installer URL 404 | panel authors move files - check `P_DOCS` in the script for the official docs page |
| Want to start over | Remove Panel → Junk Cleaner → reinstall |

---

## Safety design (what the script will never do)

- Won't run a panel installer without showing you the **exact command** first
- Won't install on top of an existing panel without a warning
- Won't remove a panel without a **backup warning** and confirmation
- Won't delete website files or databases during cleaning
- Won't delete Docker **volumes** (only images/build cache)
- Won't execute anything destructive in `--detect`, `--list`, `--guide`

---

> Made by **Hayder** · [VPS WebHoster](../../README.md) · MIT License
