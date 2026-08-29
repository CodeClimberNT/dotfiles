# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

>[!IMPORTANT]
> Clone this repo with `git clone --recurse-submodules` to ensure submodules are also cloned. See [External configuration repositories](#external-configuration-repositories) for details.

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

From repo root:

```bash
cd ~/dotfiles
```

### Option A: explicit package list

Preview stow operations (no changes made):
```bash
stow -nv -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
```

Apply stow operations (symlinks created):
```bash
stow -v  -t "$HOME" shell terminal dev media gaming desktop browser local-bin ssh
```

### Option B: stow all packages automatically (alternative)

Preview with `-n` (no changes made):
```bash
stow -nv -t "$HOME" */
```

Apply with `-v` (symlinks created):
```bash
stow -v  -t "$HOME" */
```

If conflicts exist (existing real files in `$HOME`), use one-time adopt:

```bash
stow -nv --adopt -t "$HOME" */
stow -v  --adopt -t "$HOME" */
```

Then review:

```bash
git status
git diff
```
## External configuration repositories

External repositories are tracked as Git submodules under the specific package folder. This allows for separate version control and easier updates.:

For an existing clone:

```bash
git submodule update --init --recursive
```

To check the status of submodules:

```bash
git submodule status --recursive
```

Preview the changes first:

```bash
stow -nv -t "$HOME" <package>
```

Then apply:
```bash
stow -v -t "$HOME" <package>
```

This creates (or updates) symlinks in `$HOME` pointing to the submodule files.
If stowing packages dev and desktop, the following files will be symlinked:

```text
~/.config/nvim/
~/.config/ruff/ruff.toml
~/.config/espanso/
```

## Daily usage

Restow after structure changes (new/moved/renamed files):

```bash
cd ~/dotfiles
stow -R -t "$HOME" */
```

Unstow one package:

```bash
cd ~/dotfiles
stow -D -t "$HOME" <package>
```

## Editing rules (important)

- **Content edits** (inside existing files): edit either in `$HOME` or in `~/dotfiles` (symlinked).
- **Structure edits** (add/move/rename/delete files or folders): edit in **`~/dotfiles` first**, then restow.

Why: structure changes made directly in `$HOME` can break expected symlink layout.

### Safe workflow for structure changes

```bash
cd ~/dotfiles

# 1) move/create/delete inside package folders first
#    (example: mv dev/.config/ruff media/.config/ruff)

# 2) restow all packages
stow -R -t "$HOME" */

# 3) verify
stow -nv -R -t "$HOME" */
git status
```

### Moving files between packages (optional safer flow)

```bash
cd ~/dotfiles
stow -D -t "$HOME" old-package
stow -R -t "$HOME" old-package new-package
stow -nv -R -t "$HOME" */
```

### Moving Submodules (optional safer flow)

```bash
cd ~/dotfiles
# 1) move submodule folder to new package folder
git mv old-package/submodule new-package/submodule
# 2) verify what will be unstowed and restowed
stow -nv -R -t "$HOME" */
# 3) apply the changes
stow -R -t "$HOME" */
```

## Secrets policy

Never commit private keys or tokens.

Suggested `.gitignore` entries:

```gitignore
ssh/.ssh/id_ed25519
ssh/.ssh/*.pem
ssh/.ssh/known_hosts
dev/.config/zed/secrets.env
```

## Verification checklist

### A) Symlink health

```bash
ls -l ~/.bashrc ~/.zshenv ~/.config/zsh/.zshrc ~/.config/fish/config.fish
```

Expected: symlinks pointing into `~/dotfiles/...`.

### B) Stow consistency

```bash
cd ~/dotfiles
stow -nv -R -t "$HOME" */
```

Expected: no unexpected conflicts.

### C) Shell env correctness

```bash
echo "$ZDOTDIR"
zsh -lc 'echo $EDITOR'
zsh -ic 'echo $EDITOR'
```

### D) Secret scan

```bash
cd ~/dotfiles
gitleaks dir . --redact --verbose
git add -A
gitleaks git --pre-commit --staged --redact --verbose
```

### E) SSH safety

```bash
cd ~/dotfiles
git ls-files | grep -E 'id_ed25519|\.pem|known_hosts' || true
```

Expected: no private key material tracked.