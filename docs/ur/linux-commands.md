# 🧰 Kaam ki Linux Commands - Matlab aur Istemal

> **Zaban:** [English](../en/linux-commands.md) | **اردو (Roman Urdu)**
>
> **VPS WebHoster** ka hissa - [README par wapsi](../../README.ur.md)

Beginners ke liye kaam ki list: har command ke saath **sada Urdu mein
taarif**, **haqeeqi misaal**, aur **kab kaam aati hai**.

---

## 0. Command parhna kaise hai

```text
   command   option(s)     argument(s)
     |          |               |
   sudo     apt install      nginx
     |
 (boss ke tor par chalao)
```

- **`sudo`** = "ye kaam boss (root) ke tor par karo". Bagair iske zyada tar
  system changes mana ho jate hain.
- Options aksar chhoti hoti hain (`-h`) ya lambi (`--help`).
- Commands **case-sensitive** hain: `Cd` nahi chalega, `cd` chalega.
- **Tab completion sab se acha dost** hai - `cd /etc/ssh` likhne ke liye
  `cd /etc/sh<TAB>` dabayein.

> [!CAUTION]
> Naye logon ke liye sab se khatarnak cheez `sudo rm -rf /` wali style
> deletion hai. `recycle bin` wahan **hoti nahi**. Enter dabane se pehle path
> dobara parh lein.

---

## 1. Navigation aur files

| Command | Taarif | Misaal | Kab kaam aati hai |
|---|---|---|---|
| `pwd` | **P**rint **w**orking **d**irectory - aap kahan hain | `pwd` | Rasta bhool gaye hain |
| `ls` | Directory ki list | `ls -lah /var/www` | Kaunsi files maujood hain |
| `cd` | Folder badalna | `cd /etc/nginx` | Ghoomne ke liye |
| `cd ..` | Ek folder **upar** | `cd ..` | Peeche hatne ke liye |
| `cd -` | Pichhle folder par wapas | `cd -` | Do folders ke darmiyan toggle |
| `mkdir` | Folder banana | `mkdir -p sites/mysite/logs` | Structure banana |
| `touch` | Khaali file banana | `touch index.html` | Testing, placeholder |
| `cp` | Copy | `cp index.html index.html.bak` | **Edit se pehle hamesha backup!** |
| `mv` | Move **ya** rename | `mv old.html new.html` | Naam badalna/hilana |
| `rm` | Delete (trash nahi) | `rm file.txt` | Files hatana |
| `rm -r` | Folder delete | `rm -r tmp-cache` | Directories hatana |
| `ln -s` | Shortcut (symlink) | `ln -s /etc/nginx/nginx.conf ~/nc.conf` | Gehri file tak aasani |
| `tree` | Folder structure drakht ki soorat mein | `tree -L 2 /var/www` | Project ka dhancha samajhna |

---

## 2. Files parhna aur edit karna

| Command | Taarif | Misaal | Kab kaam aati hai |
|---|---|---|---|
| `cat` | Poori file chhapna | `cat /etc/os-release` | Chhoti files |
| `less` | Lambi file page-by-page (`q` se bahar) | `less /var/log/syslog` | Lambi files |
| `head` | Pehli 10 lines | `head -n 20 app.log` | Log ka aghaz |
| `tail` | Aakhri 10 lines | `tail -f app.log` | Testing ke waqt **log ko live** dekhna |
| `nano` | Aasaan terminal editor | `nano /etc/hosts` | Beginners (Ctrl+O save, Ctrl+X exit) |
| `vim` | Taqatwar terminal editor | `vim index.php` | Jab seekh chuke hon |
| `wc` | Lines/words/ginaish | `wc -l access.log` | "Is log mein kitni lines hain?" |
| `sort` / `uniq` | Tartib / duplicates hatana | `sort names.txt \| uniq` | List saaf karna |
| `diff` | Do files ka farq dikhana | `diff old.conf new.conf` | Kya badla ye dekhne ke liye |

---

## 3. Dhoondhna (search)

| Command | Taarif | Misaal | Kab kaam aati hai |
|---|---|---|---|
| `grep` | Files ke **andar text** dhoondhna | `grep -i "error" app.log` | Logs mein error dhoondhna |
| `grep -r` | Poori folder mein search | `grep -rn "DB_PASS" /var/www` | Pata lagana ke setting kahan hai |
| `grep -c` | Matches ginna | `grep -c "404" access.log` | Kitni baar aaya |
| `find` | **File** naam/date/size se dhoondhna | `find / -name "*.conf" -size +1M` | Poori system par file dhoondhna |
| `find -mtime` | N din pehle modify hui | `find /tmp -type f -mtime +7` | Purani temp files (cleaner yahi istemal karta hai) |
| `which` | Command ka path | `which nginx` | "Ye program kahan install hai?" |
| `locate` | Tez filename search (database) | `locate php.ini` | Jaldi dhoondhne ke liye (pehle `updatedb`) |

**`grep` vs `find`:** grep file ke **andar** ki text dhoondhta hai; find
**khud files** dhoondhta hai.

