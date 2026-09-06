# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- Linux
- GNU Stow
- Git
- (Recommended) Gitleaks for secret scanning

Install on Arch/CachyOS:

```bash
sudo pacman -S stow git gitleaks
```

## Quick start

```bash
git clone --recurse-submodules --config core.hooksPath=.githooks git@github.com:CodeClimberNT/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

> [!IMPORTANT]
> This repo requires two flags on clone:
>
> - **`--recurse-submodules`** — several packages embed external config repos as submodules (see [Packages](#packages)). Without this flag, those folders clone empty.
>   **Already cloned without it?** Run `git submodule update --init --recursive`.
> 
> - **`--config core.hooksPath=.githooks`** — points git at this repo's versioned hooks (e.g. the gitleaks pre-commit check). `.git/config` is never tracked, so this must be set on every fresh clone.
>   **Already cloned without it?** Run `git config core.hooksPath .githooks` inside the repo.

Preview what will be linked (no changes made):

```bash
stow -nv -t "$HOME" */
```

Apply:

```bash
stow -v -t "$HOME" */
```

If stow reports conflicts (real files already exist in `$HOME` where a symlink should go), resolve once with `--adopt`, which moves the existing file into the repo and replaces it with a symlink — **review the diff after**, since this pulls machine-local content into the repo:

```bash
stow -nv --adopt -t "$HOME" */
stow -v  --adopt -t "$HOME" */
git status
git diff
```

## Packages

| Package     | Contains                                                                                                   | Submodules        |
| ----------- | ---------------------------------------------------------------------------------------------------------- | ----------------- |
| `shell`     | bash, fish, **starship**, zsh, shared shell config                                                         | starship          |
| `terminal`  | kitty, alacritty, konsole                                                                                  | —­                |
| `dev`       | **emacs**, **nvim**, **ruff**, tombi, uv, VS Code (default profile: settings, keybindings, snippets), zed, | emacs, nvim, ruff |
| `media`     | easyeffects, mpv, obs-studio                                                                               | —                 |
| `gaming`    | heroic, MangoHud                                                                                           | —                 |
| `desktop`   | desktop/session config, **espanso**                                                                        | espanso           |
| `browser`   | browser flags/config                                                                                       | —                 |
| `local-bin` | scripts for `~/.local/bin`                                                                                 | —                 |
| `ssh`       | SSH config + public key only (no private key)                                                              | —                 |


## Daily usage

**Content edits** (editing values inside an existing file): edit either in `$HOME` or in `~/dotfiles` — they're the same file via symlink.

**Structure edits** (add/move/rename/delete a file or folder): always edit inside `~/dotfiles` first, then restow. Editing structure directly in `$HOME` can leave broken or unexpected symlinks.

Restow after any structure change:

```bash
cd ~/dotfiles
stow -R -t "$HOME" */
stow -nv -R -t "$HOME" */   # verify: expect no conflicts
git status
```

Unstow a single package:

```bash
stow -D -t "$HOME" <package>
```

### Moving files between packages

```bash
cd ~/dotfiles
stow -D -t "$HOME" old-package
git mv old-package/path/to/file new-package/path/to/file
stow -nv -R -t "$HOME" */
stow -R -t "$HOME" */
```

### Adding or moving a submodule

```bash
cd ~/dotfiles
git submodule add <url> <package>/path/to/submodule   # adding
# or
git mv old-package/submodule new-package/submodule     # moving

stow -nv -R -t "$HOME" */   # preview
stow -R -t "$HOME" */       # apply
```

Update the **Packages** table above whenever this changes what a package contains.

Check submodule state any time:

```bash
git submodule status --recursive
```

## Secrets policy

Never commit private keys or tokens. Enforced `.gitignore` entries:

```gitignore
ssh/.ssh/id_ed25519
ssh/.ssh/*.pem
ssh/.ssh/known_hosts
dev/.config/zed/secrets.env
```

Scan before every commit:

```bash
cd ~/dotfiles
git add -A
gitleaks git --pre-commit --staged --redact --verbose
```

---

## Troubleshooting / Verification

**Symlinks not pointing where expected**

```bash
ls -l ~/.bashrc ~/.zshenv ~/.config/zsh/.zshrc ~/.config/fish/config.fish
```
Expected: each resolves into `~/dotfiles/...`. If not, restow the owning package.

**Not sure if stow state matches the repo**

```bash
cd ~/dotfiles
stow -nv -R -t "$HOME" */
```
Expected: no unexpected conflicts. Anything listed here is out of sync.

**Shell env looks wrong**

```bash
echo "$ZDOTDIR"
zsh -lc 'echo $EDITOR'
zsh -ic 'echo $EDITOR'
```

**Dangling symlinks after removing something from a package**

Stow won't clean these up on its own if you delete a file from the repo without unstowing first:

```bash
find -L ~ -maxdepth 4 -xtype l 2>/dev/null
```
Any hit pointing back into `~/dotfiles` for a path you removed can be deleted manually.

**Submodule out of date or empty after a fresh clone/pull**

```bash
git submodule update --init --recursive
git submodule status --recursive
```

**Confirming no SSH private key material is tracked**

```bash
cd ~/dotfiles
git ls-files | grep -E 'id_ed25519$|\.pem$|known_hosts$' || true
```
Expected: no output.

**Final secret sweep**

```bash
cd ~/dotfiles
gitleaks dir . --redact --verbose
```