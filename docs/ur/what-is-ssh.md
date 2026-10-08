# 🔐 SSH Kya Hai? (Beginner Guide)

> **Zaban:** [English](../en/what-is-ssh.md) | **اردو (Roman Urdu)**
>
> **VPS WebHoster** ka hissa - [README par wapsi](../../README.ur.md)

---

## 1. Seedha jawab

**SSH (Secure Shell)** aise server tak pohanchne ka **encrypted** tareeqa hai
jisse aap doosre computer (aapka VPS, datacenter mein rakhah hua) ka terminal
khol lete hain aur wahan commands type karte hain, bilkul jaise wo saamne
baitha ho.

**Asal misaal:** SSH **server ke kamre ki aapki apni chabi** hai. Darwaza
khol kar aap andar khud har cheez chhoo sakte hain. Control panel hotel ki
reception desk hai: aap request karte hain, kaam doosra karta hai.

| | |
|---|---|
| Poora naam | **S**ecure **Sh**ell |
| Kya hai | Network par encrypted terminal connection |
| Default port | **22** (TCP) |
| Kiska replacement | Telnet, FTP, rlogin (sab purane/ghair mehfooz) |
| Kahan chalta hai | Har Linux/macOS terminal, Windows 10/11 mein built-in `ssh` |
| Kis ke liye | Install karna, files edit karna, server ka saara kaam |

---

## 2. "Secure" ka matlab kya hai?

Purane tools (Telnet, FTP) sab kuch **khauli text** mein bhejte the - aapka
password jo bhi network sniff kare woh parh sakta tha. SSH poore session ko
encrypt karta hai:

```text
SSH ke bagair:  aap -> "root / mypassword123" -> internet -> server   (parhne layak!)
SSH ke saath:   aap -> "gT9#kL2$..." (encrypted) -> internet -> server -> decrypt
```

Is liye darmiyan ke koi bhi shaks (aapka ISP, cafe Wi-Fi, hackers) na aapka
likha hua parh sakte hain na server ka jawab.

---

## 3. SSH aapko kya deta hai

Connect hone ke baad aapko **shell prompt** milta hai:

```bash
root@203.0.113.10:~#
```

Yahan se keyboard jo chahe kar sakta hai:

```bash
ls                        # files ki list
cd /var/www               # folder mein jao
nano index.html           # file edit karo
systemctl restart nginx   # web server restart
apt update && apt upgrade -y   # system update
```

**Do aur taqatein** jo baad mein kaam aati hain:

1. **Files securely bhejna:** `scp report.pdf root@server:/root/`
   (FTP ka mehfooz replacement)
2. **Apne computer se command chalana:** `ssh root@server "df -h"`
   (session khulne ki zaroorat nahi)

---

## 4. Connect kaise karein (step by step)

Provider ke email se 3 cheezein chahiye:

```text
IP address : 203.0.113.10
Username   : root
Password   : (server banate waqt mila tha)
```

### Windows

**Tarika A (sab se aasaan): built-in OpenSSH**

1. `Win + R` dabayein, `powershell` likhen, Enter
2. Ye likhen:

   ```powershell
   ssh root@203.0.113.10
   ```

3. Pehli baar poochega: `Are you sure you want to continue?` -> `yes` likhen
4. Password daalein (type karte waqt kuch nahi dikhta - ye normal hai)

**Tarika B: PuTTY**

1. <https://www.putty.org/> se download karein
2. Host Name: `203.0.113.10`, Port: `22`, Connection type: SSH -> **Open**
3. Key accept karein, `root` likhein, phir password

### macOS / Linux

Terminal khol kar:

```bash
ssh root@203.0.113.10
```

### Mobile

- iOS: **Termius** (free)
- Android: **Termius** ya **JuiceSSH**

---

## 5. Password vs SSH key (ye jaldi kar lein)

| | Password | SSH key |
|---|---|---|
| Kya hai | Ek lafz jo aap type karte hain | Files ka jora (public + private) |
| Brute-force khatra | **Zyada** - bots ghante mein crore passwords aazmate hain | Takreeban zero |
| Aasani | Har baar type karna | Kabhi nahi type karna |
| Server ke liye | ❌ Nahi | ✅ Haan |

### Key banayein aur lagayein (ye APNE computer par chalayein, server par nahi)

```bash
ssh-keygen -t ed25519            # ~/.ssh/id_ed25519 (private) + .pub (public) banti hai
ssh-copy-id root@203.0.113.10    # public key server par chali jati hai
ssh root@203.0.113.10            # ab bina password ke login
```

Phir server par password-guessing ka darwaza band karein:

