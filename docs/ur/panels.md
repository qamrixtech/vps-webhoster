# 🖥️ Panels - Har Free Control Panel ka Mukammal Bayan

> **Zaban:** [English](../en/panels.md) | **اردو (Roman Urdu)**
>
> **VPS WebHoster** ka hissa - [README par wapsi](../../README.ur.md)

Is list ka har panel **free** hai ya uska **free mode** waqai kaam karta hai.
Paid panels (cPanel ≈ $15+/month, Plesk, DirectAdmin) ko jaan bujh kar
**shamil nahi** kiya gaya.

---

## Phata-phat comparison

| Panel | License | OS | Arch | Min RAM | Port | Khaas baat |
|---|---|---|---|---|---|---|
| **HestiaCP** | 100% free (GPL) | Debian 12/13, Ubuntu 22.04/24.04/26.04 | x86 + **ARM64** | 1GB* | 8083 | PostgreSQL + custom DNS + pura mail |
| **CloudPanel** | Free CE | Debian 11/12/13, Ubuntu 22.04/24.04/26.04 | x86 + **ARM64** | 2GB | 8443 | Sab se halka modern UI, Varnish, Node/Python |
| **aaPanel** | Free (Pro paid) | Ubuntu, Debian, AlmaLinux, Rocky, CentOS 9+ | x86_64 | **512MB** | dynamic | Sab se kam RAM, dono family par chalta hai |
| **CyberPanel** | Free (Pro paid) | Ubuntu 20.04/22.04/24.04, Alma/Rocky 8-9 | x86_64 | 1GB | 8090 | OpenLiteSpeed - sab se tez PHP |
| **Virtualmin GPL** | 100% free (GPL) | Alma/Rocky 8-10, Debian 11/12, Ubuntu 20.04-24.04 | x86 + **ARM64** | 1GB | 10000 | Sab se purana, mail/DNS/PostgreSQL mukammal |
| **ISPConfig** | 100% free (GPL) | Debian 11/12/13, Ubuntu 22.04/24.04 | x86 + **ARM64** | 1GB | 8080 | Asal multi-server / reseller |
| **FastPanel** | Free license | Debian 9-12, Ubuntu 18.04-24.04, Alma/Rocky 8 | x86_64 | 1GB | 8888 | Modern UI, free commercial license |
| **CWP** | Free (Pro paid) | AlmaLinux 8/9, Rocky 8/9, CentOS | x86_64 | 2GB | 2030 | Enterprise security focus |

\* HestiaCP: 1GB par chhota stack (mail/antivirus ke bagair) chal jata hai;
poore experience ke liye 4GB recommended.

---

## ⭐ Aapke server ke liye kaunsa recommended hai?

Script **aapka** RAM, CPU, distro aur aapke jawab (*"What will you host?"*) ki
buniyad par ranking khud banati hai:

| Aapki soorat | Recommended | Wajah |
|---|---|---|
| 512MB–1GB VPS, koi bhi distro | **aaPanel** | Sirf 512MB chahiye, Ubuntu/Debian/Alma/Rocky sab par |
| 2GB+, Debian/Ubuntu, PHP/WordPress | **CloudPanel** | Sab se halka UI + built-in Varnish caching |
| 2GB+, **email + PostgreSQL + custom DNS** chahiye | **HestiaCP** | Wahid free panel jisme teeno shuru se hain |
| WordPress/PHP ki kachi speed chahiye | **CyberPanel** | OpenLiteSpeed PHP sab tez chalata hai |
| AlmaLinux/Rocky, kam RAM, beginner | **aaPanel** | Native RHEL support + sab se asaan UI |
| ARM64 server (Hetzner/AWS Graviton) | **HestiaCP / Virtualmin / ISPConfig / CloudPanel** | Inhi ka official ARM64 support hai |
| Hosting business / bohat clients | **ISPConfig** ya **HestiaCP** | Asal multi-server ya reseller packages |
| Pehla server, seekhna hai | **aaPanel** ya **HestiaCP** | Sab se asaan click-click interfaces |

