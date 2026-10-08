# 📘 Beginner Guide — Control Panels, SSH & Your VPS

> **Language:** **English** | [اردو (Roman Urdu)](../ur/beginner-guide.md)
>
> Part of **VPS WebHoster** — [back to README](../../README.md)

This guide is written for someone who has **never** touched a server before.
No jargon without an explanation. Read it once and you will understand more
about servers than most people who "have a hosting account".

---

## Table of contents

1. [What is a server / VPS?](#1-what-is-a-server--vps)
2. [What is a website control panel?](#2-what-is-a-website-control-panel)
3. [What is SSH?](#3-what-is-ssh)
4. [Control panel vs SSH — the real difference](#4-control-panel-vs-ssh--the-real-difference)
5. [Real-world examples that make it click](#5-real-world-examples-that-make-it-click)
6. [How to connect with SSH (step by step)](#6-how-to-connect-with-ssh-step-by-step)
7. [Which should YOU use?](#7-which-should-you-use)
8. [Glossary of important words](#8-glossary-of-important-words)
9. [First steps after buying a VPS](#9-first-steps-after-buying-a-vps)

---

## 1. What is a server / VPS?

A **server** is a computer that is switched on 24/7 inside a datacenter and
serves your website to visitors.

A **VPS (Virtual Private Server)** is a small slice of a big physical machine,
with its own RAM, CPU, disk and IP address. You rent it monthly from providers
like Hetzner, Vultr, DigitalOcean, Contabo, etc.

**Real-world analogy:** a VPS is like renting a small shop in a big mall. The
mall (datacenter) provides electricity and security; the shop (VPS) is yours —
you decide what goes inside.

---

## 2. What is a website control panel?

A **website control panel** is a **web page** (opened in your browser) that
turns complicated server commands into **buttons and forms**.

Instead of typing 30 commands to create a website, you click:

```
Websites → Add Website → domain.com → pick PHP version → Install WordPress
```

Behind the scenes it edits Nginx config files, creates databases, issues SSL
certificates, sets cron jobs — all the things you would otherwise type.

**Real-world analogy:** a control panel is the **remote control of your TV**.
You change channels and volume by pressing buttons, without ever touching the
wiring inside the TV.

Or another one: it is the **reception desk of a hotel**. You say "I need a
room for 2 nights" and they handle keys, registration and billing. You never
see the kitchen, laundry or accounting — that's the server's internals.

**What you can usually do from a panel:**

- Create websites and subdomains
- Install WordPress / Joomla / apps in one click
- Create databases and users
- Attach free SSL certificates (Let's Encrypt)
- Manage email accounts (if the panel has a mail server)
- Manage DNS records (www, mail, @ …)
- Upload/edit files, see statistics, make backups

---

## 3. What is SSH?

**SSH (Secure Shell)** is an **encrypted connection to your server's terminal**
— the place where you *type commands*.

With SSH you get a black window (terminal) and full control:

```bash
ls                      # list files
nano index.html         # edit a file
systemctl restart nginx # restart the web server
htop                    # watch RAM/CPU live
```

**Real-world analogy:** SSH is **your own key to the server's door**. You walk
into the room and touch everything yourself — powerful, but you can also knock
something over. The control panel is the hotel desk: you request, they do.

**Why "secure"?** Everything between your computer and the server is
encrypted — passwords, files, commands. Plain old FTP is *not* encrypted,
which is why SSH replaced it.

---

## 4. Control panel vs SSH — the real difference

| Aspect | 🖥️ Control Panel | ⌨️ SSH |
|---|---|---|
| How it looks | Web page, buttons, forms | Black terminal, typed commands |
| Learning curve | Easy — hours | Steeper — days/weeks |
| Speed for beginners | Fast (point & click) | Slow at first |
| Speed for experts | Slower (menus) | Very fast (scripted) |
| What you can touch | Only what the panel exposes | **Everything** |
| Risk of mistakes | Lower (safe buttons) | Higher (a wrong command can break things) |
| Extra cost | Uses server RAM (50MB–500MB) | Free, uses nothing |
| Best for | Bloggers, shop owners, clients | Developers, sysadmins |
| Works without internet browser? | No | Yes (terminal only) |

**They are not rivals — they are teammates.**
Most people use the panel for daily work and SSH for the 5% of tasks the panel
cannot do (special tuning, debugging, one-off scripts).

---

## 5. Real-world examples that make it click

### Example A — the photographer (panel person)

Amaan takes photos and wants `amaanphotos.com` with a portfolio gallery. He
does not know what a terminal is. He:

1. Buys a VPS, opens the browser, logs into the **control panel**
2. Clicks **Add Website**, enters the domain
3. Clicks **Install WordPress**, picks a theme
4. Clicks **SSL → Let's Encrypt → Save**

Her site is live in ~10 minutes without typing a single command.
**SSH would have meant:** editing `/etc/nginx/sites-available/…`, installing
PHP, creating a MySQL database by hand, configuring certbot… 40+ minutes of
stress for someone who just wanted a portfolio.

### Example B — the developer (SSH person)

Bilal deploys his app every night. He writes one script:

```bash
#!/bin/bash
git pull
npm ci --omit=dev
pm2 restart app
```

…and runs `./deploy.sh` over SSH in 4 seconds. For him a panel's click-click
would be *slower*. He still opens the panel occasionally to read logs or check
SSL expiry with his eyes.

### Example C — the hosting company (both)

Sara sells hosting to 50 clients. She uses a **reseller-capable panel**
(HestiaCP or ISPConfig) so each client gets their own limited login, and she
uses SSH for server-level maintenance. The panel is her shop front; SSH is
her workshop.

### Example D — the tiny 1 GB VPS (why this script exists)

You bought the cheapest 1 GB VPS. Installing a heavy panel means constant
swapping and a slow server. **VPS WebHoster** measures your RAM/CPU/OS and
puts the *right* panel on top — for 1 GB it recommends aaPanel (runs from
512 MB), for 4 GB it may recommend HestiaCP with mail + DNS.

---

## 6. How to connect with SSH (step by step)

You need 3 things from your provider's email:

```
IP address    : 203.0.113.10
Username      : root
Password      : (or an SSH key file)
```

### On Windows

1. Install **PuTTY** from <https://www.putty.org/> (or use *Windows Terminal* + `ssh`)
2. Host Name: `203.0.113.10`, Port: `22` → click **Open**
3. Accept the fingerprint → type `root` → type the password
   *(the password is invisible while typing — that's normal)*

```text
login as: root
root@203.0.113.10's password:
root@server:~#
```

### On macOS / Linux

Open the built-in Terminal and type:

```bash
ssh root@203.0.113.10
```

### After logging in (your first 5 commands)

```bash
hostnamectl              # what is this server?
df -h                    # how much disk is free?
free -h                  # how much RAM is free?
apt update && apt upgrade -y   # (Debian/Ubuntu) update everything
# or: dnf update -y             # (AlmaLinux/Rocky/CentOS)
```

Then run this project's helper:

```bash
sudo bash vps-webhoster.sh
```

### Password vs key (important)

- **Password** — like leaving your shop key under the doormat. Bots scan the
  whole internet trying passwords every minute.
- **SSH key** — a 2-part keypair; the private half never travels the network,
  so it cannot be brute-forced.

Create keys on *your* computer:

```bash
ssh-keygen -t ed25519
ssh-copy-id root@203.0.113.10
```

Then disable password login (`PasswordAuthentication no` in
`/etc/ssh/sshd_config`). The script's **Security → SSH tips** screen repeats
these steps inside the terminal.

---

## 7. Which should YOU use?

Ask yourself one question: **"Do I enjoy typing commands?"**

| If you are… | Start with |
|---|---|
| A blogger / freelancer / shop owner | **Control panel** (this script picks one for you) |
| A developer who deploys code | **SSH** (+ panel only for databases/SSL) |
| Running a hosting business | **Panel with resellers** (HestiaCP, ISPConfig) |
| On a 512 MB–1 GB VPS | **Light panel** (aaPanel) — the script will recommend it |
| Learning Linux seriously | SSH first, add a panel later |

**The honest answer:** a control panel gets your first website online today;
SSH makes you dangerous (in a good way) for life. Learn the panel now, learn
one SSH command per week, and within a month you won't fear either.

---

## 8. Glossary of important words

| Word | Meaning |
|---|---|
| **VPS** | Your small rented computer running 24/7 |
| **SSH** | Encrypted terminal connection to the server |
| **Control panel** | Browser-based remote control for the server |
| **Nginx / Apache** | The web server that sends pages to visitors |
| **PHP / Node.js / Python** | Programming languages your sites are written in |
| **MySQL / MariaDB** | Databases where WordPress stores posts & users |
| **PostgreSQL** | A more advanced SQL database (Hestia/ISPConfig/Virtualmin) |
| **DNS** | The phone book connecting `example.com` to your IP |
| **SSL / HTTPS** | The padlock; free via Let's Encrypt |
| **Varnish / Redis / PageSpeed** | Caching layers that make sites feel instant |
| **Firewall** | Gatekeeper deciding which traffic may enter |
| **fail2ban** | Auto-bans IPs that keep guessing your password |
| **Domain** | The human-readable address of your site |
| **cPanel / Plesk** | Famous **paid** panels — intentionally not in this script |
| **Freemium** | Free core + paid extras (aaPanel Pro, CyberPanel Pro, CWP) |

---

## 9. First steps after buying a VPS

1. **Connect with SSH** (section 6)
2. **Update the system** — `apt update && apt upgrade -y` or `dnf update -y`
3. **Run this script** — `sudo bash vps-webhoster.sh`
4. **Install the recommended panel** from the menu
5. **Open the panel port** (8083/8443/8090/…) in your provider's
   firewall/security group — cloud firewalls block ports *before* your server
   even sees the traffic
6. **Change every default password immediately**
7. **Turn on** firewall + fail2ban + auto-updates (Security menu)
8. **Schedule backups** — a server without a backup is a server you don't own
9. **Add your first website** from inside the panel 🎉

---

> Made by **Hayder** · [VPS WebHoster on GitHub](../../README.md) ·
> MIT License · Found a mistake? PRs welcome in `docs/`!
