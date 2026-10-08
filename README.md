<h1 align="center">VPS WEBHOSTER</h1>

<p align="center">
  <b>Free Website Control Panel Installer &amp; Server Toolkit for beginners</b><br>
  Auto-detects your Linux server → recommends the best FREE panel → installs it with its official installer
</p>

<p align="center">
  🌐 Language / زبان: &nbsp;<b>English</b> &nbsp;|&nbsp; <a href="./README.ur.md">اردو (Roman Urdu)</a>
</p>

<p align="center">
  <a href="https://github.com/qamrixtech/vps-webhoster/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/version-1.0.0-blue?style=flat-square" alt="Version 1.0.0">
  <img src="https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian%20%7C%20AlmaLinux%20%7C%20Rocky%20%7C%20CentOS-orange?style=flat-square" alt="Supported OS">
  <img src="https://img.shields.io/badge/arch-x86_64%20%7C%20aarch64-lightgrey?style=flat-square" alt="Architectures">
  <img src="https://img.shields.io/badge/panels-8%20free%20%2F%20freemium-purple?style=flat-square" alt="8 free panels">
  <img src="https://img.shields.io/badge/made%20by-Hayder-ff69b4?style=flat-square" alt="Made by Hayder">
</p>

<p align="center">
  <a href="#-quick-start">🚀 Quick Start</a> •
  <a href="#-whats-inside-the-menu">🧭 Menu</a> •
  <a href="#-the-8-panels">🖥️ Panels</a> •
  <a href="#-which-panel-should-you-pick">⭐ Which panel?</a> •
  <a href="#-documentation-for-beginners">📘 Docs</a> •
  <a href="#-faq">❓ FAQ</a>
</p>

---

> [!IMPORTANT]
> **Just bought a VPS and have no idea what to do?** This tool is exactly for
> you. It detects your server, tells you which control panel actually fits
> *your* RAM / CPU / distro, runs the panel's **latest official installer**,
> and later removes it cleanly — with a beginner guide in **English and Roman
> Urdu** built right in.

---

## 📚 Table of contents

