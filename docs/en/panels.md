# 🖥️ The Panels — Every Free Control Panel, Explained

> **Language:** **English** | [اردو (Roman Urdu)](../ur/panels.md)
>
> Part of **VPS WebHoster** — [back to README](../../README.md)

Every panel in this list is **free to use** or has a genuinely usable **free
mode**. Paid panels (cPanel ≈ $15+/month, Plesk, DirectAdmin) are
deliberately **not** included.

---

## Quick comparison

| Panel | License | OS | Arch | Min RAM | Port | Standout |
|---|---|---|---|---|---|---|
| **HestiaCP** | 100% free (GPL) | Debian 12/13, Ubuntu 22.04/24.04/26.04 | x86 + **ARM64** | 1 GB* | 8083 | PostgreSQL + custom DNS + full mail |
| **CloudPanel** | Free CE | Debian 11/12/13, Ubuntu 22.04/24.04/26.04 | x86 + **ARM64** | 2 GB | 8443 | Lightest modern UI, Varnish, Node/Python |
| **aaPanel** | Free (Pro paid) | Ubuntu, Debian, AlmaLinux, Rocky, CentOS 9+ | x86_64 | **512 MB** | dynamic | Lowest RAM, works on both families |
| **CyberPanel** | Free (Pro paid) | Ubuntu 20.04/22.04/24.04, Alma/Rocky 8-9 | x86_64 | 1 GB | 8090 | OpenLiteSpeed — fastest PHP |
| **Virtualmin GPL** | 100% free (GPL) | Alma/Rocky 8-10, Debian 11/12, Ubuntu 20.04-24.04 | x86 + **ARM64** | 1 GB | 10000 | Most mature, full mail/DNS/PostgreSQL |
| **ISPConfig** | 100% free (GPL) | Debian 11/12/13, Ubuntu 22.04/24.04 | x86 + **ARM64** | 1 GB | 8080 | True multi-server / reseller |
| **FastPanel** | Free license | Debian 9-12, Ubuntu 18.04-24.04, Alma/Rocky 8 | x86_64 | 1 GB | 8888 | Modern UI, free commercial license |
| **CWP** | Free (Pro paid) | AlmaLinux 8/9, Rocky 8/9, CentOS | x86_64 | 2 GB | 2030 | Enterprise security focus |

\* HestiaCP: 1 GB works with a trimmed stack (no mail/antivirus); 4 GB is
recommended for the full experience.

---

## ⭐ Which one is recommended for YOUR server?

The script ranks them automatically using **your** RAM, CPU, distro and your
answer to *"What will you host?"*:

| Your situation | Recommended | Why |
|---|---|---|
| 512 MB–1 GB VPS, any distro | **aaPanel** | Only 512 MB needed, runs on Ubuntu/Debian/Alma/Rocky |
| 2+ GB, Debian/Ubuntu, PHP/WordPress | **CloudPanel** | Lightest UI + built-in Varnish caching |
| 2+ GB, want **email + PostgreSQL + custom DNS** | **HestiaCP** | The only free panel with all three out of the box |
| Fastest WordPress/PHP possible | **CyberPanel** | OpenLiteSpeed serves PHP fastest |
| AlmaLinux/Rocky, low RAM, beginner | **aaPanel** | Native RHEL-family support + easiest UI |
| ARM64 server (Hetzner/AWS Graviton) | **HestiaCP / Virtualmin / ISPConfig / CloudPanel** | The panels with official ARM64 support |
| Hosting business / many clients | **ISPConfig** or **HestiaCP** | Real multi-server or reseller packages |
| Learning / first server ever | **aaPanel** or **HestiaCP** | Easiest click-click interfaces |

---

## 1. HestiaCP — the most complete free cPanel alternative

- **Website/Docs:** <https://hestiacp.com/docs/introduction/getting-started>
- **License:** 100% free, GPL. No paid edition.
- **Install:**

  ```bash
  wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
  bash hst-install.sh
  ```

- **Uninstall:** no official one → use this script's **Remove Panel Cleanly**

**✅ Pros**

- Genuinely free with a huge, friendly community
- **PostgreSQL support** and **custom DNS (BIND + DNSSEC)** out of the box
- Full mail server (Exim + Dovecot) — you can host/sell email
- Works on **ARM64** as well as x86_64
- Clean interface designed for beginners (file manager, web terminal, API)
- One installer configures Nginx+Apache, MariaDB, FTP, fail2ban, backups

**❌ Cons**

- Full stack (mail + DNS + ClamAV + SpamAssassin) wants ~4 GB RAM
- Nginx+Apache combo uses more RAM than pure Nginx
- Debian/Ubuntu only — **no AlmaLinux/Rocky**
- No official uninstaller (third-party scripts exist; our script does a
  careful cleanup)

**Best for:** hosting businesses, resellers, anyone needing email hosting,
PostgreSQL or their own nameservers.

