# 🛡️ What is a WAF? (Beginner Guide)

> **Language:** **English** | [اردو (Roman Urdu)](../ur/what-is-waf.md)
>
> Part of **VPS WebHoster** - [back to README](../../README.md)

---

## 1. The short answer

A **WAF (Web Application Firewall)** is a guard that sits in front of your
website and **inspects every HTTP request** before it reaches your site. It
blocks attacks that a normal firewall cannot see, because they arrive *inside
legitimate-looking web traffic*.

**Real-world analogy:**

- A **normal firewall** is the guard at the parking lot: it checks *which
  door* traffic wants to use (port 80, 443, 22) and lets whole cars in or
  out. It doesn't open the bags.
- A **WAF** is the security officer *inside the lobby*: every visitor gets
  their bag checked, suspicious items are refused, and only clean requests
  walk through to your website.

---

## 2. Why you need one

Attackers don't "hack" your server by brute-forcing doors anymore. They send
**crafted input through your website's forms, URLs and cookies**:

| Attack | What the attacker sends | What they want |
|---|---|---|
| **SQL injection (SQLi)** | `' OR '1'='1` in a login form | Log in without a password, dump your database |
| **XSS** | `<script>stealCookies()</script>` in a comment | Run code in *other visitors'* browsers |
| **Path traversal / LFI** | `../../etc/passwd` in a URL | Read server files |
| **Remote file upload** | A PHP shell uploaded as `image.jpg` | Take over the server |
| **Brute force** | Thousands of logins/second | Guess your password |
| **Bad bots / scrapers** | Automated crawlers | Steal content, overload you |
| **Zero-day scans** | Probes for known and unknown flaws | Find anything open |

A network firewall sees all of this as *perfectly normal port-80 traffic*.
A WAF reads the **content** and says: "that's not a name, that's an SQL
attack - blocked."

---

## 3. WAF vs the other security layers

| Layer | Guards | Blocks SQLi/XSS? | Example |
|---|---|---|---|
| **Network firewall** | Which ports/services are reachable | ❌ No | `ufw`, `firewalld`, cloud security groups |
| **fail2ban** | IPs misbehaving (bad logins, flooding) | ❌ No (it reacts *after* repeated abuse) | `fail2ban` with `sshd` jail |
| **WAF** | Malicious *content* inside HTTP requests | ✅ **Yes** | ModSecurity + OWASP CRS, aaPanel WAF |
| **Antivirus (ClamAV)** | Malicious *files* on disk | ❌ No | Scans uploaded files |
| **App updates** | Known bugs in your software | ✅ Eventually | WordPress/plugin updates |

They stack - a WAF buys you time while you update WordPress 4.7 after a
vulnerability is announced.

---

## 4. Types of WAF

### 1. Module WAF - installed on your own server (what this guide cares about)

Runs inside Nginx/Apache and inspects traffic at the source.

- **ModSecurity + OWASP Core Rule Set (CRS)** - the classic, used by CWP and
  many hosts; free and open source
- **aaPanel's built-in WAF** - free with aaPanel (commercial WAF upgrades
  exist), one-click enable in its UI
- **Naxsi** (Nginx), **Coraza** (modern Go implementation)

**Pros:** free, no third party in the request path, data stays on your
server. **Cons:** you tune the rules yourself (false positives happen).

### 2. Cloud WAF - traffic is routed through their network first

**Cloudflare (free tier), AWS WAF, Google Cloud Armor, Sucuri.**

You point DNS at them; they filter and then forward clean traffic to your
server.

**Pros:** zero server resources, blocks DDoS at scale, easy setup, hides
your server IP. **Cons:** you depend on a third party (and on their pricing
later), some rules are commercial, and latency may increase slightly.

### 3. Plugin/app WAF - inside the application

**Wordfence, Sucuri Scanner, WP Cerber** for WordPress.

**Pros:** understands your app's logic (login pages, admin URLs).
**Cons:** only protects that app, runs *after* PHP starts, uses site RAM.

> [!TIP]
> **Rule of thumb:** a server-level WAF (ModSecurity/aaPanel) protects
> *every* site on the server at once. Add a plugin WAF on important
> WordPress sites too, and put Cloudflare in front if you're under attack.