---

## 1. HestiaCP - sab se mukammal free cPanel alternative

- **Docs:** <https://hestiacp.com/docs/introduction/getting-started>
- **License:** 100% free, GPL. Koi paid edition nahi.
- **Install:**

  ```bash
  wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
  bash hst-install.sh
  ```

- **Uninstall:** official nahi → is script ka **Remove Panel Cleanly** use karein

**✅ Fawada**

- Waqai free, bohat bara friendly community
- **PostgreSQL** aur **custom DNS (BIND + DNSSEC)** shuru se maujood
- Pura mail server (Exim + Dovecot) - email hosting bech sakte hain
- **ARM64** aur x86_64 dono par chalta hai
- Beginners ke liye saaf interface (file manager, web terminal, API)
- Ek installer: Nginx+Apache, MariaDB, FTP, fail2ban, backups - sab set

**❌ Nuksaan**

- Poora stack (mail + DNS + ClamAV + SpamAssassin) ko ~4GB RAM chahiye
- Nginx+Apache combo pure Nginx se zyada RAM khata hai
- Sirf Debian/Ubuntu - **AlmaLinux/Rocky nahi**
- Official uninstaller nahi (is script ka Remove option ehtiyat se saaf karta hai)

**Kis ke liye:** hosting business, reseller, jo email hosting, PostgreSQL ya
apne nameservers chahte hain.

---

## 2. CloudPanel - PHP / Node / Python ke liye sab se halka panel

- **Docs:** <https://www.cloudpanel.io/docs/>
- **License:** Free Community Edition; Enterprise paid hai
- **Install:**

  ```bash
  curl -sSL https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
  bash install.sh
  ```

- **Uninstall:** `apt remove --purge cloudpanel` (+ MOTD/host changes ki
  safaai - script khud karti hai)

**✅ Fawada**

- Kam RAM/CPU - interface bohat tez khulta hai
- **Varnish cache built-in** (docs ke mutabiq pages 250x tak tez)
- **MariaDB**, Redis, free SSL, 2FA, SFTP, monitoring
- **Node.js, Python, Go** projects ka native support (panels mein rare!)
- **ARM64** supported
- Modern, suthra developer UI

**❌ Nuksaan**

- **Mail server nahi** - bahar ka SMTP use karein (Mailgun, SES, SendGrid)
- 2GB RAM minimum
- **PostgreSQL nahi** (sirf MariaDB/MySQL)
- Community Edition source-available hai, pura OSI open-source nahi
- Sirf Debian/Ubuntu (AlmaLinux/Rocky nahi)

**Kis ke liye:** PHP/WordPress wale aur Node/Python developers jo speed aur
asaani chahte hain, email hosting nahi chahiye.

---

## 3. aaPanel - sab se kam RAM wala aur sab se zyada distro par chalne wala

- **Docs:** <https://www.aapanel.com/docs/guide/quickstart.html>
- **License:** Free; advanced cheezein paid "Pro" plugins
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

  (RHEL family par `update-rc.d` ki jagah `chkconfig --del bt`)

**✅ Fawada**

- **512MB RAM minimum**; khud panel sirf ~60MB use karta hai
- **Ubuntu, Debian, AlmaLinux, Rocky AND CentOS** - is list ka sab se wasee OS support
- **Free WAF** (web firewall) shamil
- One-click LNMP/LAMP, app store, WP Toolkit, Docker manager, Node projects
- Pehli baar server lene walon ke liye sab se aasaan hai

**❌ Nuksaan**

- Zyada tar advanced cheezein paid Pro plugins hain
- ARM64 **unofficial/partial** - x86_64 VPS lein
- Interface par paid modules ki promotion dikhti hai
- English community Hestia/CyberPanel jitni bari nahi