---

## 4. System ki maloomat

| Command | Taarif | Misaal | Kab kaam aati hai |
|---|---|---|---|
| `uname -a` | Kernel/architecture ki maloomat | `uname -m` | `x86_64` ya `aarch64` dekhna |
| `cat /etc/os-release` | Distro ka naam aur version | `cat /etc/os-release` | Aapka OS kya hai (script yahi karti hai) |
| `hostnamectl` | Hostname + OS + hypervisor | `hostnamectl` | Machine ki poori nishandahi |
| `df -h` | Disk ki jagah, asaan zaban mein | `df -h` | "Kya mera disk bhar gaya?" |
| `du -sh` | Folder kitna jagah leta hai | `du -sh /var/log` | "Disk kaun kha raha hai?" |
| `free -h` | RAM aur swap | `free -h` | Kya memory masla hai? |
| `nproc` | CPU cores ki tadaad | `nproc` | Apps/panels ki size ke liye |
| `uptime` | Kitna waqt up + load average | `uptime` | Fauri sehat jaanch |
| `top` / `htop` | Live process/resource viewer | `htop` | CPU/RAM waqt ke saath dekhna |
| `date` | System ki tareekh/waqt | `date` | Check, cron debug karne mein |
| `last` | Login ki history | `last -n 20` | Server par kaun aaya tha? |
| `id` / `whoami` | Aap kaun hain aur groups kya | `id` | "Kya main root hoon?" |

**Load average samjhein** (`uptime` se milta hai): `1.00` = ek core poori
tarah busy. 2-core machine par `0.50` sab theek hai aur `4.00` ka matlab hai
machine doob rahi hai.

---

## 5. Processes aur services

| Command | Taarif | Misaal | Kab kaam aati hai |
|---|---|---|---|
| `ps aux` | Chalne wale processes ki list | `ps aux \| grep nginx` | Process dhoondhna |
| `top` | Interactive process list | `top` | Live view |
| `kill PID` | Process band karna | `kill 1423` | Phansa hua program (pehle narmi se) |
| `kill -9 PID` | Zabardasti band | `kill -9 1423` | Aakhri hathon |
| `systemctl status X` | Service ki haalat | `systemctl status nginx` | "Kya nginx chal raha hai?" |
| `systemctl start/stop/restart X` | Service chalao/band/restart | `systemctl restart nginx` | Config badalne ke baad |
| `systemctl enable X` | Boot par khud chalna | `systemctl enable --now fail2ban` | Reboot ke baad bhi chalta rahe |
| `journalctl -u X -f` | Service ki live logs | `journalctl -u nginx -f` | Ghalatiyan aate waqt dekhna |
| `journalctl --since today` | Kisi waqt se logs | `journalctl --since "1 hour ago"` | Masla hone ke baad janch |

> Purane CentOS 7 mein `systemctl` ki jagah `service` aur `chkconfig`
> istemal karein.

---

## 6. Networking

| Command | Taarif | Misaal | Kab kaam aati hai |
|---|---|---|---|
| `ip a` | Interfaces aur IP addresses | `ip a` | "Meri IP kya hai?" (purana: `ifconfig`) |
| `hostname -I` | Sirf server ki IPs | `hostname -I` | Jaldi IP check |
| `ping` | Host jawab de raha ya nahi | `ping -c 4 google.com` | Internet/network zinda hai? |
| `ss -lntp` | Khule ports + kaun chala raha hai | `ss -lntp` | "Kya 8083 par kuch hai?" |
| `curl` | URL fetch (API/debugging) | `curl -I https://example.com` | Site ke headers/status check |
| `wget` | File download | `wget https://site/file.zip` | Server par download |
| `dig` / `nslookup` | DNS lookup | `dig example.com A` | Domain debug karna |
| `traceroute` | Packets ka rasta | `traceroute example.com` | Connection kahan mar raha hai? |
| `ufw status` | Firewall ki haalat (Debian/Ubuntu) | `sudo ufw allow 8083` | Port mehfooz tareeqe se kholna |
| `firewall-cmd --list-all` | Firewall ki haalat (Alma/Rocky) | `sudo firewall-cmd --add-port=8083/tcp --permanent` | Yehi, RHEL family |

`curl -I` vs `wget`: **curl** jaanch aur chhapne ke liye (API/debug mein
behtareen); **wget** files save karne ke liye.

---

## 7. Packages (software install)

| Command | Taarif | Misaal |
|---|---|---|
| `sudo apt update` | Package list refresh (Debian/Ubuntu) | Install se pehle hamesha |
| `sudo apt install X` | Install | `sudo apt install -y curl` |
| `sudo apt remove X` | Remove (config rehta hai) | `sudo apt remove apache2` |
| `sudo apt purge X` | Remove **aur** config bhi | `sudo apt purge apache2` |
| `sudo apt autoremove` | Faltu dependencies hatana | Script ki Junk Cleaner yahi karti hai |
| `apt search X` | Packages dhoondhna | `apt search fail2ban` |
| `sudo dnf install X` | Install (AlmaLinux/Rocky/CentOS) | `sudo dnf install -y git` |
| `sudo dnf update` | System update (RHEL family) | `apt upgrade` ka equivalent |
| `sudo dnf remove X` | Uninstall | `sudo dnf remove nginx` |
| `rpm -qa \| grep X` | Package laga hai ya nahi? (RHEL) | `rpm -qa \| grep nginx` |
| `dpkg -l \| grep X` | Package laga hai ya nahi? (Debian) | `dpkg -l \| grep nginx` |

