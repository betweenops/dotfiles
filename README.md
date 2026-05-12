# Dotfiles

Personal macOS arm64 developer workstation setup focused on terminal productivity, reproducible environments, and portable tooling.

## Included files

- WezTerm
- Bash configuration
- Vim configuration
- Starship prompt
- Homebrew bundle support
- VSCodium settings/extensions
- Bootstrap automation with symlink management and backups

## Bootstrap on a new Mac

```bash
bash ~/dotfiles/bootstrap.sh
```

The bootstrap script is the supported entrypoint for a clean macOS arm64 setup. It:

- installs Homebrew if it is missing
- runs `brew bundle --file ~/dotfiles/Brewfile`
- installs and verifies `WezTerm`, `VSCodium`, and `CaskaydiaCove Nerd Font`
- installs supporting CLI tools including `vim`
- verifies the `/opt/homebrew` paths this repo expects
- backs up existing files into `~/.dotfiles-backups/<timestamp>/`
- symlinks the tracked dotfiles into place
- reinstalls the VSCodium extensions listed in `vscodium/extensions.txt`

### Options

```bash
bash ~/dotfiles/bootstrap.sh --help
```

Supported flags:

- `--skip-homebrew-install` to require an existing Homebrew installation
- `--skip-bundle` to skip package installation and only relink dotfiles
- `--skip-extensions` to skip VSCodium extensions

### Notes

- This repo currently targets Apple Silicon Macs and assumes Homebrew lives at `/opt/homebrew`.
- A completely fresh macOS machine may still prompt for Xcode Command Line Tools during Homebrew installation.
