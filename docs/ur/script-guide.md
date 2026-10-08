# ⚙️ Script Guide - VPS WebHoster ke Har Option ki Tafseel

> **Zaban:** [English](../en/script-guide.md) | **اردو (Roman Urdu)**
>
> **VPS WebHoster** ka hissa - [README par wapsi](../../README.ur.md)

---

## Chalane ka tareeqa

```bash
# 1. download karein (ya repo clone karein)
wget https://raw.githubusercontent.com/qamrixtech/vps-webhoster/main/vps-webhoster.sh

# 2. menu chalayein
sudo bash vps-webhoster.sh
```

**Shartein:** naya-taza Linux VPS (Ubuntu, Debian, AlmaLinux, Rocky ya
CentOS), root access, aur internet.

Script pehle **aapka server detect** karti hai, phir menu dikhata hai:

```text
==============================================================
|   V P S   W E B H O S T E R                                |
|   Free Website Control Panel Installer & Server Toolkit    |
|   Made by Hayder                     v1.0.0                |
==============================================================
```

---

## Menu ka har option

### 1️⃣ System Detection & Info

Machine ke baare mein sab kuch chhapta hai:

- OS ka naam/family aur wo normalized version token jisse panels match hote hain
  (jaise AlmaLinux `9.5` → token `almalinux:9`)
- Architecture (`x86_64` ya `aarch64`) - yehi tay karta hai ke kaunse panel chal
  sakte hain
- RAM (MB/GB), CPU cores, disk, virtualization, public IP
- **8 panels ka compatibility row** - `[OK]` ya `[NO]` wajah ke saath (misal:
  "needs at least 2GB RAM, you have 1GB")
- Koi panel pehle se laga hua hai to uski report bhi

Kuch bhi ajeeb lage to pehle yahi kholein.

### 2️⃣ Install Website Control Panel

Project ka dil.

1. **"What will you host?"** - WordPress/PHP · Node/Python/Go · Email + full
   hosting · Hosting business · Learning. Yehi jawab recommendation engine
   ko chalata hai.
2. **List is tarah khulti hai:**
   - `RECOMMENDED (PanelName) - scored 87/100 - best for WordPress, fits your 4GB / amd64 / Debian 12`
   - phir baaki compatible panels
   - phir incompatible, wajah likhi hui
3. **Details screen** (features, fawada, nuksaan - English ya Roman Urdu, aapki
   marzi)
4. **Confirmation** mein chalta hua official installer command pehle dikhaya
   jata hai
5. **Official interactive installer** shuru hota - uske sawalon ke jawab dein
6. **ALL DONE screen** par panel URL, port, credentials kahan milenge aur
   firewall mein kaunsa port kholein

**Scoring logic (khula-rakha, taake aapko pata ho ke kyun recommend hua):**

| Factor | Points |
|---|---|
| Aapke OS/arch par compatible | zaroori (warna incompatible dikhta hai) |
| RAM ≥ recommended | +25 |
| RAM ≥ 2× minimum | +15 |
| RAM sirf minimum par (tight fit) | +5 |
| ≥2 CPU cores | +10 |
| Use-case match (misal `node:cloudpanel`) | +18…+30 |
| Panel ki maturity/popularity base | +8…+15 |
| Distro family ka native bonus | +8 |

### 3️⃣ Panel Details, Pros/Cons & Comparison

Kisi bhi panel ka poora bayan (bilingual) ya **comparison table** jo aapke
asal hardware par *"Support on THIS server"* section bhi dikhata hai.

### 4️⃣ Remove Panel Cleanly

1. 8 panels ke standard install paths scan karta hai
2. Jo mila wo dikhata hai - aap chunte hain
3. **Backup warning** (yehi aakhri aur asaan mauka hai backup karne ka)
4. Panel-specific safaai chalti hai:
   - uski services band + disable (web server, mail, DNS, database…)
   - uske packages remove
   - uske directories delete (`/usr/local/hestia`, `/www/server/panel`…)
   - uska system user hata dein agar banaya tha
5. Poochta hai ke **poora web stack** (nginx/apache/PHP/database/mail) bhi
   utaarein ya nahi - NO karein agar sites abhi bhi chahiyein
6. **Removal report**: marker gaya?, ports band?, koi panel bacha?

> ⚠️ Ye best-effort hai. Panels system configs gehrai se badalte hain -
> production server par fresh OS reinstall hi *guaranteed* saaf-safai hai.
> CWP ki apni docs bhi yahi kehti hain.

### 5️⃣ Junk Cleaner

Checklist (aap chunte hain kya saaf ho):

| Item | Kya karta hai | Mehfooz? |
|---|---|---|
| `pkgcache` | `apt clean` / `dnf clean` - downloaded package files | ✅ |
| `autoremove` | faltu (orphan) packages hatata hai | ✅ |
| `journal` | systemd journal logs 200MB tak kaat deta hai | ✅ |
| `oldlogs` | `/var/log` ke purane rotated logs (`*.gz`, `*.1`, `*.2`) | ✅ |
| `tmp` | `/tmp` ki 7 din se purani files | ✅ (7 din ka waqt) |
| `trash` | root ka trash khali karta hai | ✅ |
| `kernels` | sirf 2 naye kernels rakhta hai (RHEL: package-cleanup; apt: autoremove se) | ✅ |
| `docker` | `docker system prune -af` - dangling images & build cache, **volumes mehfooz** | ⚠️ confirm |
| `snap` | purane/disabled snap revisions | ✅ |

