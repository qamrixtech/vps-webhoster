# 🛡️ WAF Kya Hai? (Beginner Guide)

> **Zaban:** [English](../en/what-is-waf.md) | **اردو (Roman Urdu)**
>
> **VPS WebHoster** ka hissa - [README par wapsi](../../README.ur.md)

---

## 1. Seedha jawab

**WAF (Web Application Firewall)** aapki website ke saamne khara ek **hifazati
muhafiz** hai jo har **HTTP request** ko andar jaane se pehle check karta hai
aur wo hamle rok deta jo aam firewall dekh hi nahi sakta - kyunki wo hamle
*normal dikne wale web traffic ke andar* chhupe hote hain.

**Asal misaal:**

- **Aam firewall** parking lot ka guard hai: dekhta hai gaadi kis *darwaze*
  (port 80, 443, 22) par jana chahti hai aur poori gaadi ko andar ya bahar
  kar deta hai. Bag nahi kholta.
- **WAF** andar **lobby ka security officer** hai: har mehman ka bag check
  hota hai, shakki cheezein wapas, aur sirf saaf requests aapki website tak
  pohanchti hain.

---

## 2. Ise chahiye kyun?

Ab attackers server ke darwaze toor kar andar nahi aate. Wo **apni website ke
forms, URLs aur cookies ke zariye kharab input bhejte hain**:

| Hamla | Attacker kya bhejta hai | Uska maqsad |
|---|---|---|
| **SQL injection (SQLi)** | Login form mein `' OR '1'='1` | Bina password ke login, database chori |
| **XSS** | Comment mein `<script>stealCookies()</script>` | Doosre *visitors* ke browser mein code chalana |
| **Path traversal / LFI** | URL mein `../../etc/passwd` | Server ki files parhna |
| **File upload attack** | `image.jpg` bana kar PHP shell upload | Server par kabza |
| **Brute force** | Har second hazaron logins | Password ka andaza lagana |
| **Buri bots / scraping** | Khud-ba-khud crawlers | Content chori, server par bojh |
| **Zero-day scans** | Nayi aur purani kamzoriyon ki janch | Kuch bhi khula mile |

Network firewall ke liye ye sab bilkul normal port-80 traffic hai. WAF
**content** parhta hai aur kehta hai: "ye to naam nahi, ye SQL hamla hai -
blocked."

---

## 3. WAF aur baqi hifazati tabaqay

| Tabqa | Kya mehfooz karta hai | SQLi/XSS rokta hai? | Misaal |
|---|---|---|---|
| **Network firewall** | Kaunse ports/services khule hain | ❌ Nahi | `ufw`, `firewalld`, cloud security groups |
| **fail2ban** | Ghalat kaam karne wale IPs (login guesses, flood) | ❌ Nahi (bate *baar baar* shadish ke baad) | `sshd` jail wala `fail2ban` |
| **WAF** | HTTP request ke andar ka **kharab content** | ✅ **Haan** | ModSecurity + OWASP CRS, aaPanel WAF |
| **Antivirus (ClamAV)** | Disk par kharab **files** | ❌ Nahi | Upload ki hui files scan karna |
| **Software updates** | Aapke software ki jani hui kamzoriyan | ✅ Aakhir kar | WordPress/plugin updates |

Ye sab ek dusre ke upar chadhte hain - WordPress mein jab koi nayi kamzori
nikle to WAF aapko update karne ka waqt deta hai.

---

## 4. WAF ki qismein

### 1. Module WAF - aapke apne server par (is guide ka markaaz)

Nginx/Apache ke andar chalta hai aur traffic ki source hi par check karta hai.

- **ModSecurity + OWASP Core Rule Set (CRS)** - purana mashhoor tareeqa, CWP
  aur bohat se hosts istemal karte hain; free aur open source
- **aaPanel ka built-in WAF** - aaPanel ke saath free (paid upgrade bhi hai),
  UI se ek click mein on
- **Naxsi** (Nginx), **Coraza** (naya Go wala implementation)

**Fawada:** free, koi teesra shaks darmiyan nahi, data aapke server par rehta
hai. **Nuksaan:** rules khud tune karne padte hain (false positive hote hain).

### 2. Cloud WAF - traffic pehle unke network se guzarta hai

**Cloudflare (free tier), AWS WAF, Google Cloud Armor, Sucuri.**

DNS unki taraf point kar dete hain; wo filter karke saaf traffic aapke server
par bhejte hain.

**Fawada:** server par zero kharch, DDoS bhi absorb ho jata hai, setup aasaan,
aapka server IP chhup jata hai. **Nuksaan:** teesri party par depend (aur baad
mein pricing par), kuch rules paid, thoda latency barh sakta hai.

### 3. Plugin/app WAF - application ke andar

**Wordfence, Sucuri Scanner, WP Cerber** (WordPress ke liye).

**Fawada:** aapke app ko pata hota hai ke login page/admin URL kya hai.
**Nuksaan:** sirf usi app ko bachata hai, PHP start hone ke **baad** chalta
hai, site ka RAM khata hai.