```bash
nano /etc/ssh/sshd_config
# ye do lines dhoondh kar aise set karein:
#   PasswordAuthentication no
#   PermitRootLogin prohibit-password
systemctl restart sshd
```

> [!CAUTION]
> Ye tabhi karein jab aapki key **kaam kar rahi ho**. Password band karne se
> pehle agar key theek nahi, to aap khud ko lock kar lenge aur wapas aane ke
> liye provider ka VNC/rescue console chahiye hoga.

---

## 6. Rozmarra ke SSH commands

| Command | Kya karta hai |
|---|---|
| `ssh root@IP` | `root` user se connect |
| `ssh -p 2222 root@IP` | Custom port par connect |
| `ssh -i ~/.ssh/id_ed25519 root@IP` | Khaas key file istemal |
| `scp file.txt root@IP:/root/` | File server par **bhejna** |
| `scp root@IP:/var/log/app.log .` | File server se **lena** |
| `sftp root@IP` | Interactive file transfer (FTP client jaisa) |
| `ssh root@IP "uptime"` | Door se ek command chala kar output chhapna |
| `exit` / `Ctrl+D` | Session band |

---

## 7. Kaam ki extra cheezein (thoda aage badhne par)

### SSH config mein time bachayein

```bash
nano ~/.ssh/config
```

```text
Host myserver
    HostName 203.0.113.10
    User root
    Port 22
```

Ab sirf `ssh myserver` likhna kaafi hai.

### Port forwarding (secure tunnel)

```bash
ssh -L 3307:localhost:3307 root@203.0.113.10
```

Aapka local app `localhost:3307` par baat karta hai, SSH use server tak
mehfooz le jata hai. Database ko internet par khole bagair use karne ke liye
badi kaam ki cheez.

### fail2ban

Script ki **Security** menu fail2ban lagati hai jo SSH logs par nazar rakhta
hai aur jo IP baar baar password guess kare usay khud ban kar deta hai.
Zaroor lagwayein.

---

## 8. Troubleshooting

| Error | Matlab | Hal |
|---|---|---|
| `Connection refused` | Port 22 par koi nahi, ya ghalat port | Provider ki firewall/security group check karein; `-p <port>` aazmayein |
| `Connection timed out` | Firewall traffic rok raha hai | **Cloud** firewall/security group mein port 22 kholein |
| `Permission denied (publickey,password)` | Password/key ghalat | Username (`root` vs `ubuntu`) aur password dobara check karein |
| `Host key verification failed` | Server badal gaya (ya man-in-the-middle) | Sirf jab aapne OS dobara install kiya ho: `ssh-keygen -R 203.0.113.10` |
| `REMOTE HOST IDENTIFICATION HAS CHANGED!` | Yehi upar wala - laal nishani | Purani key hatane se **pehle** provider se tasdeeq karein |
| PuTTY `No supported authentication methods` | Server password auth reject kar raha hai | PuTTY ke *SSH -> Auth* mein apni public key lagayein |
| Type karne par kuch nahi dikhta | Password show nahi hota | Bas type karein aur Enter dabayein - kaam karega |

---

## 9. Security checklist

1. ✅ **SSH keys** istemal karein, password login band karein
2. ✅ `PermitRootLogin prohibit-password` rakhein (sirf key wala root) ya
   normal user + `sudo` banayein
3. ✅ fail2ban + firewall (script ki Security menu dono karti hai)
4. ✅ System updated rakhein (`apt update && apt upgrade -y`)
5. ✅ Apni **private** key (`~/.ssh/id_ed25519`) kabhi share na karein, sirf
   `.pub` wali
6. ✅ SSH port badalne se bots kam milte hain lekin ye **asal** security nahi
7. ✅ Zaroorat na ho to session `exit` se band karein

---

## 10. SSH vs control panel - kab kaunsa

| Soorat-e-haal | Kya use karein |
|---|---|
| Panel install karna, pehli baar server setup | **SSH** (isi se VPS WebHoster chalta hai) |
| Website, database, SSL banana | **Control panel** |
| Site down hai - wajah dhoondhna | **SSH** (`journalctl`, logs `tail`) |
| Email accounts banana | **Control panel** |
| Scripts, automation, deployments | **SSH** |
| Non-technical logon ka rozmarra hosting kaam | **Control panel** |

Ye dushman nahi, teammates hain. Har hafta ek SSH command seekhein - phir na
panel se darr lagega na terminal se.

---

> Banaya: **Hayder** · [VPS WebHoster](../../README.ur.md) · MIT ·
> Aage: [WAF kya hai?](./what-is-waf.md) ·
> [Windows user ke liye Linux](./linux-for-windows-users.md) ·
> [Linux commands ki list](./linux-commands.md)
