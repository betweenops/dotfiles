_path_remove() {
    local dir
    local path=":$PATH:"
    for dir in "$@"; do
        path="${path//:$dir:/:}"
    done
    PATH="${path#:}"
    PATH="${PATH%:}"
}

_path_prepend() {
    local dir
    _path_remove "$@"
    for ((i = $#; i >= 1; i--)); do
        dir="${!i}"
        [ -d "$dir" ] || continue
        PATH="$dir${PATH:+:$PATH}"
   done
}

_path_append() {
    local dir
    _path_remove "$@"
    for dir in "$@"; do
        [ -d "$dir" ] || continue
        PATH="${PATH:+$PATH:}$dir"
    done
}

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="${HOME}/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Keep Rancher Desktop and Homebrew first for shell tooling, with MacPorts as a fallback.
_path_prepend \
    "${HOME}/.rd/bin" \
    /opt/homebrew/bin \
    /opt/homebrew/sbin \
    "${HOME}/.krew/bin" \
    /opt/homebrew/opt/gnu-sed/libexec/gnubin

_path_append /opt/local/bin /opt/local/sbin
export PATH

export EDITOR=vim
export VISUAL=vim
export PAGER=less

if command -v gls >/dev/null 2>&1; then
    alias ls='gls --color=auto'
else
    alias ls='ls -G'
fi
alias ll='ls -lah'
alias la='ls -A'
if command -v eza >/dev/null 2>&1; then
    alias lt='eza --tree --level=2 --icons=auto'
fi

set -o vi
shopt -s histappend checkwinsize cmdhist
HISTCONTROL='ignoreboth:erasedups'
HISTSIZE=50000
HISTFILESIZE=100000

if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
elif [ -f /opt/homebrew/etc/bash_completion ]; then
    . /opt/homebrew/etc/bash_completion
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

__bash_history_sync() {
    builtin history -a
    builtin history -n
}

case ";${PROMPT_COMMAND:-};" in
    *";__bash_history_sync;"*) ;;
    *) PROMPT_COMMAND="__bash_history_sync${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

if command -v atuin >/dev/null 2>&1 && [ -w "${HOME}/.config" ]; then
    eval "$(atuin init bash --disable-up-arrow)"
fi

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi
