# 🧰 Helpful Linux Commands - Definitions and Uses

> **Language:** **English** | [اردو (Roman Urdu)](../ur/linux-commands.md)
>
> Part of **VPS WebHoster** - [back to README](../../README.md)

A practical cheat sheet for beginners: every command has a **plain-English
definition**, a **real example**, and a **when you'd use it**.

---

## 0. How to read a command

```text
   command   option(s)     argument(s)
     |          |               |
   sudo     apt install      nginx
     |
 (run as administrator)
```

- **`sudo`** = "do this as the boss (root)". Without it, most system changes
  are refused.
- Options are usually short (`-h`) or long (`--help`).
- Commands are **case-sensitive**: `Cd` will not work, `cd` will.
- **Tab completion is your best friend** - type `cd /etc/ssh` by typing
  `cd /etc/sh<TAB>`.

> [!CAUTION]
> The most dangerous command for a beginner is `sudo rm -rf /` style
> deletion. `rm` has **no recycle bin**. Always double-check paths before
> pressing Enter.

---

## 1. Navigation & files

| Command | Definition | Example | Use it when... |
|---|---|---|---|
| `pwd` | **P**rint **w**orking **d**irectory | `pwd` | You're lost and need to know where you are |
| `ls` | List directory contents | `ls -lah /var/www` | Checking what files exist |
| `cd` | Change directory | `cd /etc/nginx` | Moving around |
| `cd ..` | Go one folder **up** | `cd ..` | Backing out |
| `cd -` | Go back to previous folder | `cd -` | Toggling between two folders |
| `mkdir` | Make directory | `mkdir -p sites/mysite/logs` | Creating folder structure |
| `touch` | Create an empty file / update timestamp | `touch index.html` | Testing, placeholder files |
| `cp` | Copy | `cp index.html index.html.bak` | **Always back up before editing!** |
| `mv` | Move **or** rename | `mv old.html new.html` | Renaming/moving |
| `rm` | Remove (delete, no trash) | `rm file.txt` | Deleting files |
| `rm -r` | Remove a folder recursively | `rm -r tmp-cache` | Deleting directories |
| `ln -s` | Create a shortcut (symlink) | `ln -s /etc/nginx/nginx.conf ~/nc.conf` | Quick access to deep files |
| `tree` | Show folder structure as a tree | `tree -L 2 /var/www` | Understanding a project layout |

---

## 2. Reading and editing files

| Command | Definition | Example | Use it when... |
|---|---|---|---|
| `cat` | Print whole file | `cat /etc/os-release` | Short files |
| `less` | Page through a long file (scroll, `q` to quit) | `less /var/log/syslog` | Long files |
| `head` | First 10 lines | `head -n 20 app.log` | Start of a log |
| `tail` | Last 10 lines | `tail -f app.log` | **Live-following a log** while testing |
| `nano` | Simple terminal text editor | `nano /etc/hosts` | Beginners (Ctrl+O save, Ctrl+X exit) |
| `vim` | Powerful terminal editor | `vim index.php` | Once you've learned it |
| `wc` | Count lines/words/bytes | `wc -l access.log` | "How many lines in this log?" |
| `sort` / `uniq` | Sort / remove duplicates | `sort names.txt \| uniq` | Cleaning lists |
| `diff` | Show difference between files | `diff old.conf new.conf` | Checking what changed |

---

## 3. Searching

| Command | Definition | Example | Use it when... |
|---|---|---|---|
| `grep` | Search **text inside** files | `grep -i "error" app.log` | Finding errors in logs |
| `grep -r` | Search recursively in folders | `grep -rn "DB_PASS" /var/www` | Finding where a setting lives |
| `grep -c` | Count matches | `grep -c "404" access.log` | Counting hits |
| `find` | Find **files by name/date/size** | `find / -name "*.conf" -size +1M` | Locating files system-wide |
| `find -mtime` | Modified N days ago | `find /tmp -type f -mtime +7` | Old temp files (the cleaner uses this) |
| `which` | Path of a command | `which nginx` | "Where is this program installed?" |
| `locate` | Fast filename search (database) | `locate php.ini` | Quick lookup (run `updatedb` first) |

**`grep` vs `find`:** grep searches **inside** file contents; find searches
**for** files.

---

## 4. System information