> [!TIP]
> **Rule of thumb:** server-level WAF (ModSecurity/aaPanel) server ki **har**
> website ko ek saath bachata hai. Ahem WordPress sites par plugin WAF bhi
> lagayein, aur hamle ke shikar ho to aage Cloudflare laga dein.

---

## 5. Is script mein maujood panels par WAF kaise on karein

| Panel | WAF ka haal | Kaise on karein |
|---|---|---|
| **aaPanel** | ✅ Free WAF shamil | Panel -> *WAF* -> enable, rule level choose karein |
| **CWP** | ✅ ModSecurity dastiyab | Panel -> *Security* -> ModSecurity -> OWASP CRS install karein |
| **CyberPanel** | ⚠️ Install ke waqt ModSecurity/LiteSpeed option | Install karte waqt ModSecurity choose karein ya baad mein lagayein |
| **HestiaCP** | ⚠️ ModSecurity optional (nginx template) | Nginx mein ModSecurity add karein ya cloud WAF lein |
| **CloudPanel** | ❌ Built-in nahi | Khud ModSecurity lagayein ya Cloudflare |
| **Virtualmin** | ⚠️ Packages se mumkin | `mod_security`/OWASP CRS khud install karein |
| **ISPConfig** | ⚠️ Manual setup | Web server template mein ModSecurity configure karein |
| **FastPanel** | ⚠️ limited | Cloudflare ya plugin WAF behtar hai |

**Aur uske baad (script menu -> Security):**

```text
Firewall (ufw/firewalld)  ->  band ports par traffic rokta hai
fail2ban                  ->  brute-force IPs ban karta hai
WAF                       ->  kharab HTTP content filter karta hai
auto-updates              ->  jani hui kamzoriyan jaldi band karti hai
```

---

## 6. False-positive ka masla (bohat zaroori)

Sakht WAF **jaaiz** visitors ko bhi rok sakta hai:

- Contact form ka paighaam jisme `SELECT` lafz ho
- Ajeeb lekin jaiz user agent
- REST API / webhook JSON jo *hamla jaisa* dikhta hai

**Nishaniya:** users ko `403 Forbidden` aaye, login na ho, aapki khud ki API
toot jaye.

**Kya karein:**

1. Pehle **DetectionOnly / Learning mode** mein chalayein (ModSecurity ka
   flag: `SecRuleEngine DetectionOnly`)
2. Logs dekhte rahein:

   ```bash
   tail -f /var/log/modsec_audit.log     # ya aaPanel ka WAF log screen
   ```

3. Asli hamle ki surat mein site ko update/patch karein (WAF band karke
   nahi)
4. False positive ke liye us khaas URL/parameter par **rule exclusion** lagayein
5. Tabhi **Blocking mode** par jayein

> [!WARNING]
> Fresh OWASP CRS ko bina testing window ke live production site par
> blocking mode mein mat chalayein. Kuch dino ka tuning normal hai.

---

## 7. WAF kya NAHI karta

- ❌ WordPress/plugins ko mehfooz nahi bana deta - **phir bhi update karein**
- ❌ Backup ki jagah nahi leta
- ❌ HTTPS (SSL) ki jagah nahi leta - encryption aur inspection alag baat hain
- ❌ Sahi credentials wale SSH wale hamle nahi rok sakta
- ❌ 100% hacking-free guarantee nahi - ye sirf **ek tabqa** hai
- ❌ Aapke code ki kami dur nahi karta - sirf pohanchne wale input ko filter
  karta hai

---

## 8. Phata-phat faisla

```text
Bilkul nayi shuruat, ek chhoti site?
    → Panel ka free WAF on karein (aaPanel) ya ModSecurity (CWP)
    → Saath script ki Security menu se firewall + fail2ban

Clients ke liye WordPress chala rahe hain?
    → Server WAF + har site par Wordfence + Cloudflare DNS

Hamle ka dar ya high traffic?
    → Cloudflare (proxied) aage, peeche server WAF,
      fail2ban, aur sab kuch updated rakhein
```

---

## 9. Glossary

| Lafz | Matlab |
|---|---|
| **WAF** | Web Application Firewall - HTTP request ke **content** ko filter karta hai |
| **HTTP/HTTPS** | Websites jo bolte hain wo protocol (port 80/443) |
| **SQL injection** | Form ke input se database commands ghusana |
| **XSS** | Doosron ko dikhne wali pages mein script ghusana |
| **OWASP CRS** | ModSecurity ke liye free, standard rules ka set |
| **ModSecurity** | Sab se zyada istemal hone wala server-side WAF module |
| **403 Forbidden** | "Blocked" ka jawab - aksar WAF ka false positive |
| **False positive** | Rules ki wajah se ghalati se roka gaya jaiz visitor |
| **DDoS** | Traffic se server dubo dene ki koshish (cloud WAF absorb karta hai) |
| **Bot** | Khud-ba-khud site par aane wala script (ache aur bure dono) |

---

> Banaya: **Hayder** · [VPS WebHoster](../../README.ur.md) · MIT ·
> Baqi guides: [SSH kya hai?](./what-is-ssh.md) ·
> [Windows user ke liye Linux](./linux-for-windows-users.md) ·
> [Linux commands ki list](./linux-commands.md)
