# Dotfiles

Personal macOS developer workstation setup focused on terminal productivity, reproducible environments, and portable tooling.

## Included files

- WezTerm
- Bash configuration
- Starship prompt
- Homebrew bundle support
- VSCodium settings/extensions
- Bootstrap automation with symlink management and backups

## Restore on a new Mac

Copy the files back to these locations:

- `.wezterm.lua` -> `~/.wezterm.lua`
- `.bash_profile` -> `~/.bash_profile`
- `.bashrc` -> `~/.bashrc`
- `.config/starship.toml` -> `~/.config/starship.toml`
- `vscodium/User/settings.json` -> `~/Library/Application Support/VSCodium/User/settings.json`

Or use the bootstrap script from the repo root:

```bash
bash ~/dotfiles/bootstrap.sh
```

The script backs up existing files into `~/.dotfiles-backups/<timestamp>/`, creates symlinks to the files in this repo, and reinstalls the VSCodium extensions listed in `vscodium/extensions.txt` when `codium` is available.

Install the supporting tools that these configs expect:

```bash
brew bundle --file ~/dotfiles/Brewfile
```

Then install the font these configs expect:

- `CaskaydiaCove Nerd Font`

Reinstall VSCodium extensions:

```bash
while read -r ext; do
  codium --install-extension "$ext"
done < ~/dotfiles/vscodium/extensions.txt
```

