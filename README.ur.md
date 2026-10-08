<h1 align="center">VPS WEBHOSTER</h1>

<p align="center">
  <b>Beginners ke liye Free Website Control Panel Installer &amp; Server Toolkit</b><br>
  Aapka Linux server khud detect karta hai → sab se acha FREE panel recommend karta hai → uska official installer chalata hai
</p>

<p align="center">
  🌐 Language / زبان: &nbsp;<a href="./README.md">English</a> &nbsp;|&nbsp; <b>اردو (Roman Urdu)</b>
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
  <a href="#-menu-mein-kya-kya-hai">🧭 Menu</a> •
  <a href="#-8-panels">🖥️ Panels</a> •
  <a href="#-kaunsa-panel-choose-karein">⭐ Kaunsa panel?</a> •
  <a href="#-beginners-ke-liye-documentation">📘 Docs</a> •
  <a href="#-sawal-jawab">❓ FAQ</a>
</p>

---

> [!IMPORTANT]
> **Naya VPS khareeda hai aur samajh nahi aa raha kya karein?** Ye tool
> bilkul aapke liye hai. Ye aapka server detect karta hai, batata hai ke
> *aapke* RAM / CPU / distro par kaunsa control panel fit hai, uska **latest
> official installer** chalata hai, aur baad mein use saaf bhi hata deta hai
> — saath hi **English aur Roman Urdu** mein beginner guide built-in hai.

---

## 📚 Fehrist (Table of Contents)

