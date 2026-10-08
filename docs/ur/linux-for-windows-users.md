# 🐧 Linux Distributions Kya Hain? (Windows Users ke liye Guide)

> **Zaban:** [English](../en/linux-for-windows-users.md) | **اردو (Roman Urdu)**
>
> **VPS WebHoster** ka hissa - [README par wapsi](../../README.ur.md)

Agar aapne hamesha sirf Windows hi use kiya hai, to ye page poore Linux jahan
ko Windows ki zaban mein samjha deta hai.

---

## 1. Linux kya hai?

**Linux** ek **kernel** hai (jo hardware se baat karne wala asal dil) - free
aur open source. Akele ye kuch dikhata nahi - na desktop, na apps.

Use bechne ya chalane ke liye koi na koi **kernel ko tools, package manager,
installers aur support ke saath pack kar ke bechta hai**. Is poore package ko
**distribution** (mukhtasir mein "distro") kehte hain.

**Misaal:** Linux ek **engine** jaisa hai. Distro us engine ke ird-gird bani
**poori gaadi** hai - dashboard, seats aur rang ke saath.

---

## 2. Windows versions vs Linux distros

| Windows wala side | Linux wala side |
|---|---|
| Windows 10, Windows 11, Windows Server | Ubuntu, Debian, AlmaLinux, Fedora, Mint... |
| Ek company banati hai (Microsoft) | Sauon communities/companies apna banati hain |
| License khareedna parta hai | Aksar **free** (paisa bhi nahi aur open source bhi) |
| Updates Microsoft Update se | Har distro ke apne repositories + `apt`/`dnf` |
| .exe / .msi installers | `.deb` / `.rpm` packages, ya `apt`/`dnf` commands |
| Zyaada tar ek jaisa chehra | Desktop alag: GNOME, KDE, XFCE... |
| Laptops par milta hai | Laptops par kam, **servers aur phones par raj** |

> **Mazedaar baat:** Android Linux hai. Zyada tar routers, smart TVs, aur
> duniya ke ~96% baray servers bhi Linux par chalte hain.

---

## 3. Itne saare distros kyun?

Kyunki jo chahe wo Linux kernel le kar apni zaroorat ke liye tune kar sakta
hai:

```text
                        Linux kernel
                              |
   +--------------------------+---------------------------+
   |                          |                           |
 Debian                   Red Hat family              Baqi
 (stability)              (enterprise)          Arch (DIY), openSUSE,
   |                          |                 Fedora (nayi technology)...
 Ubuntu (beginners ke liye)  AlmaLinux / Rocky
   |                         (RHEL ke free rebuild -
 Mint, Pop!_OS,              hum servers ke liye
 Kali (security)             yahi istemal karte hain)
```

**Servers ke liye do families ahem hain:**

- **Debian family** - `apt` istemal karti hai, packages `.deb`
  → **Ubuntu, Debian**
- **RHEL family** (Red Hat) - `dnf`/`yum` istemal karti hai, packages `.rpm`
  → **AlmaLinux, Rocky Linux, CentOS Stream, Fedora**

Hamare liye baqi sab in do ka hi koi na koi variation hai.

---

## 4. Naye log kaunsa distro chunein?

### Desktop/laptop ke liye (Windows ki jagah)

| Distro | Kis ke liye behtar |
|---|---|
| **Linux Mint** | Sab se "Windows jaisa" ehsaas, halkee shuruat |
| **Ubuntu** | Sab se zyada guides/support, har jagah chalta hai |
| **Pop!_OS** | Gamers/creators, NVIDIA support zabardast |
| **Fedora** | Nayi technology sab se pehle |

### VPS/server ke liye (is project ka markaaz)

| Distro | Tab chunein jab... | Package tool |
|---|---|---|
| **Ubuntu 24.04** | Aap naye hain; guides seedhe kaam karein | `apt` |
| **Debian 12/13** | Chattan jaisi stability, kam updates chahiye | `apt` |
| **AlmaLinux 9/10** | RHEL-compatible, cPanel jaisa enterprise feel | `dnf` |
| **Rocky Linux 9/10** | Alma jaisa (community ka alternative) | `dnf` |
| **CentOS Stream** | RHEL ke bilkul qareeb chahiye | `dnf` |

> [!TIP]
> **Shuru Ubuntu ya Debian se karein.** Har panel, plugin aur tool ki docs
> inhein maan kar likhi hoti hai. `VPS WebHoster` Ubuntu, Debian, AlmaLinux,
> Rocky aur CentOS ko support karta hai aur khud pehchan leta hai ke aap
> kis family par hain.

---

## 5. Rozmarra mein Windows se farq

### Drives aur paths

```text
Windows                          Linux
C:\                  →           /              (sab ka aghaz)
C:\Users\Hayder      →           /home/hayder
C:\Program Files     →           /usr/bin, /opt, /var...
D:\ (doosri disk)    →           /mnt/data      (khud mount karni parti hai)
Backslash \          →           Forward slash /
```

**Koi drive letters nahi.** Sab kuch `/` se shuru hone wali ek hi drakht se
latka hai.

### Users aur permissions

- Windows mein aap "Run as administrator" click karte hain.
- Linux mein command ke saamne **`sudo`** lagate hain:

  ```bash
  apt update          # normal user: mana kar diya jayega
  sudo apt update     # ijazat mili: root ke tor par chala
  ```

- Boss user ka naam **`root`** hai (wo "Administrator" wala shared account
  nahi jo sab istemal karte hain).

### Software install karna