---

## 2. CloudPanel — best lightweight panel for PHP / Node / Python

- **Website/Docs:** <https://www.cloudpanel.io/docs/>
- **License:** Free Community Edition (source-available); Enterprise is paid
- **Install:**

  ```bash
  curl -sSL https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
  bash install.sh
  ```

- **Uninstall:** `apt remove --purge cloudpanel` (plus cleanup of MOTD/host
  changes — our script handles it)

**✅ Pros**

- Very low RAM/CPU footprint — the interface is extremely fast
- **Varnish cache built in** (their docs claim up to 250× faster pages)
- **MariaDB**, Redis, free SSL, 2FA, SFTP, monitoring
- **Node.js, Python and Go** projects natively supported — rare for panels
- **ARM64** supported
- Modern, no-nonsense developer UI

**❌ Cons**

- **No mail server** — use an external SMTP (Mailgun, SES, SendGrid)
- 2 GB RAM minimum
- **No PostgreSQL** (MariaDB/MySQL only)
- Community Edition is source-available, not OSI-approved open source
- Debian/Ubuntu only (no AlmaLinux/Rocky)

**Best for:** PHP/WordPress shops and Node/Python developers who want speed
and simplicity and don't need email hosting.

---

## 3. aaPanel — the lowest-RAM, widest-distro panel

- **Website/Docs:** <https://www.aapanel.com/docs/guide/quickstart.html>
- **License:** Free; advanced features are paid "Pro" plugins
- **Install:**

  ```bash
  URL=https://www.aapanel.com/script/install_panel_en.sh && \
  if [ -f /usr/bin/curl ];then curl -ksSO "$URL";else wget --no-check-certificate -O install_panel_en.sh "$URL";fi && \
  bash install_panel_en.sh forum
  ```

- **Uninstall:**

  ```bash
  service bt stop && update-rc.d -f bt remove && rm -f /etc/init.d/bt && rm -rf /www/server/panel
  ```

  (on RHEL-family use `chkconfig --del bt` instead of `update-rc.d`)

**✅ Pros**

- **512 MB RAM minimum**; the panel itself uses only ~60 MB
- Works on **Ubuntu, Debian, AlmaLinux, Rocky AND CentOS** — the widest OS
  support in this list
- Free **WAF** (web application firewall) included
- One-click LNMP/LAMP, app store, WP Toolkit, Docker manager, Node projects
- Easiest for a first-time server owner

**❌ Cons**

- Most advanced features are paid Pro plugins
- ARM64 is **unofficial/partial** — use an x86_64 VPS
- Interface shows promos for paid modules
- Smaller English-speaking community than Hestia/CyberPanel

**Best for:** small 1–2 GB VPS, AlmaLinux/Rocky users, absolute beginners.

---

## 4. CyberPanel — the speed panel (OpenLiteSpeed)

- **Website/Docs:** <https://cyberpanel.net/KnowledgeBase/home/install-cyberpanel/>
- **License:** Free edition (OpenLiteSpeed, unlimited domains) + paid
  CyberPanel Pro / LiteSpeed Enterprise
- **Install:**

  ```bash
  sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)
  ```

- **Uninstall:** no official one → this script's **Remove Panel Cleanly**

**✅ Pros**

- **Fastest PHP/WordPress performance** of any free panel (OpenLiteSpeed)
- **PowerDNS** included → easy custom nameservers
- Redis object caching, mail (Postfix+Dovecot), FTP, WordPress manager,
  Docker manager, backups, resellers
- Unlimited domains even on the free edition
- Ubuntu **and** AlmaLinux/Rocky support

**❌ Cons**

- **x86_64 only** — no ARM64 (their issue tracker still has the request open)
- **No PostgreSQL** (MariaDB only)
- **No Debian** (Ubuntu + Alma/Rocky only)
- No official uninstaller
- The installer asks several questions (LiteSpeed version, add-ons) — our
  script hands you straight into it

**Best for:** high-traffic WordPress/PHP sites where raw speed matters most.

---

## 5. Virtualmin GPL — the most mature, most complete free panel

- **Website/Docs:** <https://www.virtualmin.com/download/>
- **License:** 100% free, GPL. No paid edition exists.
- **Install:**

  ```bash
  curl -O https://software.virtualmin.com/install.sh
  sudo bash install.sh
  ```

- **Uninstall:** no official one → this script's **Remove Panel Cleanly**

**✅ Pros**

- 20+ years of development; the "old master" of free panels
- **PostgreSQL + BIND DNS + mail + FTP + quotas** — full classic hosting
- Supports **RHEL family AND Debian family**, including **ARM64**
- Extremely powerful CLI (`virtualmin` command) for automation
- 100+ Webmin modules extend everything

**❌ Cons**

