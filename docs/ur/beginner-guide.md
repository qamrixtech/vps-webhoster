# 📘 Beginner Guide - Control Panel, SSH aur Aapka VPS

> **Zaban:** [English](../en/beginner-guide.md) | **اردو (Roman Urdu)**
>
> **VPS WebHoster** ka hissa - [README par wapsi](../../README.ur.md)

Ye guide un logon ke liye hai jinhone **kabhi** server nahi chalaya.
Har technical lafz ka sada urdu mein wazahat ke saath matlab bataya gaya hai.
Ek baar parh lijiye - jinke paas "hosting account" hai unko bhi aksar itna
nahi pata hota.

---

## Fehrist (Table of Contents)

1. [Server / VPS kya hai?](#1-server--vps-kya-hai)
2. [Website control panel kya hai?](#2-website-control-panel-kya-hai)
3. [SSH kya hai?](#3-ssh-kya-hai)
4. [Control panel vs SSH - asal farq](#4-control-panel-vs-ssh--asal-farq)
5. [Asal duniya ki misaalen](#5-asal-duniya-ki-misaalen)
6. [SSH se kaise connect karein (step by step)](#6-ssh-se-kaise-connect-karein-step-by-step)
7. [Aapko kya use karna chahiye?](#7-aapko-kya-use-karna-chahiye)
8. [Zaroori alfaz ka glossary](#8-zaroori-alfaz-ka-glossary)
9. [VPS lene ke baad pehle 9 kaam](#9-vps-lene-ke-baad-pehle-9-kaam)

---

## 1. Server / VPS kya hai?

**Server** ek aisa computer hai jo datacenter mein 24 ghante chalta rehta hai
aur aapki website visitors ko dikhata hai.

**VPS (Virtual Private Server)** ek badi physical machine ka chhota tukda hai,
jis ka apna RAM, CPU, disk aur IP address hota hai. Aap use mahana kiraye par
lete hain - Hetzner, Vultr, DigitalOcean, Contabo waghera se.

**Asal misaal:** VPS mall mein ek chhoti si dukan kiraye par lena jaisa hai.
Mall (datacenter) bijli aur security deta hai; dukan (VPS) aapki hai - andar
kya rakhna hai aap tay karte hain.

---

## 2. Website control panel kya hai?

**Website control panel** ek **web page** hai (browser mein khulta hai) jo
server ke mushkil commands ko **buttons aur forms** mein badal deta hai.

30 commands likhne ke bajaye aap sirf click karte hain:

```
Websites → Add Website → domain.com → PHP version choose → WordPress Install
```

Peeche us waqt Nginx ki config file edit hoti hai, database banta hai, SSL
lagta hai, cron set hota hai - sab kuch apne aap.

**Asal misaal:** control panel aapke **TV ka remote control** hai. Aap buttons
daba kar channel aur awaaz badalte hain - TV ke andar taaron ko chhue bagair.

Ek aur: ye **hotel ki reception desk** hai. Aap kehte hain "mujhe do raat ke
liye kamra chahiye" aur wo sab sambhal leta hai - kitchen, laundry aur
accounting aap nahi dekhte. Server ka andaruni hissa bhi aise hi chhupi rehta
hai.

**Panel se aap aam tor par ye kar sakte hain:**

- Websites aur subdomains banana
- WordPress / Joomla ek click mein install karna
- Database aur users banana
- Free SSL (Let's Encrypt) lagana
- Email accounts banana (agar panel mein mail server ho)
- DNS records sambhalna (www, mail, @ …)
- Files upload/edit, statistics dekhna, backups lena

---

## 3. SSH kya hai?

**SSH (Secure Shell)** aapke server ke **terminal tak encrypted connection**
hai - jahan aap *commands type* karte hain.

SSH mein aapke paas kala terminal hota hai aur mukammal control:

```bash
ls                      # files ki list
nano index.html         # file edit karo
systemctl restart nginx # web server restart
htop                    # RAM/CPU live dekho
```

**Asal misaal:** SSH **aapki apni chabi** hai server ke darwaze ki. Aap andar
ghus kar khud sab kuch chhoo sakte hain - taqatwar, lekin kuch gir bhi sakte
hain. Control panel hotel ka desk hai: aap request karte hain, wo karte hain.

**"Secure" kyun?** Aapke computer aur server ke darmiyan har cheez encrypted
hoti hai - password, files, commands. Purana FTP encrypted nahi tha, isi liye
SSH ne usay replace kar diya.

---

## 4. Control panel vs SSH - asal farq

| Pehlu | 🖥️ Control Panel | ⌨️ SSH |
|---|---|---|
| Dikhta kaisa hai | Web page, buttons, forms | Kala terminal, type ki gayi commands |
| Seekhna | Aasan - ghanton mein | Thoda mushkil - hafton mein |
| Naye logon ke liye speed | Tez (point & click) | Pehle ahista |
| Experts ke liye speed | Dheema (menus se) | Bohat tez (scripts se) |
| Kya chhoo sakte ho | Sirf jo panel de | **Poora server** |
| Galti ka khatra | Kam (safe buttons) | Zyada (ek ghalat command nuqsan) |
| Extra RAM kharch | Panel RAM use karta hai (50–500MB) | Zero, kuch nahi khata |
| Kis ke liye | Blogger, dukaandar, clients | Developer, sysadmin |
| Bina browser ke chale? | Nahi | Haan (sirf terminal) |

**Ye dushman nahi - teammates hain.**
Zyadatar log panel se roz ka kaam karte hain aur SSH un 5% kaamon ke liye
istemal karte hain jo panel nahi kar sakta (khaas tuning, debugging, ek dafa ki
scripts).

---

## 5. Asal duniya ki misaalen

### Misaal A - photographer (panel wala)

Amaan tasveerein lete hain aur unhe `amaanphotos.com` chahiye portfolio
gallery ke saath. Unko terminal ka pata nahi. Wo:

1. VPS khareed kar browser mein **control panel** mein login karte hain
2. **Add Website** click karte hain, domain daalte hain
3. **WordPress Install** click karte hain, theme choose karte hain
4. **SSL → Let's Encrypt → Save**

10 minute mein website live - ek bhi command type kiye bagair.
**SSH hota to:** `/etc/nginx/sites-available/…` edit karna, PHP install
karna, MySQL database khud banana, certbot set karna… 40+ minute ka tension.

### Misaal B - developer (SSH wala)

Bilal har raat app deploy karte hain. Ek script likhte hain:

```bash
#!/bin/bash
git pull
npm ci --omit=dev
pm2 restart app
```

…aur SSH se `./deploy.sh` chala dete hain - 4 second. Unke liye panel ke
click-click *dheeme* hain. Phir bhi kabhi logs ya SSL expiry dekhne panel
khol lete hain.

### Misaal C - hosting company (dono)

Sara 50 clients ki hosting bechti hain. Wo **reseller panel** (HestiaCP ya
ISPConfig) use karti hain taake har client ka apna limited login ho, aur
server-level maintenance SSH se karti hain. Panel unka shop-front hai; SSH
unka workshop.

### Misaal D - sirf 1GB ka VPS (is script ki wajah)

Aapne sasta 1GB VPS liya. Bhaari panel lagaya to server hamesha swap karta
rahega aur slow ho jayega. **VPS WebHoster** aapka RAM/CPU/OS naap kar
*sahi* panel top par rakhta hai - 1GB ke liye aaPanel (512MB se chalta hai),
4GB ke liye HestiaCP (mail + DNS ke saath).

---

## 6. SSH se kaise connect karein (step by step)

Provider ke email se 3 cheezein chahiye:

```
IP address    : 203.0.113.10
Username      : root
Password      : (ya SSH key file)
```

### Windows par

1. **PuTTY** install karein <https://www.putty.org/> se (ya *Windows
   Terminal* + `ssh`)
2. Host Name: `203.0.113.10`, Port: `22` → **Open** dabayein
3. Fingerprint accept karein → `root` likhein → password daalein
   *(password type karte waqt screen par nahi dikhta - ye normal hai)*

```text
login as: root
root@203.0.113.10's password:
root@server:~#
```

### macOS / Linux par

Terminal khol kar:

```bash
ssh root@203.0.113.10
```

### Login ke baad (pehle 5 commands)

```bash
hostnamectl              # ye server kaun hai?
df -h                    # disk mein kitni jagah free hai?
free -h                  # RAM kitna free hai?
apt update && apt upgrade -y   # (Debian/Ubuntu) sab update
# ya: dnf update -y             # (AlmaLinux/Rocky/CentOS)
```

Phir is project ka helper chalayein:

```bash
sudo bash vps-webhoster.sh
```

### Password vs key (bohat zaroori)

- **Password** - jaise dukaan ki chabi darwaze ke neeche chhod dein. Bots
  pore internet par har minute passwords aazmate hain.
- **SSH key** - 2 hisson wala keypair; private hissa network par kabhi travel
  nahi karta, is liye brute-force ho hi nahi sakta.

Apne computer par (server par nahi) keys banayein:

```bash
ssh-keygen -t ed25519
ssh-copy-id root@203.0.113.10
```

Phir password login band karein (`/etc/ssh/sshd_config` mein
`PasswordAuthentication no`). Script ki **Security → SSH tips** screen yehi
steps terminal ke andar bhi dikhati hai.

---

## 7. Aapko kya use karna chahiye?

Sirf ek sawaal pooch lein: **"Mujhe commands type karna pasand hai?"**

| Aap agar… | Ye shuru karein |
|---|---|
| Blogger / freelancer / dukaandar hain | **Control panel** (script khud recommend karta hai) |
| Developer hain jo code deploy karte hain | **SSH** (panel sirf database/SSL ke liye) |
| Hosting business chalate hain | **Reseller wala panel** (HestiaCP, ISPConfig) |
| 512MB–1GB VPS par hain | **Halka panel** (aaPanel) - script yehi batayega |
| Linux seriously seekhna chahte hain | Pehle SSH, baad mein panel |

**Sidhi baat:** control panel aapki pehli website aaj hi online le aata hai;
SSH zindagi bhar ke liye aapko confident banata hai. Abhi panel seekhein, har
hafta ek SSH command seekhein - mahine bhar mein na darr lagega panel se na
terminal se.

---

## 8. Zaroori alfaz ka glossary

| Lafz | Matlab |
|---|---|
| **VPS** | Aapka chhota sa kiraye ka server jo 24/7 chalta hai |
| **SSH** | Server tak encrypted terminal connection |
| **Control panel** | Browser wala server remote control |
| **Nginx / Apache** | Web server jo visitors ko pages bhejta hai |
| **PHP / Node.js / Python** | Programming languages jin mein websites banti hain |
| **MySQL / MariaDB** | Database jahan WordPress apni posts aur users rakhta hai |
| **PostgreSQL** | Zyada advanced SQL database (Hestia/ISPConfig/Virtualmin) |
| **DNS** | Phone book jo `example.com` ko aapke IP se jorta hai |
| **SSL / HTTPS** | Green lock; Let's Encrypt se free |
| **Varnish / Redis / PageSpeed** | Caching - site foran khulti hai |
| **Firewall** | Security gate jo traffic ko andar aane deti ya rokti hai |
| **fail2ban** | Jo IP baar baar password guess kare, use khud ban kar deta hai |
| **Domain** | Website ka asaan naam |
| **cPanel / Plesk** | Mashhoor **paid** panels - jaan bujh kar is script mein nahi |
| **Freemium** | Free core + paid extras (aaPanel Pro, CyberPanel Pro, CWP) |

---

## 9. VPS lene ke baad pehle 9 kaam

1. **SSH se connect karein** (section 6)
2. **System update karein** - `apt update && apt upgrade -y` ya `dnf update -y`
3. **Ye script chalayein** - `sudo bash vps-webhoster.sh`
4. **Recommended panel install karein** menu se
5. **Panel ka port kholein** (8083/8443/8090/…) apne provider ke
   firewall/security group mein - cloud firewall traffic ko aapke server tak
   pahunchne se *pehle* hi rok deta hai
6. **Har default password foran badlein**
7. **Firewall + fail2ban + auto-update chalu karein** (Security menu)
8. **Backup schedule lagayein** - backup ke bina server asal mein aapka nahi
9. **Pehli website panel ke andar add karein** 🎉

---

## 📚 Mazeed beginner guides

| Guide | Ismein kya seekhenge |
|---|---|
| [SSH kya hai?](./what-is-ssh.md) | Gehri baat: keys vs passwords, PuTTY, tunnels, har error ka hal |
| [WAF kya hai?](./what-is-waf.md) | Web Application Firewall, SQLi/XSS, har panel par kaise on karein |
| [Windows user ke liye Linux](./linux-for-windows-users.md) | Distribution kya hai, Debian vs RHEL, Windows↔Linux tarjuma |
| [Linux commands ki list](./linux-commands.md) | 100+ commands - taarif, misaal aur kab kaam aati hain |

---

> Banaya: **Hayder** · [VPS WebHoster GitHub](../../README.ur.md) ·
> MIT License · Koi galti mili? `docs/ur/` mein PR welcome hai!
