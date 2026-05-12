#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

backup_and_link() {
    local src="$1"
    local dest="$2"
    local dest_dir

    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        printf 'ok   %s already linked\n' "$dest"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_ROOT/$dest_dir"
        mv "$dest" "$BACKUP_ROOT/$dest"
        printf 'mv   %s -> %s\n' "$dest" "$BACKUP_ROOT/$dest"
    fi

    ln -s "$src" "$dest"
    printf 'link %s -> %s\n' "$dest" "$src"
}

printf 'Using repo: %s\n' "$REPO_ROOT"
printf 'Backup dir: %s\n' "$BACKUP_ROOT"

backup_and_link "$REPO_ROOT/.wezterm.lua" "$HOME/.wezterm.lua"
backup_and_link "$REPO_ROOT/.bash_profile" "$HOME/.bash_profile"
backup_and_link "$REPO_ROOT/.bashrc" "$HOME/.bashrc"
backup_and_link "$REPO_ROOT/.config/starship.toml" "$HOME/.config/starship.toml"
backup_and_link \
    "$REPO_ROOT/vscodium/User/settings.json" \
    "$HOME/Library/Application Support/VSCodium/User/settings.json"

if command -v codium >/dev/null 2>&1; then
    while read -r ext; do
        [ -n "$ext" ] || continue
        codium --install-extension "$ext" >/dev/null
        printf 'ext  %s\n' "$ext"
    done < "$REPO_ROOT/vscodium/extensions.txt"
else
    printf 'skip codium extensions: codium not found\n'
fi

printf '\nDone.\n'
printf 'If needed, install packages with: brew bundle --file "%s/Brewfile"\n' "$REPO_ROOT"
