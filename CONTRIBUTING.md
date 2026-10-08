# Contributing to VPS WebHoster 🛠️

Thanks for wanting to help! This project exists to make life easier for
beginners who just bought a VPS.

## Ground rules

1. **Free only.** The panel list contains free or freemium panels. Paid
   panels (cPanel, Plesk, DirectAdmin) are deliberately excluded.
2. **Beginner first.** Any text a human reads should stay simple and, when
   possible, available in English **and** Roman Urdu.
3. **Official sources only.** Install commands must come from the panel's
   official documentation — never from third-party blogs.
4. **No execution in CI.** This script changes servers. We only run static
   checks (`bash -n`, `shellcheck`) — never the script itself.

## How to contribute

1. Fork the repository and create a branch: `fix/short-description`
2. Make your change
3. Run the static checks:

   ```bash
   bash -n vps-webhoster.sh
   shellcheck vps-webhoster.sh
   ```

4. Open a Pull Request describing **what** changed and **why**

## Reporting a bug

Open an issue and include:

- Output of `bash vps-webhoster.sh --detect`
- Which panel / which menu option you used
- What you expected vs what happened
- The relevant lines from `/var/log/vps-webhoster.log`

## Updating a panel's install command

Panel installers change. If a command is outdated:

1. Find the current command on the **official** docs page
   (`P_DOCS` in `vps-webhoster.sh` lists every official docs URL)
2. Update `panel_install_cmd()` in `vps-webhoster.sh`
3. Update `docs/en/panels.md` and `docs/ur/panels.md`
4. Mention the official source URL in your PR

## Translations

Roman Urdu translations live in `docs/ur/` and `README.ur.md`.
Keep them side-by-side with the English versions — if you add a section in
English, add it in Roman Urdu too.

---

Made by **Hayder** — MIT licensed.