- [What is this?](#-what-is-this)
- [🚀 Quick Start](#-quick-start)
- [🧭 What's inside the menu?](#-whats-inside-the-menu)
- [🖥️ The 8 panels](#-the-8-panels)
- [⭐ Which panel should you pick?](#-which-panel-should-you-pick)
- [🔍 How detection & recommendation works](#-how-detection--recommendation-works)
- [🧹 Junk Cleaner & 🗑️ Clean removal](#-junk-cleaner--clean-removal)
- [💻 Command-line flags](#-command-line-flags)
- [📘 Documentation for beginners](#-documentation-for-beginners)
- [❓ FAQ](#-faq)
- [🤝 Contributing & license](#-contributing--license)

---

## 🧾 What is this?

**VPS WebHoster** is a single Bash script that turns a blank Linux VPS into a
managed hosting server — without reading 50 tutorials.

| It does | It does NOT |
|---|---|
| ✅ Detect Ubuntu / Debian / AlmaLinux / Rocky / CentOS | ❌ Touch paid panels (cPanel, Plesk, DirectAdmin) |
| ✅ Detect `x86_64` / `aarch64`, RAM, CPU cores, disk | ❌ Run anything without showing you the command first |
| ✅ Build a terminal TUI (dialog/whiptail, plain fallback) | ❌ Delete your website files or databases |
| ✅ Recommend the best free panel **for your machine** | ❌ Hide which panel is incompatible or why |
| ✅ Run each panel's latest **official** installer | ❌ Install without a confirmation |
| ✅ Remove panels cleanly (services → packages → files → ports) | ❌ Claim to be a replacement for understanding your server |
| ✅ Junk-cleaner, firewall, fail2ban, auto-updates, status | | |
| ✅ Beginner guide in **English + Roman Urdu** | |

**Made by Hayder.** Free forever, MIT licensed.

---

## 🚀 Quick Start

SSH into your VPS as `root`, then:

```bash
wget https://raw.githubusercontent.com/qamrixtech/vps-webhoster/main/vps-webhoster.sh
sudo bash vps-webhoster.sh
```

Or clone the whole repo (docs included):

```bash
git clone https://github.com/qamrixtech/vps-webhoster.git
cd vps-webhoster
sudo bash vps-webhoster.sh
```

Then follow the menu:

```text
1. System Detection & Info      → see what your server is
2. Install Control Panel        → answer "what will you host?" → ★ recommended on top
3. Panel Details & Comparison   → pros / cons of every panel (EN + Roman Urdu)
4. Remove Panel Cleanly         → uninstall with cleanup + verification
5. Junk Cleaner                 → free disk space (shows before/after)
6. Security Hardening           → firewall + fail2ban + auto updates
7. Server Status Dashboard      → RAM, disk, ports, failed services
8. System Update & Upgrade
9. Beginner Guide               → English / Roman Urdu, inside the terminal
10. Language & Settings
11. About / Credits
```

> [!TIP]
> **Use a fresh VPS.** Panel installers officially want a clean operating
> system. The script warns you if it finds an existing panel.

---

## 🧭 What's inside the menu?

<details>
<summary><b>1️⃣ System Detection &amp; Info</b> — click to expand</summary>

Prints OS family, normalized version token, architecture, RAM, CPU cores,
disk, virtualization, public IP — and a compatibility row for **all 8
panels** with the exact reason if one doesn't fit:

```text
 [OK ] HestiaCP         compatible — 1024MB min
 [OK ] CloudPanel       compatible — 2048MB min
 [--] CyberPanel        needs x86_64, you have aarch64
 [OK ] aaPanel          compatible — 512MB min
```

</details>

<details>
<summary><b>2️⃣ Install Website Control Panel</b> — ★ recommendation on top</summary>

1. You answer **"What will you host?"**
   (WordPress/PHP · Node/Python/Go · Email + DNS + PostgreSQL ·
   Hosting business · Learning)
2. The list is **ranked** — the recommended panel appears first with its
   score and reason, e.g.:

   ```text
   ★ RECOMMENDED (CloudPanel) - scored 87/100 - perfect RAM fit (4GB),
     best for WordPress/PHP, fits Debian 12 / x86_64 / 4 core(s)
   ```

3. You see the panel's **features, pros and cons** (English or Roman Urdu)
4. The **exact official installer command** is shown for confirmation
5. The official interactive installer runs
6. A summary screen shows **panel URL, port, credentials location** and the
   firewall port you must open

</details>

<details>
<summary><b>4️⃣ Remove Panel Cleanly</b> — click to expand</summary>

1. Auto-detects installed panels by their marker paths
2. Big **BACK UP FIRST** warning + confirmation
3. Panel-specific cleanup: stop/disable services → purge packages → delete
   directories → remove created users
4. Optional: **purge the whole web stack** (nginx/apache/PHP/database/mail)
   or keep it
5. Report: marker gone? ports closed? panels left?

> [!WARNING]
> Panels modify system configs deeply. On production servers, a fresh OS
> reinstall is the only *guaranteed* clean slate. CWP's own docs say the
> same (they provide no uninstaller at all).

</details>

<details>
<summary><b>5️⃣ Junk Cleaner</b> — click to expand</summary>

Checklist with **disk used before/after**:

| Item | What it does |
|---|---|
| `pkgcache` | apt/dnf downloaded package cache |
| `autoremove` | orphaned unused packages |
| `journal` | systemd journal trimmed to 200 MB |
| `oldlogs` | old rotated logs (`*.gz`, `*.1`) |
| `tmp` | `/tmp` files older than 7 days |
| `trash` | root's trash |
| `kernels` | keep only the 2 newest kernels |
| `docker` | images + build cache only, **volumes kept** |
| `snap` | old/disabled snap revisions |

Never touches `/var/www`, website files or database dumps.

</details>

<details>
<summary><b>6️⃣ Security Hardening</b> — click to expand</summary>

- **Firewall**: `ufw` (Debian/Ubuntu, deny incoming + allow SSH) or
  `firewalld` (AlmaLinux/Rocky/CentOS)
- **fail2ban**: installed, configured with an `sshd` jail, enabled
- **Auto-updates**: `unattended-upgrades` / `dnf-automatic` / `yum-cron`
- **SSH tips**: key-based login, disabling password auth, non-root user,
  why changing ports isn't real security

</details>

---

## 🖥️ The 8 panels

All free or freemium — verified against **official docs** (Oct 2026).

| # | Panel | License | Min RAM | Standout |
|---|---|---|---|---|
| ⭐ | **[HestiaCP](https://hestiacp.com/docs/introduction/getting-started)** | 100% free (GPL) | 1 GB | **PostgreSQL + custom DNS + full mail** — most complete cPanel alternative |
| ⭐ | **[CloudPanel](https://www.cloudpanel.io/docs/)** | Free CE | 2 GB | Lightest modern UI, **Varnish**, **MariaDB**, PHP/Node/Python/Go, ARM64 |
| | **[aaPanel](https://www.aapanel.com/docs/guide/quickstart.html)** | Free (Pro paid) | **512 MB** | Lowest RAM, runs on Ubuntu+Debian+**Alma+Rocky**, free WAF |
| | **[CyberPanel](https://cyberpanel.net/KnowledgeBase/home/install-cyberpanel/)** | Free (Pro paid) | 1 GB | **OpenLiteSpeed** = fastest PHP/WordPress, PowerDNS |
| | **[Virtualmin GPL](https://www.virtualmin.com/download/)** | 100% free (GPL) | 1 GB | Most mature — mail, DNS, PostgreSQL, ARM64, powerful CLI |
| | **[ISPConfig](https://www.ispconfig.org/documentation/)** | 100% free (GPL) | 1 GB | True **multi-server** / reseller panel, ARM64 |
| | **[FastPanel](https://kb.fastpanel.direct/quick_start/how-to-install-fastpanel/)** | Free license | 1 GB | Modern UI, free **commercial** license, official uninstaller |
| | **[CWP](https://control-webpanel.com/installation-instructions)** | Free (Pro paid) | 2 GB | Enterprise security for **AlmaLinux/Rocky** |

<details>
<summary><b>Pros &amp; cons of each panel (short version)</b> — full write-ups in <a href="./docs/en/panels.md">docs/en/panels.md</a></summary>

| Panel | ✅ Pros | ❌ Cons |
|---|---|---|
| **HestiaCP** | Truly free, PostgreSQL + custom DNS + mail, ARM64, friendly UI | Full stack wants 4 GB RAM; Debian/Ubuntu only; no official uninstaller |
| **CloudPanel** | Very light, Varnish built-in, Node/Python/Go native, ARM64 | 2 GB min; no mail server; no PostgreSQL; Debian/Ubuntu only |
| **aaPanel** | 512 MB min, widest OS support (Alma/Rocky too), free WAF | Advanced features paid; ARM64 unofficial; promo banners |
| **CyberPanel** | Fastest PHP (OpenLiteSpeed), PowerDNS, Redis, unlimited free domains | x86_64 only; no PostgreSQL; no Debian; no official uninstaller |
| **Virtualmin** | 100% free, PostgreSQL+DNS+mail, RHEL+Debian+ARM64, huge CLI | Dated interface; steeper learning curve |
| **ISPConfig** | 100% free, real multi-server, PostgreSQL, ARM64 auto-installer | Slower/heavier setup; plain UI; no official uninstaller |
| **FastPanel** | Free commercial license, modern UI, **official uninstall command** | x86_64 only; email license activation; smaller community |
| **CWP** | Strong security (CSF, ClamAV, ModSecurity), great PHP selector | RHEL only; 2 GB min; **no uninstaller** ("reinstall the OS") |

**Deliberately excluded:** VestaCP (unmaintained — use HestiaCP), cPanel /
Plesk / DirectAdmin (paid), Sentora (abandoned).

</details>

---

## ⭐ Which panel should you pick?

The script answers this automatically — but here's the human version:

| Your server / need | Pick |
|---|---|
| 512 MB–1 GB RAM, any distro | **aaPanel** |
| 2 GB+, Debian/Ubuntu, WordPress/PHP | **CloudPanel** |
| Need **email + PostgreSQL + custom DNS** | **HestiaCP** |
| Fastest possible PHP/WordPress | **CyberPanel** |
| AlmaLinux / Rocky, low RAM, beginner | **aaPanel** |
| **ARM64** VPS (Hetzner, AWS Graviton, Oracle) | **HestiaCP / CloudPanel / Virtualmin / ISPConfig** |
| Hosting business / resellers / clusters | **ISPConfig** or **HestiaCP** |
| Learning, first server ever | **aaPanel** or **HestiaCP** |

---

## 🔍 How detection & recommendation works

```text
/etc/os-release  →  ID + VERSION_ID  →  "ubuntu:24.04" / "almalinux:9" / "debian:12"
uname -m         →  x86_64 | aarch64
/proc/meminfo    →  RAM MB/GB
nproc            →  CPU cores
df               →  disk GB
```

Each panel carries a **support matrix** (OS tokens × architecture × min
RAM × min disk). Panels that don't fit are shown **greyed out with the
exact reason** — never silently hidden.

The recommendation score is transparent:

| Factor | Points |
|---|---|
| RAM ≥ recommended | +25 |
| RAM ≥ 2× minimum | +15 |
| RAM ≥ minimum only | +5 |
| ≥2 CPU cores | +10 |
| Use-case match (`node:cloudpanel`, `email:hestiacp`, …) | +18…+30 |
| Panel maturity base | +8…+15 |
| Distro-family native bonus | +8 |

---

## 🧹 Junk Cleaner & 🗑️ Clean removal

Two beginner-shaped problems, two menu options:

- **Junk Cleaner** → frees disk space (cache, orphans, logs, old kernels,
  trash) and prints `before → after`. Your site files and databases are
  never touched.
- **Remove Panel Cleanly** → the reverse of installing: services stopped,
  packages purged, files and users removed, ports verified — plus an
  optional full web-stack purge.

Full details: **[docs/en/script-guide.md](./docs/en/script-guide.md)** ·
**[docs/ur/script-guide.md](./docs/ur/script-guide.md)**

---

## 💻 Command-line flags

```bash
bash vps-webhoster.sh --detect                 # system report (no root needed)
bash vps-webhoster.sh --list                   # all panels + support matrix
bash vps-webhoster.sh --guide [--lang ur]      # beginner guide to stdout
bash vps-webhoster.sh --lang ur                # set default guide language

sudo bash vps-webhoster.sh --install hestiacp  # straight into the installer
sudo bash vps-webhoster.sh --remove aapanel    # clean removal
sudo bash vps-webhoster.sh --clean             # safe cleaning (or --clean pkgcache,journal)
sudo bash vps-webhoster.sh --security          # firewall + fail2ban + auto updates
sudo bash vps-webhoster.sh --status            # status dashboard
sudo bash vps-webhoster.sh --update            # system upgrade
sudo bash vps-webhoster.sh --version           # version
```

---

## 📘 Documentation for beginners

Everything is written twice — **English** and **Roman Urdu (اردو)**:

| 📖 English | 📖 Roman Urdu (اردو) | What's inside |
|---|---|---|
| [Beginner Guide](./docs/en/beginner-guide.md) | [.beginner Guide](./docs/ur/beginner-guide.md) | What is a control panel? What is SSH? The difference + real-world examples + how to connect with PuTTY/Terminal |
| [The Panels](./docs/en/panels.md) | [Panels](./docs/ur/panels.md) | Every panel's features, **pros & cons**, official install/uninstall commands, who each is for |
| [Script Guide](./docs/en/script-guide.md) | [Script Guide](./docs/ur/script-guide.md) | Every menu option explained (incl. junk cleaner), CLI flags, logging, troubleshooting |

> **Start here if you have never used a server:**
> [docs/en/beginner-guide.md](./docs/en/beginner-guide.md) —
> control panel = TV remote / hotel reception, SSH = your own key to the
> server room. It all clicks after one read.

---

## ❓ FAQ

<details>
<summary><b>Is it really free?</b></summary>

Yes — the script is MIT licensed and every panel in the list is free or has a
genuinely usable free mode. Panels with paid extras (aaPanel Pro,
CyberPanel Pro, CWP Pro) are marked as freemium. Paid-only panels are not
included at all.

</details>

<details>
<summary><b>Will it work on my existing server with websites on it?</b></summary>

It will run, but panel installers officially target **fresh systems**. On a
server with live sites, back everything up first and prefer a clean OS +
restore. The script warns you if it detects an existing panel.

</details>

<details>
<summary><b>My server is ARM64 — which panels work?</b></summary>

**HestiaCP, CloudPanel, Virtualmin and ISPConfig** officially support
`aarch64`. aaPanel/CyberPanel/FastPanel/CWP are x86_64-only — the script
will show them as incompatible with the reason.

</details>

<details>
<summary><b>Does the script test anything by running it?</b></summary>

Development follows one rule: **static checks only** (`bash -n`,
`shellcheck`) — the script itself is never executed automatically, because it
changes servers. You run it, on your machine, on your choice.

</details>

<details>
<summary><b>Where are logs and settings stored?</b></summary>

`/var/log/vps-webhoster.log` (fallback `/tmp/vps-webhoster-<uid>.log`) and
`~/.vps-webhoster.conf` for your language choice.

</details>

<details>
<summary><b>Can I switch panels later?</b></summary>

Yes: **Remove Panel Cleanly** → **Junk Cleaner** → install the new panel.
On production servers a fresh OS install is still the safest way.

</details>

---

## 🤝 Contributing & license

Bug fixes, panel updates (install commands change!) and Roman Urdu
improvements are welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md).

**License:** [MIT](./LICENSE) — Copyright (c) 2026 **Hayder**

<p align="center">
  Made with care by <b>Hayder</b><br>
  <a href="https://github.com/qamrixtech/vps-webhoster">⭐ Star this repo if it saved you a tutorial</a>
</p>
