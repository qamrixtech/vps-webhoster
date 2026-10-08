# 🐧 What are Linux Distributions? (A Guide for Windows Users)

> **Language:** **English** | [اردو (Roman Urdu)](../ur/linux-for-windows-users.md)
>
> Part of **VPS WebHoster** - [back to README](../../README.md)

If you have only ever used Windows, this page translates the whole Linux
world into Windows terms.

---

## 1. What is Linux?

**Linux** is a **kernel** (the core that talks to hardware) that is free and
open source. On its own it shows nothing - no desktop, no apps.

To sell or use it, someone must **package** the kernel together with tools,
a package manager, installers and support. That complete package is called
a **distribution** ("distro" for short).

**Analogy:** Linux is like an **engine**. A distro is a **complete car**
built around that engine - with a dashboard, seats and a paint job.

---

## 2. Windows versions vs Linux distros

| Windows world | Linux world |
|---|---|
| Windows 10, Windows 11, Windows Server | Ubuntu, Debian, AlmaLinux, Fedora, Mint... |
| One company makes it (Microsoft) | Hundreds of communities/companies make their own |
| You buy a license | Usually **free** (as in no cost *and* open source) |
| Updates arrive from Microsoft Update | Each distro has its own repositories + `apt`/`dnf` |
| .exe / .msi installers | `.deb` / `.rpm` packages, or `apt`/`dnf` commands |
| One look and feel (mostly) | Different desktops: GNOME, KDE, XFCE... |
| Ships on most laptops | Rare on laptops, **dominant on servers & phones** |

> **Fun fact:** Android is Linux. So are most routers, smart TVs, the
> International Space Station's laptops, and ~96% of the world's top
> servers.

---

## 3. Why are there so many distros?

Because anyone can take the Linux kernel and tune it for a purpose:

```text
                        Linux kernel
                              |
   +--------------------------+---------------------------+
   |                          |                           |
 Debian                   Red Hat family              Others
 (stability)              (enterprise)          Arch (DIY), openSUSE,
   |                          |                 Fedora (cutting edge)...
 Ubuntu (beginner-friendly) AlmaLinux / Rocky
   |                         (free rebuilds of
 Mint, Pop!_OS,             RHEL - what we use
 Kali (security)            for servers)
```

**Two families matter for servers:**

- **Debian family** - uses `apt`, packages are `.deb`
  → **Ubuntu, Debian**
- **RHEL family** (Red Hat) - uses `dnf`/`yum`, packages are `.rpm`
  → **AlmaLinux, Rocky Linux, CentOS Stream, Fedora**

Everything else is a variation on these two for our purposes.

---

## 4. Which distro should a beginner pick?

### For a desktop/laptop (replacing Windows)

| Distro | Best for |
|---|---|
| **Linux Mint** | Closest "Windows feel", gentle start |
| **Ubuntu** | Huge support, works everywhere |
| **Pop!_OS** | Gamers/creators, great NVIDIA support |
| **Fedora** | Modern features first |

### For a VPS/server (what this project is about)

| Distro | Pick it when... | Package tool |
|---|---|---|
| **Ubuntu 24.04** | You're new; you want tutorials to "just work" | `apt` |
| **Debian 12/13** | You want rock-solid stability, fewer updates | `apt` |
| **AlmaLinux 9/10** | You want RHEL-compatible, cPanel-style enterprise feel | `dnf` |
| **Rocky Linux 9/10** | Same as Alma (community alternative) | `dnf` |
| **CentOS Stream** | You want to be upstream/close to RHEL releases | `dnf` |

> [!TIP]
> **Start with Ubuntu or Debian.** The docs for almost every panel, plugin
> and tool assume them. `VPS WebHoster` supports Ubuntu, Debian, AlmaLinux,
> Rocky and CentOS, and it detects which family you're on automatically.

---

## 5. Day-to-day differences from Windows

### Drives and paths

```text
Windows                          Linux
C:\                  →           /              (root of everything)
C:\Users\Hayder      →           /home/hayder
C:\Program Files     →           /usr/bin, /opt, /var...
D:\ (second disk)    →           /mnt/data      (you mount it)
Backslash \          →           Forward slash /
```

There are **no drive letters**. Everything hangs off a single tree starting
at `/`.

### Users and permissions

- In Windows, you click "Run as administrator".
- In Linux you use **`sudo`** in front of a command to run it as the boss:

  ```bash
  apt update          # normal user: refused
  sudo apt update     # allowed: runs as root
  ```

- The super-user is called **`root`** (there is no built-in "Administrator"
  account everyone shares).

### Installing software

| Windows | Linux |
|---|---|
| Download an .exe from a website | `sudo apt install nginx` (from trusted repos) |
| Microsoft Store | `snap` / `flatpak` (app stores, optional) |
| "Add or remove programs" | `sudo apt remove nginx` |
| Manual uninstall | `sudo apt purge nginx` |