---

## 8. Users aur permissions

| Command | Taarif | Misaal |
|---|---|---|
| `sudo adduser hayder` | User banana (Debian/Ubuntu) | Naya admin account |
| `sudo usermod -aG sudo hayder` | Sudo ki ijazat dena | Alma/Rocky par `wheel` group |
| `sudo passwd hayder` | Password set/badalna | |
| `sudo deluser hayder` | User hataana | |
| `chmod` | File permissions badalna | `chmod 600 id_rsa` (keys hamesha private!) |
| `chmod +x script.sh` | Script ko executable banao | Phir `./script.sh` chalega |
| `chown` | Malik badalna | `sudo chown -R www-data:www-data /var/www/site` |
| `sudo -i` | Root shell kholna | Har command par `sudo` likhna band |

**`chmod 644` kaise parhein:** malik ko `6` (read+write), baqi sab ko `4`
(sirf read). `7` = read+write+execute, `5` = read+execute, `0` = kuch nahi.

**Teen numbers hain: malik / group / baqi sab.**

---

## 9. Archives aur transfer

| Command | Taarif | Misaal |
|---|---|---|
| `tar -czf backup.tar.gz folder/` | **C**ompress archive banana | Backups |
| `tar -xzf backup.tar.gz` | Archive kholna | Wapas laana |
| `tar -tzf` | Khole bagair list/test | "Andar kya hai?" |
| `zip -r out.zip folder/` | Zip banana | Windows ko bhejne ke liye |
| `unzip out.zip` | Zip kholna | |
| `scp file root@IP:/root/` | Secure copy server **par** | Jaldi upload |
| `scp root@IP:/var/log/x.log .` | Secure copy server **se** | Logs lana |
| `rsync -avz folder/ root@IP:/backup/` | Smart sync (sirf farq wali cheezein) | Behtareen, resumable backups |

`tar` yaad rakhein: **c**ompress, e**x**tract, **t**est/list. Saath **z**
(gzip), **v** (verbose), **f** (file).

---

## 10. Logs aur monitoring

| Command | Taarif | Kab kaam aati hai |
|---|---|---|
| `tail -f /var/log/nginx/error.log` | Nginx errors live dekhna | Site **abhi** toot gayi hai |
| `journalctl -p err -b` | Reboot se ab tak errors | Reboot ke baad machine ajeeb hai |
| `grep -i error app.log` | File mein error dhoondhna | Baad mein janch |
| `df -h && du -sh /*` | Disk usage drill-down | Disk full ka alert |
| `free -h` | Memory check | Swap/slowness |
| `htop` | Ek jagah sab kuch | Aam sehat |
| `dmesg \| tail` | Kernel messages | Hardware/driver ka masla |
| `ss -lntp` | Khule ports | Install ke baad security check |

---

## 11. Woh 20 commands jo roz hathon aati hain

```text
 1. ls                 files dekhna
 2. cd                 ghoomna
 3. pwd                main kahan hoon
 4. cat                file dikhao
 5. nano               file edit karo
 6. tail -f            live logs
 7. grep               text mein dhoondho
 8. df -h              disk space
 9. free -h            memory
10. top / htop         live resources
11. systemctl status X service ki haalat
12. systemctl restart X changes apply karo
13. journalctl -u X -f service logs
14. apt update         packages refresh (Debian)
15. dnf update         packages refresh (RHEL)
16. ip a               meri IP address
17. ss -lntp           khule ports
18. curl -I url        website check karo
19. sudo               boss ke tor par chalao
20. history            maine pehle kya likha tha?
```

---

## 12. Madad dhoondhna (sab se kaam ki "commands")

| Command | Kya deta hai |
|---|---|
| `man ls` | `ls` ka poora manual (`q` dabakar bahar) |
| `ls --help` | Chhota usage + options |
| `apropos "disk space"` | Topic maloom ho sirf - command dhoondho |
| `tldr tar` | Aasaan misaalein (pehle `tldr` install karein) |
| `history \| grep apt` | "Wo apt wali command kya thi phir?" |
| `Ctrl + R` | History mein ulta search |

**Sone ka usool:** `sudo` ke saath anjaani command chalane se pehle `command
--help` zaroor parh lein. Do second parhne se ghanton ki murammat bachti hai.

---

> Banaya: **Hayder** · [VPS WebHoster](../../README.ur.md) · MIT ·
> Baqi: [SSH kya hai?](./what-is-ssh.md) · [WAF kya hai?](./what-is-waf.md) ·
> [Windows user ke liye Linux](./linux-for-windows-users.md)
