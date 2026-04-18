#If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
autoload -U colors && colors
#PROMPT='%B%F{#d79921}%n%f%F{#cc241d}@%f%F{#8ec07c}%m%f %F{#a89984}%~%f %F{#fabd2f}>%f%b '
#PROMPT='%B%F{#cc241d}[%f%F{#d79921}%n%f%F{#b8bb26}@%f%F{#458588}%m%f %F{#fb4934}%~%f%F{#cc241d}]%f%F{#a89984}$%f%b '
PROMPT='%B%F{#cc241d}[%f%F{#d79921}%n%f%F{#b8bb26}@%f%F{#458588}%m%f %F{#d3869b}%~%f%F{#cc241d}]%f%F{#a89984}$%f%b '
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="/home/subh/go/bin:$PATH"
export GPG_TTY=$(tty)
source <(fzf --zsh)
# CTRL-Y to copy the command into clipboard using pbcopy
#####Exports######
##################
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export ZSH="$HOME/.oh-my-zsh"
export JAVA_HOME=/opt/java/jdk-24.0.2/
export PATH=$JAVA_HOME/bin:$PATH
export PATH=/home/subh/go:/home/subh/.cargo/bin:$PATH

eval "$(zoxide init zsh --cmd cd)"
#fastfetch --config os


set -o vi
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment th following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias v="vim"
alias a="aerc"
alias t="tmux"
alias open="xdg-open"
alias ls='exa -g'
alias venv='source /home/subh/venv/bin/activate'
alias y='EDITOR=vim yazi'
alias yi='yay -S'
alias grep='rg'
alias p='doas pacman'
alias find='fd -c always'
alias cat="bat -p --theme-dark 'Catppuccin Mocha'"
alias cp='rsync -av --progress'
alias define='/opt/scripts/define.sh'
alias noseyparker='/opt/nosyparker/bin/noseyparker'
alias etcdctl='/opt/etcd-v3.6.8-linux-amd64/etcdctl'
alias kubeletctl='/opt/kubeletctl'
alias gh='/opt/gh_2.87.3_linux_amd64/bin/gh'
alias sizeof="du -h -d 0 $1"
alias k='/usr/sbin/kubectl'
bindkey '^H' backward-kill-word
bindkey ' ' magic-space
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word


# ==== fzf key bindings (Arch Linux) ====

# Remove unsupported custom Ctrl-R command (zsh warning fix)

# fzf defaults
# ===== fzf appearance =====

export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border=rounded
  --info=inline
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
"
export FZF_CTRL_R_OPTS="
  --tac
  --preview 'echo {}'
  --preview-window=down:3:hidden:wrap
  --header='Ctrl-R: search history | Ctrl-J/K move | Enter select'
"
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=default
  --border=rounded
  --info=inline
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --color=bg+:#282828,bg:#1d2021,spinner:#8ec07c,hl:#fb4934 \
  --color=fg:#ebdbb2,header:#fb4934,info:#d3869b,pointer:#fabd2f \
  --color=marker:#b8bb26,fg+:#ebdbb2,prompt:#d3869b,hl+:#fb4934 \
  --color=selected-bg:#32302f \
  --color=border:#928374,label:#ebdbb2"
#export FZF_CTRL_R_OPTS="--tac --preview 'echo {}' --preview-window down:3:hidden:wrap"

# Source fzf (Arch path)
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi

if [[ -f /usr/share/fzf/completion.zsh ]]; then
  source /usr/share/fzf/completion.zsh
fi

# Ensure Ctrl+R works in vi insert mode too
bindkey -M viins '^R' fzf-history-widget

# ==== end fzf ====

# Created by `pipx` on 2026-01-10 08:53:29
export PATH="$PATH:/home/subh/.local/bin"

PATH="/home/subh/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/subh/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/subh/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/subh/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/subh/perl5"; export PERL_MM_OPT;

##MUSIC LESSGO

ytdl() {
    yt-dlp -f bestaudio -x --audio-format mp3 --embed-thumbnail --embed-metadata \
        -o "/mnt/$2/%(title)s.%(ext)s" "$1"
    rmpc update
}

ytdl-pl() {
    yt-dlp -f bestaudio -x --audio-format mp3 --embed-thumbnail --embed-metadata \
        -o "/mnt/%(playlist)s/%(title)s.%(ext)s" \
        --print-to-file "%(title)s.%(ext)s" "$HOME/Music/playlists/$1.m3u" \
        "$2"
    rmpc update
}
ms () {
    mpc clear
    mpc listall | shuf | shuf | mpc add
    mpc random on
    mpc shuffle
    mpc play
}

m() {
    case "$1" in
        start)
            systemctl start --user mpd
            ( quickshell --path /home/subh/.config/quickshell/mpd/shell.qml >/dev/null 2>&1 & );;
        stop)
            systemctl stop --user mpd
            pkill -f "quickshell/mpd/shell.qml"
            ;;
        *)
            echo "Usage: m {start|stop}"
            return 1
            ;;
    esac
}
    
mistral() {
    /opt/scripts/mistral
}

### Custom Listener Functions ###
#
listen() {
    if [[ -z $1 ]]; then
        echo "[*]Usage: listen <port>"
        return 1
    fi
    printf "\033[1;34m[*]\033[0m listening on %s...\n" "$1"
    rlwrap socat -d TCP-LISTEN:$1,reuseaddr, STDOUT 2>/dev/null
}



### Custom IP Listing function ###
ips() {
    local IFACE_COLOR="\033[1;34m"   
    local IP_COLOR="\033[0;32m"      
    local RESET="\033[0m"

    ip -4 -o addr show | while read -r _ ifname _ addr _; do
        printf "%b[%s]%b %b%s%b\n" \
            "$IFACE_COLOR" "$ifname" "$RESET" \
            "$IP_COLOR" "${addr%/*}" "$RESET"
    done
}