---

## 5. How to enable a WAF with the panels in this script

| Panel | WAF situation | How to switch it on |
|---|---|---|
| **aaPanel** | ✅ Free WAF included | Panel → *WAF* → enable, choose rule level |
| **CWP** | ✅ ModSecurity available | Panel → *Security* → ModSecurity → install OWASP CRS |
| **CyberPanel** | ⚠️ ModSecurity/LiteSpeed options during install | Choose ModSecurity when installing, or add later |
| **HestiaCP** | ⚠️ ModSecurity optional (nginx template) | Add ModSecurity to Nginx, or use a cloud WAF |
| **CloudPanel** | ❌ Not built in | Use ModSecurity yourself or Cloudflare |
| **Virtualmin** | ⚠️ Possible via packages | Install `mod_security`/OWASP CRS manually |
| **ISPConfig** | ⚠️ Manual setup | Configure ModSecurity in the web server template |
| **FastPanel** | ⚠️ Limited | Prefer Cloudflare or a plugin WAF |

**Then, on top of that (script menu → Security):**

```text
Firewall (ufw/firewalld)  →  blocks closed ports
fail2ban                  →  bans brute-force IPs
WAF                       →  filters malicious HTTP content
auto-updates              →  closes known holes fast
```

---

## 6. The false-positive problem (important!)

A strict WAF can block **legitimate** visitors:

- A contact form containing the word `SELECT` in a message
- A weird (but valid) user agent
- REST API / webhook JSON that *looks* like an attack

**Symptoms:** users get `403 Forbidden`, logins fail, your own API breaks.

**How to handle it:**

1. Start in **DetectionOnly / Learning mode** (ModSecurity flag:
   `SecRuleEngine DetectionOnly`)
2. Watch the logs:

   ```bash
   tail -f /var/log/modsec_audit.log     # or aaPanel's WAF log screen
   ```

3. Fix real hits by patching your site (never by turning the WAF off)
4. For false positives, add a **rule exclusion** for that specific URL/parameter
5. Only then switch to **Blocking mode**

> [!WARNING]
> Never run a fresh OWASP CRS install straight to blocking mode on a live
> production site without a testing window. It is normal to need a few days
> of tuning.

---

## 7. What a WAF does NOT do

- ❌ It does not make WordPress/plugins safe - **update them anyway**
- ❌ It does not replace backups
- ❌ It does not replace HTTPS (SSL) - encryption and inspection are
  different things
- ❌ It does not stop attacks that come through SSH with valid credentials
- ❌ It does not guarantee you can't get hacked - it's **one layer**
- ❌ It can't fix your code - it only filters what reaches it

---

## 8. Quick decision guide

```text
Just starting out, one small site?
    → Enable the panel's free WAF (aaPanel) or ModSecurity (CWP)
    → Plus firewall + fail2ban from the script's Security menu

Running WordPress for clients?
    → Server WAF + Wordfence on each site + Cloudflare DNS

Expecting attacks / high traffic?
    → Cloudflare (proxied) in front, server WAF behind it,
      fail2ban, and keep everything updated
```

---

## 9. Glossary

| Term | Meaning |
|---|---|
| **WAF** | Web Application Firewall - filters HTTP request *content* |
| **HTTP/HTTPS** | The protocol websites speak (port 80/443) |
| **SQL injection** | Injecting database commands through form input |
| **XSS** | Injecting scripts into pages other people view |
| **OWASP CRS** | Free, standard rule set for ModSecurity |
| **ModSecurity** | The most common server-side WAF module |
| **403 Forbidden** | "Blocked" response - often a WAF false positive |
| **False positive** | A normal visitor wrongly blocked by rules |
| **DDoS** | Overwhelming your server with traffic (cloud WAFs absorb it) |
| **Bot** | Automated script visiting your site (good and bad kinds) |

---

> Made by **Hayder** · [VPS WebHoster](../../README.md) · MIT ·
> More beginner guides: [What is SSH?](./what-is-ssh.md) ·
> [Linux for Windows users](./linux-for-windows-users.md) ·
> [Linux commands cheat sheet](./linux-commands.md)