- Interface looks dated next to CloudPanel/aaPanel
- Steeper learning curve for a total beginner
- Installs many services by default (disable what you don't need)

**Best for:** sysadmins, Debian/Alma users who want total control, free
PostgreSQL hosting, automation lovers.

---

## 6. ISPConfig — the professional multi-server panel

- **Website/Docs:** <https://www.ispconfig.org/documentation/>
- **License:** 100% free, GPL
- **Install:**

  ```bash
  wget -O - https://get.ispconfig.org | sh -s -- --interactive
  ```

- **Uninstall:** no official one → this script's **Remove Panel Cleanly**

**✅ Pros**

- 100% free with no paid tiers
- **True multi-server** — web, DNS, mail and DB can run on separate machines
  controlled from one interface
- MySQL **and** PostgreSQL, BIND DNS, mail, resellers, quotas
- **ARM64 supported** by the official auto-installer
- Uses standard Debian/Ubuntu packages under the hood (easy to debug)

**❌ Cons**

- Heavier and slower to install than CloudPanel/aaPanel
- Functional but plain interface
- No official uninstaller

**Best for:** hosting companies planning to grow into clusters; classic
ISP-style setups.

---

## 7. FastPanel — modern UI with a genuinely free license

- **Website/Docs:** <https://kb.fastpanel.direct/quick_start/how-to-install-fastpanel/>
- **License:** Free lifetime license for personal **and** commercial use
  (issued by email after install)
- **Install:**

  ```bash
  wget https://repo.fastpanel.direct/install_fastpanel.sh -O - | bash -
  ```

- **Uninstall (official):**

  ```bash
  # Debian/Ubuntu
  apt-get remove fastpanel2 fastpanel2-nginx
  # CentOS/AlmaLinux/Rocky
  yum remove fastpanel2 fastpanel2-nginx
  ```

**✅ Pros**

- Free license even for agencies selling hosting
- Very modern, clean, fast interface; HTTP/3 support
- **Official uninstall command** — rare among panels
- Debian **and** AlmaLinux/Rocky
- Choose your MySQL version during install

**❌ Cons**

- x86_64 only (no ARM64)
- Needs a free license activation via email
- Smaller community than Hestia/CyberPanel
- Must be installed on a **completely fresh OS**

**Best for:** freelancers/agencies who want a clean, commercial-friendly panel
without paying.

---

## 8. CWP (Control Web Panel) — enterprise security for AlmaLinux

- **Website/Docs:** <https://control-webpanel.com/installation-instructions>
- **License:** Free core + CWPpro paid
- **Install (AlmaLinux 9 / Rocky 9):**

  ```bash
  dnf install epel-release -y && dnf -y install wget && dnf -y update
  reboot
  # after reboot:
  cd /usr/local/src
  wget http://centos-webpanel.com/cwp-el9-latest
  sh cwp-el9-latest
  ```

  *(EL8 / AlmaLinux 8 uses `cwp-el8-latest`, CentOS 7 uses `cwp-el7-latest`)*

- **Uninstall:** **none** — their official statement: *"CWP does not include
  an uninstaller. To remove the software… a complete reinstallation of the
  server's OS is required."* Our script does a careful best-effort cleanup
  instead, but on a production server a fresh OS really is the safe answer.

**✅ Pros**

- Strong security tooling: firewall + CSF, ClamAV, ModSecurity
- Excellent PHP version selector for shared hosting
- Best-documented panel for AlmaLinux
- Root-based admin dashboard sysadmins like

**❌ Cons**

- **RHEL family only** (no Ubuntu/Debian)
- x86_64 only, 2 GB RAM minimum (4 GB recommended), static IP required
- Must run on a fresh OS
- No official uninstaller

**Best for:** AlmaLinux/Rocky servers hosting many PHP apps that need hardened
security.

---

## ⚠️ Panels we deliberately do NOT include

| Panel | Why excluded |
|---|---|
| **VestaCP** | Once popular, now **unmaintained** — security risk. Use HestiaCP (its maintained fork) instead. |
| **cPanel, Plesk, DirectAdmin, CyberPanel Enterprise** | Paid only / paid tiers are the product |
| **Sentora** | Largely abandoned |
| **Froxlor** | Great lightweight tool but more a "config manager" than a beginner panel — may be added later |

---

## 🔁 How to switch panels later

1. **Back up** website files and databases (panel → backup, or `mysqldump`)
2. In VPS WebHoster: **Remove Panel Cleanly** → choose whether to also purge
   the web stack
3. Reboot (recommended)
4. Run **Junk Cleaner** to free the leftovers
5. Install the new panel on the now-clean system

> On production servers, the safest way to "switch panels" is still a fresh
> OS install + restore. Only reuse the server if you understand what the
> removal script deleted.

---

> Made by **Hayder** · [VPS WebHoster](../../README.md) · MIT ·
> Install commands verified against official docs (Oct 2026).