### Custom revshell generator ###
gen_ps_rev() {
    if [[ $# -lt 2 ]]; then
        echo "[*]gen_ps_rev <ip> <port>"
        return 1

    fi

    encoded_payload=$(sed -e "s/XXXX/$1/g" -e "s/YYYY/$2/g" /opt/offensive-windows/shell.ps1 | iconv -t UTF-16LE | base64 -w0)
    printf "\033[1;34m[*]\033[0m powershell -e %s\n" "$encoded_payload"
}


#compdef _cliam cliam

# zsh completion for cliam                                -*- shell-script -*-

__cliam_debug()
{
    local file="$BASH_COMP_DEBUG_FILE"
    if [[ -n ${file} ]]; then
        echo "$*" >> "${file}"
    fi
}

_cliam()
{
    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local lastParam lastChar flagPrefix requestComp out directive comp lastComp noSpace
    local -a completions

    __cliam_debug "\n========= starting completion logic =========="
    __cliam_debug "CURRENT: ${CURRENT}, words[*]: ${words[*]}"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CURRENT location, so we need
    # to truncate the command-line ($words) up to the $CURRENT location.
    # (We cannot use $CURSOR as its value does not work when a command is an alias.)
    words=("${=words[1,CURRENT]}")
    __cliam_debug "Truncated words[*]: ${words[*]},"

    lastParam=${words[-1]}
    lastChar=${lastParam[-1]}
    __cliam_debug "lastParam: ${lastParam}, lastChar: ${lastChar}"

    # For zsh, when completing a flag with an = (e.g., cliam -n=<TAB>)
    # completions must be prefixed with the flag
    setopt local_options BASH_REMATCH
    if [[ "${lastParam}" =~ '-.*=' ]]; then
        # We are dealing with a flag with an =
        flagPrefix="-P ${BASH_REMATCH}"
    fi

    # Prepare the command to obtain completions
    requestComp="${words[1]} __complete ${words[2,-1]}"
    if [ "${lastChar}" = "" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go completion code.
        __cliam_debug "Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __cliam_debug "About to call: eval ${requestComp}"

    # Use eval to handle any environment variables and such
    out=$(eval ${requestComp} 2>/dev/null)
    __cliam_debug "completion output: ${out}"

    # Extract the directive integer following a : from the last line
    local lastLine
    while IFS='\n' read -r line; do
        lastLine=${line}
    done < <(printf "%s\n" "${out[@]}")
    __cliam_debug "last line: ${lastLine}"

    if [ "${lastLine[1]}" = : ]; then
        directive=${lastLine[2,-1]}
        # Remove the directive including the : and the newline
        local suffix
        (( suffix=${#lastLine}+2))
        out=${out[1,-$suffix]}
    else
        # There is no directive specified.  Leave $out as is.
        __cliam_debug "No directive found.  Setting do default"
        directive=0
    fi

    __cliam_debug "directive: ${directive}"
    __cliam_debug "completions: ${out}"
    __cliam_debug "flagPrefix: ${flagPrefix}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        __cliam_debug "Completion received error. Ignoring completions."
        return
    fi

    while IFS='\n' read -r comp; do
        if [ -n "$comp" ]; then
            # If requested, completions are returned with a description.
            # The description is preceded by a TAB character.
            # For zsh's _describe, we need to use a : instead of a TAB.
            # We first need to escape any : as part of the completion itself.
            comp=${comp//:/\\:}

            local tab=$(printf '\t')
            comp=${comp//$tab/:}

            __cliam_debug "Adding completion: ${comp}"
            completions+=${comp}
            lastComp=$comp
        fi
    done < <(printf "%s\n" "${out[@]}")

    if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
        __cliam_debug "Activating nospace."
        noSpace="-S ''"
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local filteringCmd
        filteringCmd='_files'
        for filter in ${completions[@]}; do
            if [ ${filter[1]} != '*' ]; then
                # zsh requires a glob pattern to do file filtering
                filter="\*.$filter"
            fi
            filteringCmd+=" -g $filter"
        done
        filteringCmd+=" ${flagPrefix}"

        __cliam_debug "File filtering command: $filteringCmd"
        _arguments '*:filename:'"$filteringCmd"
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        subdir="${completions[1]}"
        if [ -n "$subdir" ]; then
            __cliam_debug "Listing directories in $subdir"
            pushd "${subdir}" >/dev/null 2>&1
        else
            __cliam_debug "Listing directories in ."
        fi

        local result
        _arguments '*:dirname:_files -/'" ${flagPrefix}"
        result=$?
        if [ -n "$subdir" ]; then
            popd >/dev/null 2>&1
        fi
        return $result
    else
        __cliam_debug "Calling _describe"
        if eval _describe "completions" completions $flagPrefix $noSpace; then
            __cliam_debug "_describe found some completions"

            # Return the success of having called _describe
            return 0
        else
            __cliam_debug "_describe did not find completions."
            __cliam_debug "Checking if we should do file completion."
            if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
                __cliam_debug "deactivating file completion"

                # We must return an error code here to let zsh know that there were no
                # completions found by _describe; this is what will trigger other
                # matching algorithms to attempt to find completions.
                # For example zsh can match letters in the middle of words.
                return 1
            else
                # Perform file completion
                __cliam_debug "Activating file completion"

                # We must return the result of this command, so it must be the
                # last command, or else we must store its result to return it.
                _arguments '*:filename:_files'" ${flagPrefix}"
            fi
        fi
    fi
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_cliam" ]; then
    _cliam
fi
export GTK_THEME="Adwaita-Dark"