| Command | Definition | Example | Use it when... |
|---|---|---|---|
| `uname -a` | Kernel/architecture info | `uname -m` | Checking `x86_64` vs `aarch64` |
| `cat /etc/os-release` | Distro name & version | `cat /etc/os-release` | Knowing your OS (the script does this) |
| `hostnamectl` | Hostname + OS + hypervisor | `hostnamectl` | Full identity of the machine |
| `df -h` | **D**isk **f**ree space, human-readable | `df -h` | "Is my disk full?" |
| `du -sh` | **D**isk **u**sage of a folder | `du -sh /var/log` | "What is eating my disk?" |
| `free -h` | RAM and swap | `free -h` | Is memory the problem? |
| `nproc` | Number of CPU cores | `nproc` | Sizing apps/panels |
| `uptime` | How long up + load average | `uptime` | Quick health glance |
| `top` / `htop` | Live process/resource viewer | `htop` | Watching CPU/RAM in real time |
| `date` | System date/time | `date` | Sanity checks, cron debugging |
| `last` | Logins history | `last -n 20` | Who accessed the server? |
| `id` / `whoami` | Current user & groups | `id` | "Am I root?" |

**Load average guide** (from `uptime`): `1.00` = one core fully busy.
On a 2-core box, `0.50` is calm and `4.00` means it's drowning.

---

## 5. Processes & services

| Command | Definition | Example | Use it when... |
|---|---|---|---|
| `ps aux` | List running processes | `ps aux \| grep nginx` | Finding a process |
| `top` | Interactive process list | `top` | Live view |
| `kill PID` | Stop a process | `kill 1423` | A stuck program (try gently first) |
| `kill -9 PID` | Force-kill | `kill -9 1423` | Last resort |
| `systemctl status X` | Service status | `systemctl status nginx` | "Is nginx running?" |
| `systemctl start/stop/restart X` | Control a service | `systemctl restart nginx` | Applying config changes |
| `systemctl enable X` | Start at boot | `systemctl enable --now fail2ban` | Making it survive reboots |
| `journalctl -u X -f` | Live logs of a service | `journalctl -u nginx -f` | Watching errors as they happen |
| `journalctl --since today` | Logs since a time | `journalctl --since "1 hour ago"` | Post-incident debugging |

> On older CentOS 7, replace `systemctl` with `service` and `chkconfig`.

---

## 6. Networking

| Command | Definition | Example | Use it when... |
|---|---|---|---|
| `ip a` | Show interfaces & IP addresses | `ip a` | "What's my IP?" (old: `ifconfig`) |
| `hostname -I` | Server's IPs only | `hostname -I` | Quick IP check |
| `ping` | Test if a host replies | `ping -c 4 google.com` | Is the internet/network alive? |
| `ss -lntp` | Listening ports + owning process | `ss -lntp` | "Is anything on port 8083?" |
| `curl` | Fetch a URL (API/debugging) | `curl -I https://example.com` | Check headers/status of a site |
| `wget` | Download a file | `wget https://site/file.zip` | Downloading to the server |
| `dig` / `nslookup` | DNS lookup | `dig example.com A` | Debugging domains |
| `traceroute` | Path packets take | `traceroute example.com` | Where is the connection dying? |
| `ufw status` | Firewall state (Debian/Ubuntu) | `sudo ufw allow 8083` | Opening/closing ports safely |
| `firewall-cmd --list-all` | Firewall state (Alma/Rocky) | `sudo firewall-cmd --add-port=8083/tcp --permanent` | Same, RHEL family |

`curl -I` vs `wget`: **curl** inspects/prints (great for APIs and debugging);
**wget** saves files.

---

## 7. Packages (software installation)

| Command | Definition | Example |
|---|---|---|
| `sudo apt update` | Refresh package list (Debian/Ubuntu) | Run before any install |
| `sudo apt install X` | Install package | `sudo apt install -y curl` |
| `sudo apt remove X` | Remove package (keeps config) | `sudo apt remove apache2` |
| `sudo apt purge X` | Remove package **and** config | `sudo apt purge apache2` |
| `sudo apt autoremove` | Remove now-unused dependencies | The script's Junk Cleaner uses this |
| `apt search X` | Search available packages | `apt search fail2ban` |
| `sudo dnf install X` | Install (AlmaLinux/Rocky/CentOS) | `sudo dnf install -y git` |
| `sudo dnf update` | Update system (RHEL family) | Equivalent of `apt upgrade` |
| `sudo dnf remove X` | Uninstall | `sudo dnf remove nginx` |
| `rpm -qa \| grep X` | Is package installed? (RHEL) | `rpm -qa \| grep nginx` |
| `dpkg -l \| grep X` | Is package installed? (Debian) | `dpkg -l \| grep nginx` |