**Kis ke liye:** chhote 1–2GB VPS, AlmaLinux/Rocky users, bilkul naye log.

---

## 4. CyberPanel - speed ka panel (OpenLiteSpeed)

- **Docs:** <https://cyberpanel.net/KnowledgeBase/home/install-cyberpanel/>
- **License:** Free edition (OpenLiteSpeed, unlimited domains) + paid
  CyberPanel Pro / LiteSpeed Enterprise
- **Install:**

  ```bash
  sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)
  ```

- **Uninstall:** official nahi → is script ka **Remove Panel Cleanly**

**✅ Fawada**

- Kisi bhi free panel se **tez PHP/WordPress performance** (OpenLiteSpeed)
- **PowerDNS** shamil → apne nameservers banana aasan
- Redis object caching, mail (Postfix+Dovecot), FTP, WordPress manager,
  Docker manager, backups, resellers
- Free edition par bhi unlimited domains
- Ubuntu **aur** AlmaLinux/Rocky dono

**❌ Nuksaan**

- **Sirf x86_64** - ARM64 nahi (unke issue tracker par abhi bhi request pending)
- **PostgreSQL nahi** (sirf MariaDB)
- **Debian nahi** (Ubuntu + Alma/Rocky sirf)
- Official uninstaller nahi
- Installer kai sawaal puchta hai (LiteSpeed version, add-ons) - script
  seedha usi mein le jati hai

**Kis ke liye:** high-traffic WordPress/PHP sites jahan kachi speed zaroori ho.

---

## 5. Virtualmin GPL - sab se purana aur mukammal free panel

- **Docs:** <https://www.virtualmin.com/download/>
- **License:** 100% free, GPL. Koi paid edition hi nahi.
- **Install:**

  ```bash
  curl -O https://software.virtualmin.com/install.sh
  sudo bash install.sh
  ```

- **Uninstall:** official nahi → is script ka **Remove Panel Cleanly**

**✅ Fawada**

- 20+ saal ka development; free panels ka "ustad"
- **PostgreSQL + BIND DNS + mail + FTP + quotas** - pura classic hosting
- **RHEL family AND Debian family**, **ARM64** ke saath
- Bohat taqatwar CLI (`virtualmin` command) automation ke liye
- 100+ Webmin modules se har cheez extend ho jati hai

**❌ Nuksaan**

- Interface CloudPanel/aaPanel ke muqable purana lagta hai
- Total beginner ke liye seekhna thoda mushkil
- Default mein yeh bohat si services install kar deta hai (faltu wale band karein)

**Kis ke liye:** sysadmins, Debian/Alma users jo mukammal control chahte hain,
free PostgreSQL hosting, automation pasand karne wale.

---

## 6. ISPConfig - professional multi-server panel

- **Docs:** <https://www.ispconfig.org/documentation/>
- **License:** 100% free, GPL
- **Install:**

  ```bash
  wget -O - https://get.ispconfig.org | sh -s -- --interactive
  ```

- **Uninstall:** official nahi → is script ka **Remove Panel Cleanly**

**✅ Fawada**

- 100% free, koi paid tier nahi
- **Asal multi-server** - web, DNS, mail aur DB alag machines par chalti hain,
ek interface se control hoti hain
- MySQL **aur** PostgreSQL, BIND DNS, mail, resellers, quotas
- Official auto-installer mein **ARM64 support**
- Neeche standard Debian/Ubuntu packages istemal hote hain (debug karna aasaan)

**❌ Nuksaan**

- CloudPanel/aaPanel ke muqable install karna bhaari aur ahista hai
- Kaam ka lekin simple interface
- Official uninstaller nahi

**Kis ke liye:** hosting companies jinhe aage barh kar clusters banane hain;
classic ISP-style setup.

---

## 7. FastPanel - modern UI + waqai free license