**Never install software by downloading random `.sh` scripts from blogs.**
Use the distro's repositories or the software's official installer (which is
exactly what VPS WebHoster does for control panels).

### The desktop itself

- **Windows:** one desktop environment, made by Microsoft
- **Linux:** the desktop is replaceable -
  - **GNOME** (Ubuntu default) - clean, macOS-ish
  - **KDE Plasma** - highly Windows-like, customizable
  - **XFCE** - light, for old machines

This is why Linux screenshots all look different.

### The terminal

On Windows you have PowerShell/cmd. On Linux the terminal is **first-class**:
most admin work (servers especially) happens there. Don't fear it; half of
this project's menu exists so you *can* avoid it.

---

## 6. Command cheat-sheet translation

| Task | Windows | Linux |
|---|---|---|
| List files | `dir` | `ls` |
| Change folder | `cd` | `cd` |
| Copy/move | `copy` / `move` | `cp` / `mv` |
| Delete | `del` | `rm` |
| Find text | Notepad++ search | `grep` |
| See running apps | Task Manager | `top`, `htop`, `ps` |
| Kill an app | End task | `kill PID` |
| See network config | `ipconfig` | `ip a` |
| Test connection | `ping` | `ping` |
| Find your IP | `ipconfig` | `ip a` or `hostname -I` |
| Disk space | Explorer → This PC | `df -h` |
| Check services | Services.msc | `systemctl status nginx` |
| Logs | Event Viewer | `journalctl -u nginx` |
| Install a package | Download .exe | `sudo apt install pkg` |

Full details: **[Linux commands cheat sheet](./linux-commands.md)**

---

## 7. Can I try Linux without giving up Windows?

Absolutely:

1. **WSL** (Windows Subsystem for Linux) - install Ubuntu *inside Windows*:

   ```powershell
   wsl --install
   ```

   Best for learning commands safely.

2. **Live USB** - boot Ubuntu from a USB stick; your Windows stays untouched.

3. **VirtualBox/VMware** - run a full Linux desktop in a window.

4. **A cheap VPS** - the real thing, and it's what this project is for
   (often $3–6/month, or free tiers for students).

---

## 8. Is Linux harder than Windows?

| For... | Verdict |
|---|---|
| Browsing, email, documents | No - Mint/Ubuntu are as easy as Windows |
| Gaming | Much better than 5 years ago, still behind Windows for some titles |
| Learning curve | A weekend for basics; fluency in a few weeks |
| Servers | **Easier and safer** than Windows Server for most hosting |
| Cost | Free (Windows licenses cost real money) |
| Malware | Far fewer viruses (but not zero - you still update and use a firewall) |

**For servers the question barely arises:** nearly all hosting control
panels (cPanel, Plesk, HestiaCP, CloudPanel...) run on Linux only. Windows
Server hosting exists but is niche and expensive.

---

## 9. Glossary: Windows term → Linux term

| Windows | Linux |
|---|---|
| Drive `C:` | Root filesystem `/` |
| Explorer | Files (Nautilus/Dolphin) or `ls` |
| Control Panel / Settings | `settings` app or terminal tools |
| PowerShell / CMD | Shell (`bash`, `zsh`) |
| Administrator | `root` / `sudo` |
| Task Manager | `htop` / `gnome-system-monitor` |
| Services.msc | `systemctl` |
| Event Viewer | `journalctl` / `/var/log/*` |
| .exe / .msi | `.deb` / `.rpm` / AppImage / Flatpak |
| Windows Update | `apt update && apt upgrade` / `dnf update` |
| Registry | Config files in `/etc` (plain text!) |
| Windows Defender | ClamAV (free) + common sense + WAF |
| Firewall (Windows Security) | `ufw` / `firewalld` |
| Drive letters A:, B:, C: | Mount points `/`, `/home`, `/mnt/...` |

---

## 10. Your first 30 minutes on a Linux VPS

```bash
# 1. what am I on?
cat /etc/os-release

# 2. update everything
sudo apt update && sudo apt upgrade -y     # Debian/Ubuntu
# sudo dnf update -y                       # AlmaLinux/Rocky/CentOS

# 3. see resources
df -h && free -h && nproc

# 4. run this project's helper
sudo bash vps-webhoster.sh
```

The script's **System Detection** screen does steps 1 and 3 for you and
recommends a control panel that actually fits *your* distro and hardware.

---

> Made by **Hayder** · [VPS WebHoster](../../README.md) · MIT ·
> More: [What is SSH?](./what-is-ssh.md) · [What is a WAF?](./what-is-waf.md) ·
> [Linux commands cheat sheet](./linux-commands.md)