- [Ye hai kya?](#-ye-hai-kya)
- [🚀 Quick Start](#-quick-start)
- [🧭 Menu mein kya kya hai?](#-menu-mein-kya-kya-hai)
- [🖥️ 8 Panels](#-8-panels)
- [⭐ Kaunsa panel choose karein?](#-kaunsa-panel-choose-karein)
- [🔍 Detection aur recommendation kaise kaam karti hai](#-detection-aur-recommendation-kaise-kaam-karti-hai)
- [🧹 Junk Cleaner aur 🗑️ Clean removal](#-junk-cleaner-aur-️-clean-removal)
- [💻 Command-line flags](#-command-line-flags)
- [📘 Beginners ke liye documentation](#-beginners-ke-liye-documentation)
- [❓ Sawal / Jawab](#-sawal-jawab)
- [🤝 Contributing aur license](#-contributing-aur-license)

---

## 🧾 Ye hai kya?

**VPS WebHoster** ek single Bash script hai jo khaali Linux VPS ko managed
hosting server bana deti hai — 50 tutorials parhe bagair.

| Ye karta hai | Ye NAHI karta |
|---|---|
| ✅ Ubuntu / Debian / AlmaLinux / Rocky / CentOS detect | ❌ Paid panels (cPanel, Plesk, DirectAdmin) chalata hai |
| ✅ `x86_64` / `aarch64`, RAM, CPU cores, disk detect | ❌ Command dikhaye bagair kuch bhi chalata hai |
| ✅ Terminal TUI banata hai (dialog/whiptail, plain fallback) | ❌ Aapki website files ya databases delete karta hai |
| ✅ **Aapki machine** ke liye sab se acha free panel recommend | ❌ Ye chhupata hai ke kaunsa panel incompatible hai aur kyun |
| ✅ Har panel ka latest **official** installer chalata hai | ❌ Bina confirmation ke install karta hai |
| ✅ Panels ko saaf hatata (services → packages → files → ports) | ❌ Server samajhne ki jagah nahi leta |
| ✅ Junk-cleaner, firewall, fail2ban, auto-updates, status | | |
| ✅ Beginner guide **English + Roman Urdu** mein | |

**Banaya: Hayder.** Hamesha ke liye free, MIT licensed.

---

## 🚀 Quick Start

VPS mein `root` se SSH karein, phir:

```bash
wget https://raw.githubusercontent.com/qamrixtech/vps-webhoster/main/vps-webhoster.sh
sudo bash vps-webhoster.sh
``

Ya poora repo clone karein (docs ke saath):

```bash
git clone https://github.com/qamrixtech/vps-webhoster.git
cd vps-webhoster
sudo bash vps-webhoster.sh
```

Phir menu ko follow karein:

```text
1. System Detection & Info      → dekhein aapka server kya hai
2. Install Control Panel        → "what will you host?" ka jawab dein → ★ recommended top par
3. Panel Details & Comparison   → har panel ke pros / cons (EN + Roman Urdu)
4. Remove Panel Cleanely        → uninstall + cleanup + verification
5. Junk Cleaner                 → disk jagah banayein (pehle/baad dikhata hai)
6. Security Hardening           → firewall + fail2ban + auto updates
7. Server Status Dashboard      → RAM, disk, ports, failed services
8. System Update & Upgrade
9. Beginner Guide               → English / Roman Urdu, terminal ke andar
10. Language & Settings
11. About / Credits
```

> [!TIP]
> **Naya (fresh) VPS use karein.** Panel installers officially saaf
> operating system maangte hain. Agar script ko pehle se panel mila to wo
> warn kar degi.

---

## 🧭 Menu mein kya kya hai?

<details>
<summary><b>1️⃣ System Detection &amp; Info</b> — kholne ke liye click karein</summary>

OS family, normalized version token, architecture, RAM, CPU cores, disk,
virtualization, public IP — aur **8 panels ka compatibility row** exact
wajah ke saath:

```text
 [OK ] HestiaCP         compatible — 1024MB min
 [OK ] CloudPanel       compatible — 2048MB min
 [--] CyberPanel        needs x86_64, you have aarch64
 [OK ] aaPanel          compatible — 512MB min
```

</details>

<details>
<summary><b>2️⃣ Install Website Control Panel</b> — ★ recommendation top par</summary>

1. Aap poochte hain **"What will you host?"**
   (WordPress/PHP · Node/Python/Go · Email + DNS + PostgreSQL ·
   Hosting business · Learning)
2. List **ranked** khulti hai — recommended panel sab se upar score aur
   wajah ke saath:

   ```text
   ★ RECOMMENDED (CloudPanel) - scored 87/100 - perfect RAM fit (4GB),
     best for WordPress/PHP, fits Debian 12 / x86_64 / 4 core(s)
   ```

3. Panel ke **features, fawada aur nuksaan** dikhte hain (English ya Roman
   Urdu)
4. **Exact official installer command** confirm hone se pehle dikhaya jata
   hai
5. Official interactive installer chalta hai
6. Summary screen: **panel URL, port, credentials kahan hain** aur kaunsa
   firewall port kholein

</details>

<details>
<summary><b>4️⃣ Remove Panel Cleanly</b> — kholne ke liye click karein</summary>

1. Marker paths se installed panel khud detect karta hai
2. Bara **PEHLE BACKUP LEIN** warning + confirmation
3. Panel-specific safaai: services band → packages purge → directories
   delete → banaye gaye users hatao
4. Optional: **poora web stack** (nginx/apache/PHP/database/mail) bhi
   utaarein ya rakhein
5. Report: marker gaya? ports band? koi panel bacha?

> [!WARNING]
> Panels system ko gehrai se badalte hain. Production server par fresh OS
> reinstall hi *guaranteed* saaf-safai hai. CWP ki apni docs bhi yahi
> kehti hain (unke paas uninstaller hi nahi hai).

</details>

<details>
<summary><b>5️⃣ Junk Cleaner</b> — kholne ke liye click karein</summary>

**Disk pehle/baad** ke saath checklist:

| Item | Kya karta hai |
|---|---|
| `pkgcache` | apt/dnf ke downloaded package cache |
| `autoremove` | faltu (orphaned) packages |
| `journal` | systemd journal 200MB tak |
| `oldlogs` | purane rotated logs (`*.gz`, `*.1`) |
| `tmp` | `/tmp` ki 7 din se purani files |
| `trash` | root ka trash |
| `kernels` | sirf 2 naye kernels rakhe |
| `docker` | sirf images + build cache, **volumes mehfooz** |
| `snap` | purane/disabled snap revisions |

`/var/www`, website files ya database dumps ko **kabhi** nahi chhoota.

</details>

<details>
<summary><b>6️⃣ Security Hardening</b> — kholne ke liye click karein</summary>

- **Firewall**: `ufw` (Debian/Ubuntu, incoming deny + SSH allow) ya
  `firewalld` (AlmaLinux/Rocky/CentOS)
- **fail2ban**: install + `sshd` jail wala `jail.local` + service enabled
- **Auto-updates**: `unattended-upgrades` / `dnf-automatic` / `yum-cron`
- **SSH tips**: key login, password auth band karna, non-root user, aur
  port badalna *asal* security nahi

</details>

---

## 🖥️ 8 Panels

Sab free ya freemium — **official docs** se verify kiye gaye (Oct 2026).

| # | Panel | License | Min RAM | Khaas baat |
|---|---|---|---|---|
| ⭐ | **[HestiaCP](https://hestiacp.com/docs/introduction/getting-started)** | 100% free (GPL) | 1 GB | **PostgreSQL + custom DNS + pura mail** — sab se mukammal cPanel alternative |
| ⭐ | **[CloudPanel](https://www.cloudpanel.io/docs/)** | Free CE | 2 GB | Sab se halka modern UI, **Varnish**, **MariaDB**, PHP/Node/Python/Go, ARM64 |
| | **[aaPanel](https://www.aapanel.com/docs/guide/quickstart.html)** | Free (Pro paid) | **512 MB** | Sab se kam RAM, Ubuntu+Debian+**Alma+Rocky**, free WAF |
| | **[CyberPanel](https://cyberpanel.net/KnowledgeBase/home/install-cyberpanel/)** | Free (Pro paid) | 1 GB | **OpenLiteSpeed** = sab se tez PHP/WordPress, PowerDNS |
| | **[Virtualmin GPL](https://www.virtualmin.com/download/)** | 100% free (GPL) | 1 GB | Sab se purana — mail, DNS, PostgreSQL, ARM64, taqatwar CLI |
| | **[ISPConfig](https://www.ispconfig.org/documentation/)** | 100% free (GPL) | 1 GB | Asal **multi-server** / reseller panel, ARM64 |
| | **[FastPanel](https://kb.fastpanel.direct/quick_start/how-to-install-fastpanel/)** | Free license | 1 GB | Modern UI, free **commercial** license, official uninstaller |
| | **[CWP](https://control-webpanel.com/installation-instructions)** | Free (Pro paid) | 2 GB | **AlmaLinux/Rocky** ke liye enterprise security |

<details>
<summary><b>Har panel ke pros &amp; cons (chhota version)</b> — poora bayan <a href="./docs/ur/panels.md">docs/ur/panels.md</a> mein</summary>

| Panel | ✅ Fawada | ❌ Nuksaan |
|---|---|---|
| **HestiaCP** | Waqai free, PostgreSQL + custom DNS + mail, ARM64, asaan UI | Poore stack ko 4 GB RAM; sirf Debian/Ubuntu; official uninstaller nahi |
| **CloudPanel** | Bohat halka, Varnish built-in, Node/Python/Go native, ARM64 | 2 GB min; mail server nahi; PostgreSQL nahi; sirf Debian/Ubuntu |
| **aaPanel** | 512 MB min, sab se bara OS support (Alma/Rocky bhi), free WAF | Advanced cheezein paid; ARM64 unofficial; promo banners |
| **CyberPanel** | Sab se tez PHP (OpenLiteSpeed), PowerDNS, Redis, unlimited free domains | x86_64 sirf; PostgreSQL nahi; Debian nahi; official uninstaller nahi |
| **Virtualmin** | 100% free, PostgreSQL+DNS+mail, RHEL+Debian+ARM64, bara CLI | Purana interface; thoda mushkil learning curve |
| **ISPConfig** | 100% free, asal multi-server, PostgreSQL, ARM64 auto-installer | Setup bhaari/ahista; simple UI; official uninstaller nahi |
| **FastPanel** | Free commercial license, modern UI, **official uninstall command** | x86_64 sirf; email license activation; chhota community |
| **CWP** | Taqatwar security (CSF, ClamAV, ModSecurity), acha PHP selector | Sirf RHEL; 2 GB min; **uninstaller nahi** ("OS reinstall karein") |

**Jaan bujh kar excluded:** VestaCP (unmaintained — HestiaCP lein), cPanel /
Plesk / DirectAdmin (paid), Sentora (chhoda hua).

</details>

---

## ⭐ Kaunsa panel choose karein?

Script ye khud tay karti hai — lekin asaan version:

| Aapka server / zaroorat | Choose karein |
|---|---|
| 512 MB–1 GB RAM, koi bhi distro | **aaPanel** |
| 2 GB+, Debian/Ubuntu, WordPress/PHP | **CloudPanel** |
| **Email + PostgreSQL + custom DNS** chahiye | **HestiaCP** |
| Sab se tez PHP/WordPress | **CyberPanel** |
| AlmaLinux / Rocky, kam RAM, beginner | **aaPanel** |
| **ARM64** VPS (Hetzner, AWS Graviton, Oracle) | **HestiaCP / CloudPanel / Virtualmin / ISPConfig** |
| Hosting business / resellers / clusters | **ISPConfig** ya **HestiaCP** |
| Pehla server, seekhna hai | **aaPanel** ya **HestiaCP** |

---

## 🔍 Detection aur recommendation kaise kaam karti hai

```text
/etc/os-release  →  ID + VERSION_ID  →  "ubuntu:24.04" / "almalinux:9" / "debian:12"
uname -m         →  x86_64 | aarch64
/proc/meminfo    →  RAM MB/GB
nproc            →  CPU cores
df               →  disk GB
```

Har panel ke paas **support matrix** hai (OS tokens × architecture × min
RAM × min disk). Jo fit nahi hota wo **exact wajah ke saath dim** dikhta hai
— chupke se nahi chhupaya jata.

Recommendation score khula hai:

| Factor | Points |
|---|---|
| RAM ≥ recommended | +25 |
| RAM ≥ 2× minimum | +15 |
| Sirf RAM ≥ minimum | +5 |
| ≥2 CPU cores | +10 |
| Use-case match (`node:cloudpanel`, `email:hestiacp`, …) | +18…+30 |
| Panel maturity base | +8…+15 |
| Distro-family native bonus | +8 |

---

## 🧹 Junk Cleaner aur 🗑️ Clean removal

Do beginners wale masle, do menu options:

- **Junk Cleaner** → disk jagah banata hai (cache, orphans, logs, purane
  kernels, trash) aur `pehle → baad` chhapta hai. Site files aur databases
  ko kabhi nahi chhoota.
- **Remove Panel Cleanly** → install ka ulta: services band, packages
  purge, files aur users delete, ports verify — plus optional poora
  web-stack purge.

Tafseel: **[docs/ur/script-guide.md](./docs/ur/script-guide.md)** ·
**[docs/en/script-guide.md](./docs/en/script-guide.md)**

---

## 💻 Command-line flags

```bash
bash vps-webhoster.sh --detect                 # system report (root nahi chahiye)
bash vps-webhoster.sh --list                   # sab panels + support matrix
bash vps-webhoster.sh --guide [--lang ur]      # beginner guide stdout par
bash vps-webhoster.sh --lang ur                # default guide language set

sudo bash vps-webhoster.sh --install hestiacp  # seedha installer mein
sudo bash vps-webhoster.sh --remove aapanel    # saaf removal
sudo bash vps-webhoster.sh --clean             # safe cleaning (ya --clean pkgcache,journal)
sudo bash vps-webhoster.sh --security          # firewall + fail2ban + auto updates
sudo bash vps-webhoster.sh --status            # status dashboard
sudo bash vps-webhoster.sh --update            # system upgrade
sudo bash vps-webhoster.sh --version           # version
```

---

## 📘 Beginners ke liye documentation

Har cheez do baar likhi hai — **English** aur **Roman Urdu (اردو)**:

| 📖 Roman Urdu (اردو) | 📖 English | Andar kya hai |
|---|---|---|
| [Beginner Guide](./docs/ur/beginner-guide.md) | [Beginner Guide](./docs/en/beginner-guide.md) | Control panel kya hai? SSH kya hai? Dono ka farq + asal duniya ki misaalen + PuTTY/Terminal se connect karna |
| [Panels](./docs/ur/panels.md) | [The Panels](./docs/en/panels.md) | Har panel ke features, **fawada & nuksaan**, official install/uninstall commands, kis ke liye |
| [Script Guide](./docs/ur/script-guide.md) | [Script Guide](./docs/en/script-guide.md) | Har menu option ki tafseel (junk cleaner samet), CLI flags, logging, troubleshooting |

> **Yahan se shuru karein agar aapne pehle kabhi server nahi chalaya:**
> [docs/ur/beginner-guide.md](./docs/ur/beginner-guide.md) —
> control panel = TV ka remote / hotel reception, SSH = server room ki aapki
> apni chabi. Ek baar parh kar sab clear ho jayega.

---

## ❓ Sawal / Jawab

<details>
<summary><b>Kya ye waqai free hai?</b></summary>

Haan — script MIT licensed hai aur list ka har panel free hai ya uska free
mode waqai kaam karta hai. Jin panels ke paid extras hain (aaPanel Pro,
CyberPanel Pro, CWP) unhe freemium mark kiya gaya hai. Sirf paid wale panels
bilkul shamil nahi.

</details>

<details>
<summary><b>Kya mere purane server (jisme websites hain) par chalega?</b></summary>

Chal jayega, lekin panel installers officially **clean system** maangte hain.
Live sites wale server par pehle sab ka backup lein aur fresh OS + restore
ko tarjeeh dein. Agar script ko maujooda panel mila to wo warn karti hai.

</details>

<details>
<summary><b>Mera server ARM64 hai — kaunse panels chalenge?</b></summary>

**HestiaCP, CloudPanel, Virtualmin aur ISPConfig** officially `aarch64`
support karte hain. aaPanel/CyberPanel/FastPanel/CWP x86_64-only hain —
script unhe wajah ke saath incompatible dikha degi.

</details>

<details>
<summary><b>Kya script khud test hoti hai?</b></summary>

Development ka ek usool hai: **sirf static checks** (`bash -n`,
`shellcheck`) — script ko khud kabhi automatically run nahi kiya jata kyunki
wo servers badal deti hai. Aap chalate hain, apni marzi par.

</details>

<details>
<summary><b>Logs aur settings kahan hote hain?</b></summary>

`/var/log/vps-webhoster.log` (fallback `/tmp/vps-webhoster-<uid>.log`) aur
zaban ki choice `~/.vps-webhoster.conf` mein.

</details>

<details>
<summary><b>Baad mein panel badal sakte hain?</b></summary>

Haan: **Remove Panel Cleanly** → **Junk Cleaner** → naya panel install.
Production servers par fresh OS install hi sab se mehfooz tareeqa hai.

</details>

---

## 🤝 Contributing aur license

Bug fixes, panel updates (install commands badalte rehte hain!) aur Roman
Urdu behtari welcome hai — dekhein [CONTRIBUTING.md](./CONTRIBUTING.md).

**License:** [MIT](./LICENSE) — Copyright (c) 2026 **Hayder**

<p align="center">
  <b>Hayder</b> ne ehtiaat se banaya<br>
  <a href="https://github.com/qamrixtech/vps-webhoster">⭐ Agar isne aapko ek tutorial bachaya ho to star dein</a>
</p>