- **Docs:** <https://kb.fastpanel.direct/quick_start/how-to-install-fastpanel/>
- **License:** Free lifetime license - personal **aur** commercial dono ke
  liye (install ke baad email se milti hai)
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

**✅ Fawada**

- Un agencies ke liye bhi free license jo hosting bechti hain
- Bohat modern, saaf, tez interface; HTTP/3 support
- **Official uninstall command** - panels mein rare!
- Debian **aur** AlmaLinux/Rocky
- Install ke waqt MySQL version choose kar sakte hain

**❌ Nuksaan**

- Sirf x86_64 (ARM64 nahi)
- Email se free license activation zaroori
- Hestia/CyberPanel jitna bara community nahi
- **Sirf bilkul fresh OS** par hi install ho sakta hai

**Kis ke liye:** freelancers/agencies jinhe bina kisi paise ke commercial-friendly
saaf panel chahiye.

---

## 8. CWP (Control Web Panel) - AlmaLinux ke liye enterprise security

- **Docs:** <https://control-webpanel.com/installation-instructions>
- **License:** Free core + CWPpro paid
- **Install (AlmaLinux 9 / Rocky 9):**

  ```bash
  dnf install epel-release -y && dnf -y install wget && dnf -y update
  reboot
  # reboot ke baad:
  cd /usr/local/src
  wget http://centos-webpanel.com/cwp-el9-latest
  sh cwp-el9-latest
  ```

  *(EL8 / AlmaLinux 8 ke liye `cwp-el8-latest`, CentOS 7 ke liye `cwp-el7-latest`)*

- **Uninstall:** **koi nahi** - unki official baat: *"CWP mein uninstaller
  nahi hai. Hatane ke liye… server ka OS dobara install karna padta hai."*
  Hamara script ehtiyat se best-effort safaai karta hai, lekin production
  server par fresh OS hi mehfooz jawab hai.

**✅ Fawada**

- Taqatwar security tools: firewall + CSF, ClamAV, ModSecurity
- Shared hosting ke liye zabardast PHP version selector
- AlmaLinux ke liye sab se behtar documentation
- Root-based admin dashboard jo sysadmins ko pasand hai

**❌ Nuksaan**

- **Sirf RHEL family** (Ubuntu/Debian nahi)
- Sirf x86_64, 2GB RAM minimum (4GB recommended), static IP zaroori
- Fresh OS par hi chal sakta hai
- Official uninstaller nahi

**Kis ke liye:** AlmaLinux/Rocky servers jahan bohat si PHP apps chalti hain
aur hardened security chahiye.

---

## ⚠️ Panels jo jaan bujh kar shamil NAHI kiye

| Panel | Wajah |
|---|---|
| **VestaCP** | Kabhi mashhoor tha, ab **unmaintained** - security risk. Iski jagah HestiaCP (iska maintained fork) lein. |
| **cPanel, Plesk, DirectAdmin, CyberPanel Enterprise** | Sirf paid / paid tier hi asal product hai |
| **Sentora** | Ziyada tar chhod diya gaya |
| **Froxlor** | Acha halka tool hai lekin beginner panel se zyada "config manager" hai - baad mein shamil ho sakta hai |

---

## 🔁 Baad mein panel kaise badlein

1. **Backup lein** - website files aur databases (panel → backup ya `mysqldump`)
2. VPS WebHoster mein: **Remove Panel Cleanly** → poochega poora web stack
   bhi utaarna hai ya nahi
3. Reboot (recommended)
4. **Junk Cleaner** se bachi hui gandagi saaf karein
5. Naye saaf system par naya panel install karein

> Production server par panel badalne ka sab se mehfooz tareeqa phir bhi
> fresh OS install + restore hai. Sirf tab reuse karein jab aapko pata ho ke
> removal script ne kya-kya hataya.

---

> Banaya: **Hayder** · [VPS WebHoster](../../README.ur.md) · MIT ·
> Install commands official docs se verify kiye gaye (Oct 2026).
