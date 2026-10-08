# 🔐 What is SSH? (Beginner Guide)

> **Language:** **English** | [اردو (Roman Urdu)](../ur/what-is-ssh.md)
>
> Part of **VPS WebHoster** - [back to README](../../README.md)

---

## 1. The short answer

**SSH (Secure Shell)** is an encrypted connection that lets you open a
*terminal* on a computer that is somewhere else - your VPS in a datacenter -
and type commands on it as if you were sitting in front of it.

**Real-world analogy:** SSH is **your own key to the server's room**. You
unlock the door, walk in, and touch everything yourself. A control panel is
the hotel reception desk: you make requests, someone else does the work.

| | |
|---|---|
| Full name | **S**ecure **Sh**ell |
| What it is | Encrypted terminal connection over a network |
| Default port | **22** (TCP) |
| Replaces | Telnet, FTP, rlogin (all insecure/old) |
| Runs on | Every Linux/macOS terminal, Windows 10/11 built-in `ssh` |
| Used for | Installing things, editing files, managing a control panel's server |

---

## 2. Why "Secure"?

Old tools (Telnet, FTP) sent **everything in plain text** - your password
could be read by anyone sniffing the network. SSH encrypts the entire
session:

```text
Without SSH:  you -> "root / mypassword123" -> internet -> server   (readable!)
With SSH:     you -> "gT9#kL2$..." (encrypted) -> internet -> server -> decrypts
```

So nobody in between (your ISP, coffee-shop Wi-Fi, attackers) can read what
you typed or what the server sent back.

---

## 3. What SSH actually gives you

Once connected you get a **shell prompt**:

```bash
root@203.0.113.10:~#
```

From there you can do everything a keyboard allows:

```bash
ls                        # list files
cd /var/www               # move into a folder
nano index.html           # edit a file
systemctl restart nginx   # restart the web server
apt update && apt upgrade -y   # update the system
```

**Two bonus powers** beginners discover later:

1. **Copy files securely:** `scp report.pdf root@server:/root/`
   (secure replacement for FTP)
2. **Run commands from your own machine:** `ssh root@server "df -h"`
   (no interactive session needed)

---

## 4. How to connect, step by step

You need 3 things from your provider's email:

```text
IP address : 203.0.113.10
Username   : root
Password   : (printed when you created the server)
```

### Windows

**Option A (easiest): built-in OpenSSH**

1. Press `Win + R`, type `powershell`, press Enter
2. Type:

   ```powershell
   ssh root@203.0.113.10
   ```

3. First time it asks: `Are you sure you want to continue?` → type `yes`
4. Type your password (nothing appears while typing - that is normal)

**Option B: PuTTY**

1. Download from <https://www.putty.org/>
2. Host Name: `203.0.113.10`, Port: `22`, Connection type: SSH → **Open**
3. Accept the key, enter `root`, then the password

### macOS / Linux

Open the Terminal app and type:

```bash
ssh root@203.0.113.10
```

### Mobile

- iOS: **Termius** (free)
- Android: **Termius** or **JuiceSSH**

---

## 5. Password vs SSH key (do this early!)

| | Password | SSH key |
|---|---|---|
| What it is | A secret word you type | A file pair (public + private) |
| Brute-force risk | **High** - bots try millions of passwords/hour | Essentially zero |
| Convenience | Type it every time | Never type it again |
| Recommended for servers | ❌ No | ✅ Yes |

### Create and install a key (run on YOUR computer, not the server)

```bash
ssh-keygen -t ed25519            # creates ~/.ssh/id_ed25519 (private) + .pub (public)
ssh-copy-id root@203.0.113.10    # uploads the public key to the server
ssh root@203.0.113.10            # now logs in with NO password
```

Then lock the door to password guessing on the server:

```bash
nano /etc/ssh/sshd_config
# find these two lines and set them:
#   PasswordAuthentication no
#   PermitRootLogin prohibit-password
systemctl restart sshd
```

> [!CAUTION]
> Do this **after** your key works. If you disable passwords before the key
> works, you lock yourself out and will need your provider's VNC/rescue
> console to get back in.

---

## 6. Everyday SSH commands

| Command | What it does |
|---|---|
| `ssh root@IP` | Connect as user `root` |
| `ssh -p 2222 root@IP` | Connect on a custom port |
| `ssh -i ~/.ssh/id_ed25519 root@IP` | Use a specific key file |
| `scp file.txt root@IP:/root/` | Copy a file **to** the server |
| `scp root@IP:/var/log/app.log .` | Copy a file **from** the server |
| `sftp root@IP` | Interactive file transfer (like an FTP client) |
| `ssh root@IP "uptime"` | Run one command remotely, print output, disconnect |
| `exit` / `Ctrl+D` | Close the session |

---

## 7. Useful extras (once you're comfortable)

### Save time with SSH config

```bash
nano ~/.ssh/config
```

```text
Host myserver
    HostName 203.0.113.10
    User root
    Port 22
```

Now `ssh myserver` is all you have to type.

### Port forwarding (secure tunnel)

```bash
ssh -L 3307:localhost:3307 root@203.0.113.10
```

Your local app talks to `localhost:3307`, and SSH carries it safely to the
server's `3307`. Handy for reaching a database without exposing its port to
the internet.

### Fail2ban

The script's **Security** menu installs fail2ban, which watches SSH logs and
automatically bans IPs that keep guessing passwords. Highly recommended.

---

## 8. Troubleshooting

| Error | What it means | Fix |
|---|---|---|
| `Connection refused` | Nothing listening on port 22, or wrong port | Check your provider's firewall/security group; try `-p <port>` |
| `Connection timed out` | A firewall is dropping the traffic | Open port 22 in the **cloud** firewall/security group |
| `Permission denied (publickey,password)` | Wrong username/password or key | Double-check username (`root` vs `ubuntu`) and password |
| `Host key verification failed` | The server changed (or a man-in-the-middle) | Only if you rebuilt the server: `ssh-keygen -R 203.0.113.10` then reconnect |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` | Same as above - a red flag | Verify with your provider **before** removing the old key |
| PuTTY `No supported authentication methods` | Server rejects password auth | Add your public key in PuTTY's *SSH → Auth* page |
| Typing is invisible | Passwords don't echo | Keep typing and press Enter - it works |

---

## 9. Security checklist

1. ✅ Use **SSH keys**, disable password login
2. ✅ Keep `PermitRootLogin prohibit-password` (key-only root) or use a
   normal user + `sudo`
3. ✅ fail2ban + firewall (the script's Security menu does both)
4. ✅ Keep the system updated (`apt update && apt upgrade -y`)
5. ✅ Never share your **private** key (`~/.ssh/id_ed25519`), only the
   `.pub` one
6. ✅ Changing the SSH port reduces bot noise but is **not** real security
7. ✅ Log out of sessions you don't need (`exit`)

---

## 10. SSH vs control panel - when to use which

| Situation | Use |
|---|---|
| Install a panel, first-time server setup | **SSH** (that's what VPS WebHoster runs through) |
| Add a website, database, SSL | **Control panel** |
| Debug why a site is down | **SSH** (`journalctl`, `tail` logs) |
| Create email accounts | **Control panel** |
| One-off scripts, automation, deployments | **SSH** |
| Everyday hosting for non-technical users | **Control panel** |

They complement each other. Learn one SSH command per week and you'll never
fear your server again.

---

> Made by **Hayder** · [VPS WebHoster](../../README.md) · MIT ·
> Next: [What is a WAF?](./what-is-waf.md) ·
> [Linux for Windows users](./linux-for-windows-users.md) ·
> [Linux commands cheat sheet](./linux-commands.md)