**Disk pehle aur baad** dono dikhata hai - pata chalta hai kitni jagah khali hui.
**Kabhi bhi** `/var/www`, website files ya database dumps nahi chhoota.

### 6️⃣ Security Hardening

- **Firewall** - Debian/Ubuntu par `ufw` (incoming deny, SSH allow) ya
  AlmaLinux/Rocky/CentOS par `firewalld` (ssh service allow)
- **fail2ban** - install karta hai, `jail.local` ke saath `sshd` jail banata
  hai aur service enable karta hai
- **Automatic updates** - Debian/Ubuntu par `unattended-upgrades`, Alma/Rocky
  par `dnf-automatic`, CentOS 7 par `yum-cron`
- **SSH tips** - key login, `PasswordAuthentication no`, non-root user, aur
  port badalna *asal* security nahi
- **Sab kuch ek saath** - `All of the above`

> Yaad rakhein: cloud providers ki **alag** firewall hoti hai (AWS Security
> Groups, Hetzner Cloud Firewall…). Sirf OS firewall se panel port nahi
> khulega.

### 7️⃣ Server Status Dashboard

Sirf-dekhne wala overview: hostname, uptime, load, RAM, disk, listening
ports, failed systemd services, mila hua panel + URL, memory ke top 5
processes.

### 8️⃣ System Update & Upgrade

`apt update && apt upgrade` ya `dnf/yum update`, phir reboot zaroori ho to
warn karta hai (`/var/run/reboot-required`, `needs-restarting`).

### 9️⃣ Beginner Guide

Poora beginner guide (control panel vs SSH, asal duniya ki misaalen,
glossary) terminal ke andar - **English** ya **Roman Urdu** mein.

### 🔟 Language & Settings

Guide ki zaban choose karein (`en` / `ur`). `~/.vps-webhoster.conf` mein save
ho jati hai aur agli baar wahi istemal hoti hai. Log file ki location bhi
yahan milti hai.

### 🪪 About / Credits

Version, author (**Hayder**), license (MIT), repository link.

---

## Command-line flags (bina menu ke)

```bash
bash vps-webhoster.sh --detect                 # system report (root nahi chahiye)
bash vps-webhoster.sh --list                   # sab panels + support matrix
bash vps-webhoster.sh --guide [--lang ur]      # beginner guide stdout par
bash vps-webhoster.sh --lang ur                # default guide language set

sudo bash vps-webhoster.sh --install hestiacp  # seedha installer mein
sudo bash vps-webhoster.sh --remove aapanel    # saaf removal (confirm poochta hai)
sudo bash vps-webhoster.sh --clean             # default safe cleaning
sudo bash vps-webhoster.sh --clean pkgcache,journal,oldlogs
sudo bash vps-webhoster.sh --security          # firewall + fail2ban + auto updates
sudo bash vps-webhoster.sh --status            # status dashboard
sudo bash vps-webhoster.sh --update            # system upgrade
sudo bash vps-webhoster.sh --yes --remove cwp  # confirmations skip (khatarnak!)
```

Panel ids: `hestiacp cloudpanel aapanel cyberpanel virtualmin ispconfig fastpanel cwp`

---

## Logging & troubleshooting

- **Main log:** `/var/log/vps-webhoster.log`
  (agar root-writable nahi: `/tmp/vps-webhoster-<uid>.log`)
- Har detection, recommendation aur removal step timestamp ke saath logged
  hota hai.

| Masla | Hal |
|---|---|
| "This action needs root" | aage `sudo` lagayein |
| "No terminal detected" | aapne script pipe ki hai - asal terminal mein chalayein |
| Menus bilkul plain lag rahe hain | `apt install dialog` (script khud poochti hai) |
| Installer bole "not a fresh OS" | zyada tar panels saaf server maangte hain - ya to OS reinstall karein ya maujooda stack hatayein |
| Port nahi khul raha | **cloud provider** ki firewall mein bhi kholein |
| ARM64 panel missing | sirf HestiaCP/CloudPanel/Virtualmin/ISPConfig officially ARM64 support karte hain - baaki script chhupa deti hai |
| Installer URL 404 | panel wale files hata dete hain - script mein `P_DOCS` se official docs page dekhein |
| Shuru se karna hai | Remove Panel → Junk Cleaner → dobara install |

---

## Safety design (script ye KABHI nahi karega)

- Panel installer bina **exact command** dikhaye nahi chalayega
- Maujooda panel hone par bina warning ke nahi install karega
- **Backup warning** aur confirmation ke bagair panel nahi hatayega
- Cleaning mein website files ya databases nahi delete karega
- Docker **volumes** nahi delete karta (sirf images/build cache)
- `--detect`, `--list`, `--guide` mein kuch bhi khatarnak nahi chalta

---

> Banaya: **Hayder** · [VPS WebHoster](../../README.ur.md) · MIT License
