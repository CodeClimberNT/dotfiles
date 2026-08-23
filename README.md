# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Packages are grouped by purpose:

- `shell` → bash, zsh, fish, shared shell config
- `terminal` → kitty, alacritty, konsole-related config
- `dev` → developer tooling (`ruff`, `tombi`, `uv`, `zed`, etc.)
- `media` → `easyeffects`, `mpv`, `obs-studio`
- `gaming` → `heroic`, `MangoHud`
- `desktop` → desktop/session config
- `browser` → browser flags/config
- `local-bin` → scripts for `~/.local/bin`
- `ssh` → SSH config and public key only (no private key)

## Prerequisites

- Linux
- GNU Stow
- Git
- (Recommended) Gitleaks for secret scanning

Install on Arch/CachyOS:

```bash
sudo pacman -S stow git gitleaks
```

## First-time setup

From this repo root:

```bash
cd ~/dotfiles
stow -nv -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
```

If dry run looks correct:

```bash
stow -v -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
```

If conflicts exist (existing real files in `$HOME`), use one-time adopt:

```bash
cd ~/dotfiles
stow -nv --adopt -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
stow -v  --adopt -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
```

Then review adopted changes:

```bash
git status
git diff
```

## Daily usage

Restow after edits:

```bash
cd ~/dotfiles
stow -R -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
```

Unstow a package:

```bash
cd ~/dotfiles
stow -D -t "$HOME" shell
```

## Secrets policy

- Never commit private keys or tokens.
- Keep secrets in local untracked files (example: `~/.config/zed/secrets.env`).
- Keep only safe defaults/templates in repo.

Suggested `.gitignore` entries:

```gitignore
ssh/.ssh/id_ed25519
ssh/.ssh/*.pem
ssh/.ssh/known_hosts
dev/.config/zed/secrets.env
```

## Zsh note (post-chezmoi cleanup)

If still present, remove this line from zsh config:

```zsh
source <(chezmoi completion zsh)
```

---

## Verification checklist

### A) Symlink health

```bash
cd ~/dotfiles
find shell terminal dev media gaming desktop browser local-bin ssh -type f | head
```

```bash
ls -l ~/.bashrc ~/.zshenv ~/.config/zsh/.zshrc ~/.config/fish/config.fish
```

Expected: files in `$HOME` should be symlinks into `~/dotfiles/...`.

### B) Stow correctness

```bash
cd ~/dotfiles
stow -nv -R -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
```

Expected: no unexpected conflicts.

### C) Shell env correctness

```bash
echo "$ZDOTDIR"
zsh -lc 'echo $EDITOR'
zsh -ic 'echo $EDITOR'
```

Expected: `ZDOTDIR=$HOME/.config/zsh`; `EDITOR` available in both shell types.

### D) Secret scanning

Scan working tree:

```bash
cd ~/dotfiles
gitleaks dir . --redact --verbose
```

Scan staged changes:

```bash
cd ~/dotfiles
git add -A
gitleaks git --pre-commit --staged --redact --verbose
```

Expected: no leaks.

### E) Git hook path (repo-local)

```bash
git -C ~/dotfiles config --get core.hooksPath
```

Expected: `.githooks` (if configured).

### F) SSH safety

```bash
cd ~/dotfiles
git ls-files | grep -E 'id_ed25519|\.pem|known_hosts' || true
```

Expected: no private key material tracked.