| Windows | Linux |
|---|---|
| Website se .exe download | `sudo apt install nginx` (bharosemand repos se) |
| Microsoft Store | `snap` / `flatpak` (chaho to app store) |
| "Add or remove programs" | `sudo apt remove nginx` |
| Manual uninstall | `sudo apt purge nginx` |

**Kisi bhi blog se random `.sh` script download kar ke install mat karein.**
Distro ke repositories ya us software ka official installer use karein (yahi
kaam VPS WebHoster control panels ke liye karti hai).

### Khud desktop

- **Windows:** ek hi desktop environment, Microsoft ki
- **Linux:** desktop badalne wala hota hai -
  - **GNOME** (Ubuntu default) - saaf-suthra, macOS jaisa
  - **KDE Plasma** - Windows jaisa, khoob customize hota hai
  - **XFCE** - halka, purane computers ke liye

Is liye Linux ki screenshots sab alag dikhti hain.

### Terminal

Windows mein PowerShell/cmd hai. Linux mein terminal **pehla darja** hai -
zyada tar admin ka kaam (khaas kar servers) wahi hota hai. Dar na - is
project ke menu ka aadha hissa isi liye hai ke aap **bina** uske bhi kaam kar
sakein.

---

## 6. Commands ka tarjuma

| Kaam | Windows | Linux |
|---|---|---|
| Files ki list | `dir` | `ls` |
| Folder badalna | `cd` | `cd` |
| Copy/move | `copy` / `move` | `cp` / `mv` |
| Delete | `del` | `rm` |
| Text dhoondhna | Notepad++ search | `grep` |
| Chalne wale apps dekhna | Task Manager | `top`, `htop`, `ps` |
| App band karna | End task | `kill PID` |
| Network config | `ipconfig` | `ip a` |
| Connection test | `ping` | `ping` |
| IP dhoondhna | `ipconfig` | `ip a` ya `hostname -I` |
| Disk space | Explorer -> This PC | `df -h` |
| Services dekhna | Services.msc | `systemctl status nginx` |
| Logs | Event Viewer | `journalctl -u nginx` |
| Package install | .exe download | `sudo apt install pkg` |

Poori tafseel: **[Linux commands ki list](./linux-commands.md)**

---

## 7. Bina Windows chhode Linux aazmaya ja sakta hai?

Bilkul:

1. **WSL** (Windows ke andar Linux) - Windows mein hi Ubuntu lagayein:

   ```powershell
   wsl --install
   ```

   Commands seekhne ka sab se mehfooz tareeqa.

2. **Live USB** - USB se Ubuntu boot karein; aapka Windows jaisa ka taisa
   rehta hai.

3. **VirtualBox/VMware** - window ke andar poora Linux desktop chalayein.

4. **Sasta VPS** - asal cheez, aur yahi is project ka maqsad hai
   (aksar $3-6 mahana, students ke liye free tiers bhi).

---

## 8. Linux Windows se mushkil hai?

| Ke liye... | Faisla |
|---|---|
| Browser, email, documents | Nahi - Mint/Ubuntu bilkul Windows jitne aasaan |
| Gaming | 5 saal pehle se bohat behtar, kuch titles mein abhi bhi Windows aage |
| Seekhna | Bunyadi baaton ke liye ek weekend; mahine bhar mein confidence |
| Servers | Zyada tar hosting ke liye Windows Server se **aasaan aur mehfooz** |
| Kharcha | Free (Windows license ke paise lagte hain) |
| Virus | Bohat kam (lekin zero nahi - update aur firewall phir bhi zaroori) |

**Servers ke liye sawaal hi paida nahi hota:** taqreeban har hosting control
panel (cPanel, Plesk, HestiaCP, CloudPanel...) sirf Linux par chalta hai.
Windows Server hosting hai lekin mehanga aur niche kaam hai.

---

## 9. Glossary: Windows ka lafz -> Linux ka lafz

| Windows | Linux |
|---|---|
| Drive `C:` | Root filesystem `/` |
| Explorer | Files (Nautilus/Dolphin) ya `ls` |
| Control Panel / Settings | Settings app ya terminal tools |
| PowerShell / CMD | Shell (`bash`, `zsh`) |
| Administrator | `root` / `sudo` |
| Task Manager | `htop` / `gnome-system-monitor` |
| Services.msc | `systemctl` |
| Event Viewer | `journalctl` / `/var/log/*` |
| .exe / .msi | `.deb` / `.rpm` / AppImage / Flatpak |
| Windows Update | `apt update && apt upgrade` / `dnf update` |
| Registry | `/etc` mein config files (plain text!) |
| Windows Defender | ClamAV (free) + aqal-mandi + WAF |
| Firewall (Windows Security) | `ufw` / `firewalld` |
| Drive letters A:, B:, C: | Mount points `/`, `/home`, `/mnt/...` |

---

## 10. Linux VPS par pehle 30 minute

```bash
# 1. main kis cheez par hoon?
cat /etc/os-release

# 2. sab kuch update
sudo apt update && sudo apt upgrade -y     # Debian/Ubuntu
# sudo dnf update -y                       # AlmaLinux/Rocky/CentOS

# 3. resources dekho
df -h && free -h && nproc

# 4. is project ka helper chalao
sudo bash vps-webhoster.sh
```

Script ki **System Detection** screen 1 aur 3 number ka kaam khud kar deti
hai aur aapke distro aur hardware ke haqeeqi tor par control panel recommend
karti hai.

---

> Banaya: **Hayder** · [VPS WebHoster](../../README.ur.md) · MIT ·
> Baqi: [SSH kya hai?](./what-is-ssh.md) · [WAF kya hai?](./what-is-waf.md) ·
> [Linux commands ki list](./linux-commands.md)
