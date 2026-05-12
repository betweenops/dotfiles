#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${REPO_ROOT}/Brewfile"
BACKUP_ROOT="${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

INSTALL_HOMEBREW=1
RUN_BUNDLE=1
INSTALL_EXTENSIONS=1

usage() {
    cat <<'EOF'
Usage: bootstrap.sh [options]

Sets up this macOS arm64 dotfiles repo in one pass:
1. Install Homebrew when missing
2. Install formulas, casks, and fonts from the Brewfile
3. Verify required arm64 Homebrew paths
4. Symlink dotfiles into place with backups
5. Install VSCodium extensions

Options:
  --skip-homebrew-install  Require brew to already exist
  --skip-bundle            Skip brew bundle
  --skip-extensions        Skip VSCodium extension installation
  --help                   Show this message
EOF
}

log() {
    printf '%s\n' "$1"
}

die() {
    printf 'err  %s\n' "$1" >&2
    exit 1
}

warn() {
    printf 'warn %s\n' "$1" >&2
}

brew_bin_path() {
    if command -v brew >/dev/null 2>&1; then
        command -v brew
        return 0
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        printf '/opt/homebrew/bin/brew\n'
        return 0
    fi

    return 1
}

homebrew_shellenv() {
    local brew_bin="$1"
    # Load the installed Homebrew location into this non-interactive shell.
    eval "$("$brew_bin" shellenv)"
}

require_macos_arm64() {
    [ "$(uname -s)" = "Darwin" ] || die "This bootstrap only supports macOS."
    [ "$(uname -m)" = "arm64" ] || die "This bootstrap expects Apple Silicon (arm64) and /opt/homebrew."
}

ensure_homebrew() {
    local brew_bin

    if brew_bin="$(brew_bin_path)"; then
        homebrew_shellenv "$brew_bin"
        log "ok   homebrew ${brew_bin}"
        return
    fi

    [ "$INSTALL_HOMEBREW" -eq 1 ] || die "Homebrew is not installed. Re-run without --skip-homebrew-install."
    command -v curl >/dev/null 2>&1 || die "curl is required to install Homebrew."

    log "install homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    brew_bin="$(brew_bin_path)" || die "Homebrew installation finished, but brew was not found."
    homebrew_shellenv "$brew_bin"
    log "ok   homebrew ${brew_bin}"
}

run_brew_bundle() {
    [ "$RUN_BUNDLE" -eq 1 ] || {
        log "skip brew bundle"
        return
    }

    command -v brew >/dev/null 2>&1 || die "brew is required before running brew bundle."
    log "brew bundle ${BREWFILE}"
    brew bundle --file "$BREWFILE"
}

verify_formula() {
    local name="$1"
    brew list --formula "$name" >/dev/null 2>&1 || die "Missing Homebrew formula: ${name}"
}

verify_cask() {
    local name="$1"
    brew list --cask "$name" >/dev/null 2>&1 || die "Missing Homebrew cask: ${name}"
}

verify_expected_installs() {
    local formula
    local cask

    for formula in \
        bash \
        bash-completion@2 \
        coreutils \
        gnu-sed \
        atuin \
        direnv \
        eza \
        fzf \
        ripgrep \
        starship \
        zoxide; do
        verify_formula "$formula"
    done

    for cask in \
        font-caskaydia-cove-nerd-font \
        vscodium \
        wezterm; do
        verify_cask "$cask"
    done

    [ -x /opt/homebrew/bin/bash ] || die "Expected /opt/homebrew/bin/bash after brew bundle."
    [ -x /opt/homebrew/bin/starship ] || die "Expected /opt/homebrew/bin/starship after brew bundle."

    log "ok   verified Homebrew packages, casks, and fonts"
}

backup_and_link() {
    local src="$1"
    local dest="$2"
    local dest_dir
    local backup_dest

    [ -e "$src" ] || die "Source file not found: ${src}"

    dest_dir="$(dirname "$dest")"
    backup_dest="${BACKUP_ROOT}/${dest#/}"
    mkdir -p "$dest_dir"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        log "ok   ${dest} already linked"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$(dirname "$backup_dest")"
        mv "$dest" "$backup_dest"
        log "mv   ${dest} -> ${backup_dest}"
    fi

    ln -s "$src" "$dest"
    log "link ${dest} -> ${src}"
}

find_codium_bin() {
    local candidate

    for candidate in \
        "${HOMEBREW_PREFIX:-}/bin/codium" \
        "/Applications/VSCodium.app/Contents/Resources/app/bin/codium" \
        "${HOME}/Applications/VSCodium.app/Contents/Resources/app/bin/codium"; do
        [ -n "$candidate" ] || continue
        [ -x "$candidate" ] || continue
        printf '%s\n' "$candidate"
        return 0
    done

    if command -v codium >/dev/null 2>&1; then
        command -v codium
        return 0
    fi

    return 1
}

install_vscodium_extensions() {
    local codium_bin
    local ext

    [ "$INSTALL_EXTENSIONS" -eq 1 ] || {
        log "skip codium extensions"
        return
    }

    if ! codium_bin="$(find_codium_bin)"; then
        warn "skip codium extensions: codium executable not found"
        return
    fi

    while read -r ext; do
        [ -n "$ext" ] || continue
        "$codium_bin" --install-extension "$ext" --force >/dev/null
        log "ext  ${ext}"
    done < "${REPO_ROOT}/vscodium/extensions.txt"
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --skip-homebrew-install)
                INSTALL_HOMEBREW=0
                ;;
            --skip-bundle)
                RUN_BUNDLE=0
                ;;
            --skip-extensions)
                INSTALL_EXTENSIONS=0
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                die "Unknown option: $1"
                ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"
    require_macos_arm64

    log "Using repo: ${REPO_ROOT}"
    log "Backup dir: ${BACKUP_ROOT}"

    ensure_homebrew
    HOMEBREW_PREFIX="$(brew --prefix)"
    export HOMEBREW_PREFIX

    run_brew_bundle
    if [ "$RUN_BUNDLE" -eq 1 ]; then
        verify_expected_installs
    fi

    backup_and_link "${REPO_ROOT}/.wezterm.lua" "${HOME}/.wezterm.lua"
    backup_and_link "${REPO_ROOT}/.bash_profile" "${HOME}/.bash_profile"
    backup_and_link "${REPO_ROOT}/.bashrc" "${HOME}/.bashrc"
    backup_and_link "${REPO_ROOT}/.config/starship.toml" "${HOME}/.config/starship.toml"
    backup_and_link \
        "${REPO_ROOT}/vscodium/User/settings.json" \
        "${HOME}/Library/Application Support/VSCodium/User/settings.json"

    install_vscodium_extensions

    log ""
    log "Done."
}

main "$@"