---

## 8. Users & permissions

| Command | Definition | Example |
|---|---|---|
| `sudo adduser hayder` | Create a user (Debian/Ubuntu) | New admin account |
| `sudo usermod -aG sudo hayder` | Give sudo rights | `wheel` group on Alma/Rocky |
| `sudo passwd hayder` | Set/change a password | |
| `sudo deluser hayder` | Delete a user | |
| `chmod` | Change file permissions | `chmod 600 id_rsa` (keys must be private!) |
| `chmod +x script.sh` | Make a script executable | `./script.sh` then works |
| `chown` | Change owner | `sudo chown -R www-data:www-data /var/www/site` |
| `sudo -i` | Open a root shell | Stop typing `sudo` for every command |

**Reading `chmod 644`:** owner gets `6` (read+write), everyone else gets
`4` (read-only). `7` = read+write+execute, `5` = read+execute, `0` = nothing.

**The three numbers are: owner / group / others.**

---

## 9. Archives & transfers

| Command | Definition | Example |
|---|---|---|
| `tar -czf backup.tar.gz folder/` | **C**reate gzipped archive | Backups |
| `tar -xzf backup.tar.gz` | E**x**tract archive | Restoring |
| `tar -tzf` | **T**est/list without extracting | "What's inside?" |
| `zip -r out.zip folder/` | Make a zip | Windows-friendly sharing |
| `unzip out.zip` | Extract a zip | |
| `scp file root@IP:/root/` | Secure copy **to** server | Quick uploads |
| `scp root@IP:/var/log/x.log .` | Secure copy **from** server | Pulling logs |
| `rsync -avz folder/ root@IP:/backup/` | Smart sync (only differences) | Efficient, resumable backups |

`tar` mnemonic: **c**reate, e**x**tract, **t**est/list. Add **z** for gzip,
**v** for verbose, **f** for file.

---

## 10. Logs & monitoring

| Command | Definition | Use it when... |
|---|---|---|
| `tail -f /var/log/nginx/error.log` | Live-follow nginx errors | A site is broken **right now** |
| `journalctl -p err -b` | Errors since last boot | Server acting strange after reboot |
| `grep -i error app.log` | Hunt errors in a file | Post-incident review |
| `df -h && du -sh /*` | Disk usage drill-down | Disk full alerts |
| `free -h` | Memory check | Swapping/slowness |
| `htop` | Everything at once | General health |
| `dmesg \| tail` | Kernel messages | Hardware/driver trouble |
| `ss -lntp` | Open ports | Security check after installs |

---

## 11. The 20 commands you'll actually use daily

```text
 1. ls                 see files
 2. cd                 move around
 3. pwd                where am I
 4. cat                show a file
 5. nano               edit a file
 6. tail -f            live logs
 7. grep               search in text
 8. df -h              disk space
 9. free -h            memory
10. top / htop         live resources
11. systemctl status X service health
12. systemctl restart X apply changes
13. journalctl -u X -f service logs
14. apt update         refresh packages (Debian)
15. dnf update         refresh packages (RHEL)
16. ip a               my IP address
17. ss -lntp           listening ports
18. curl -I url        test a website
19. sudo               run as root
20. history            what did I type earlier?
```

---

## 12. Getting help (the most useful "commands")

| Command | What it gives you |
|---|---|
| `man ls` | The full manual for `ls` (press `q` to exit) |
| `ls --help` | Short usage + options |
| `apropos "disk space"` | Find a command when you only know the topic |
| `tldr tar` | Modern simplified examples (install `tldr` first) |
| `history \| grep apt` | "What was that apt command again?" |
| `Ctrl + R` | Reverse search through your history interactively |

**Golden habit:** before running an unfamiliar command with `sudo`, check
`command --help` first. Two seconds of reading prevents hours of repair.

---

> Made by **Hayder** · [VPS WebHoster](../../README.md) · MIT ·
> More: [What is SSH?](./what-is-ssh.md) · [What is a WAF?](./what-is-waf.md) ·
> [Linux for Windows users](./linux-for-windows-users.md)
