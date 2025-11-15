# ~/.bashrc

# Give a small intro message upon starting a new shell that most developers use
echo "Welcome $USER! Type 'aliases' to see custom aliases and key bindings."


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Set up environment variables
if command -v nvim &> /dev/null; then
    export EDITOR=nvim
    export VISUAL=nvim
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    case ":$PATH:" in
        *":$HOME/bin:"*) ;;
        *) export PATH="$HOME/bin:$PATH" ;;
    esac
fi

if [ -d "$HOME/.local/bin" ] ; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi


# Aliases

# Navigation & Directory
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# File Operations
alias ls='ls --color=auto'
alias la='ls -la'
alias ll='ls -lh'
alias l='ls -CF'
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Git
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gl='git log'
alias glog='git log --oneline --graph --decorate'
alias gp='git pull'
alias gpull='git pull'
alias gpush='git push'
alias gs='git status'
alias gst='git status'
alias lzg='lazygit'

# Docker
alias d='docker'
alias dc='docker compose'
alias dcd='docker compose down -v'
alias dcu='docker compose up -d'
alias dex='docker exec -it'
alias di='docker images'
alias dlogs='docker logs -f'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias lzd='lazydocker'

# System & Utilities
alias c='clear'
alias h='history'
alias path='echo -e ${PATH//:/\\n}'
alias reload='source ~/.bashrc'
alias please='sudo'
alias ports='netstat -tulanp'
alias qq='exit'

# Development Tools
alias py='python3'
alias pip='pip3'
alias v='nvim'
alias vim='nvim'
alias serve='python3 -m http.server'
alias jsonpp='python3 -m json.tool'
alias myip='curl ifconfig.me'

# Functions

# Better touch that creates directories if they don't exist
touch() {
    for file in "$@"; do
        if [[ "$file" == */* ]]; then
            mkdir -p "$(dirname "$file")"
        fi
        command touch "$file"
    done
}

# History search with arrow keys
# Make sure these bindings are in sync with the 'aliases' function below
bind '"\e[A": history-search-backward'  # Up arrow
bind '"\e[B": history-search-forward'   # Down arrow
bind '"\C-f": forward-word'              # Ctrl+F - jump forward one word
bind '"\C-b": backward-word'             # Ctrl+B - jump backward one word
bind '"\C-k": kill-line'                 # Ctrl+K - delete to end of line
bind '"\C-u": backward-kill-line'        # Ctrl+U - delete to start of line
bind '"\C-w": backward-kill-word'        # Ctrl+W - delete word backward

# Function to display welcome message
welcome() {
    if [ -f "$HOME/.welcome_message" ]; then
        if command -v bat &> /dev/null; then
            bat --style=plain --paging=never "$HOME/.welcome_message"
        else
            cat "$HOME/.welcome_message"
        fi
    else
        echo "Welcome message file not found at $HOME/.welcome_message"
    fi
}

aliases() {
    # Create a temporary file for bat to display with syntax highlighting
    local temp_file=$(mktemp)
    
    {
        echo ""
        echo "╔══════════════════════════════════════════════════════════════════════════════╗"
        echo "║                           📋 Custom Aliases                                  ║"
        echo "╚══════════════════════════════════════════════════════════════════════════════╝"
        echo ""
        
        # Display aliases in a formatted table
        alias | sed 's/^alias //' | awk -F= '{
            alias=$1
            cmd=$2
            gsub(/^'\''|'\''$/, "", cmd)
            printf "  %-12s → %s\n", alias, cmd
        }' | sort
        
        echo ""
        echo "╔══════════════════════════════════════════════════════════════════════════════╗"
        echo "║                         ⌨️  Custom Key Bindings                              ║"
        echo "╚══════════════════════════════════════════════════════════════════════════════╝"
        echo ""
        
        # Display key bindings in readable format - only show our custom bindings
        # This must be maintained in sync with the bind commands above
        printf "  %-20s → %s\n" "Up Arrow" "Search history backward (with prefix)"
        printf "  %-20s → %s\n" "Down Arrow" "Search history forward (with prefix)"
        printf "  %-20s → %s\n" "Ctrl+F" "Jump forward one word"
        printf "  %-20s → %s\n" "Ctrl+B" "Jump backward one word"
        printf "  %-20s → %s\n" "Ctrl+K" "Delete from cursor to end of line"
        printf "  %-20s → %s\n" "Ctrl+U" "Delete from cursor to start of line"
        printf "  %-20s → %s\n" "Ctrl+W" "Delete word backward"
        
        echo ""
        echo "💡 Tip: Type 'welcome' to see the full welcome message with descriptions"
        echo ""
    } > "$temp_file"
    
    # Display with bat if available, otherwise use cat
    if command -v bat &> /dev/null; then
        bat --style=plain --paging=never "$temp_file"
    else
        cat "$temp_file"
    fi
    
    rm -f "$temp_file"
}

# Enable color support for ls and grep
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagacad

# Load additional scripts if they exist
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# Initialize Starship prompt if installed
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# User-specific shell configuration for bash
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# NVM (Node Version Manager) setup
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Initialize zoxide if installed
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# Herd Lite PHP environment variables if installed
if [ -d "$HOME/.config/herd-lite/bin" ]; then
    export PATH="$HOME/.config/herd-lite/bin:$PATH"
    export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
fi